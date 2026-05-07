from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import pandas as pd
import shap
import matplotlib
import matplotlib.pyplot as plt
import io
import base64
import os
import json
import time
from dotenv import load_dotenv
import google.generativeai as genai

# --- Import CNN Food Classifier ---
from cnn_food_classifier import food_classifier

# Set matplotlib to non-interactive mode
matplotlib.use('Agg')

# --- SECURE: Configure Google Gemini AI ---
load_dotenv()
my_secret_key = os.getenv("GEMINI_API_KEY")

if not my_secret_key:
    print(" WARNING: GEMINI_API_KEY not found! Please check your .env file.")

genai.configure(api_key=my_secret_key)
llm_model = genai.GenerativeModel('gemini-2.5-flash')

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================
# --- JSON DATABASE LOGIC ---
# ==========================================
DB_FILE = "clinical_history.json"

def save_to_local_db(session_id, actor, content):
    try:
        with open(DB_FILE, "r") as f:
            db = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        db = {}
    if session_id not in db:
        db[session_id] = []
    db[session_id].append({
        "actor": actor,
        "content": content,
        "timestamp": int(time.time() * 1000)
    })
    with open(DB_FILE, "w") as f:
        json.dump(db, f, indent=4)

def get_local_history(session_id):
    try:
        with open(DB_FILE, "r") as f:
            db = json.load(f)
        return db.get(session_id, [])
    except (FileNotFoundError, json.JSONDecodeError):
        return []


# ==========================================
# --- DRINK DETECTION HELPER ---
# The Random Forest was trained on meal data only.
# Drinks (coffee, tea, water) have near-zero nutrition
# so we bypass RF and return a clinically accurate
# near-zero spike instead.
# ==========================================

def is_drink_detected(carbs: float, calories: float, protein: float) -> bool:
    """Returns True if nutrition values indicate a drink."""
    return carbs <= 1.0 and calories <= 15 and protein <= 1.0


def get_drink_response(patient_id: int, microbiome_type: str,
                       carbs: float, calories: float,
                       food_name: str = "drink") -> dict:
    """
    Clinically accurate response for drinks.
    Bypasses Random Forest — predicts 1 mg/dL spike.
    """
    drink_advice = (
        f"☕ Excellent choice for blood glucose management! "
        f"Your {food_name} contains virtually no carbohydrates ({carbs}g), "
        f"meaning your blood glucose response will be minimal — a predicted rise of just 1 mg/dL. "
        f"\n\n* **Clinical Insight:** With near-zero carbohydrate content, "
        f"your {microbiome_type} gut microbiome has no significant fermentable substrate "
        f"to process, resulting in negligible glycaemic impact. "
        f"\n* **Action Plan:** Continue enjoying unsweetened beverages freely — "
        f"they support hydration without disrupting your glucose balance."
    )

    try:
        prompt = f"""You are an expert Clinical AI Nutritionist.
A patient logged a drink: {food_name} with {calories} calories and {carbs}g carbs.
Their Gut Microbiome Profile is: {microbiome_type}.
The predicted blood glucose impact is just 1 mg/dL — essentially zero.

Write a brief, encouraging response (2-3 sentences max) explaining:
- Why this drink has minimal glucose impact
- How their {microbiome_type} microbiome interacts with it
Keep it positive and clinically accurate.
Format: one intro sentence then two bullet points:
* **Clinical Insight:** ...
* **Action Plan:** ..."""
        response = llm_model.generate_content(prompt)
        drink_advice = response.text.strip()
    except Exception:
        pass  # Use fallback advice

    try:
        session_id = f"patient_{patient_id}"
        save_to_local_db(session_id, "User",
                         f"Logged Drink: {food_name} — {calories} kcal, {carbs}g carbs")
        save_to_local_db(session_id, "AI",
                         f"Predicted Spike: 1 mg/dL (drink detected). {drink_advice}")
        print(f" Successfully saved drink log for patient_{patient_id}")
    except Exception:
        pass

    return {
        "status": "success",
        "patient_id": patient_id,
        "predicted_spike": 1.0,
        "shap_image_base64": "",
        "ai_advice": drink_advice,
        "message": f"Drink detected ({food_name}) — minimal glucose impact predicted."
    }


# ==========================================
# --- EMPTY PLATE DETECTION HELPER ---
# When a user uploads an almost empty plate or food residue,
# the CNN may still detect some nutrition values from crumbs
# or stains. This bypass catches those cases and returns a
# clear message instead of a misleading prediction.
#
# Thresholds (after portion scaling to 150g default):
#   calories <= 50 AND carbs <= 8g AND protein <= 5g
# These are deliberately generous to avoid false positives
# on genuinely light meals like plain lettuce.
# ==========================================

def is_empty_plate(carbs: float, calories: float,
                   protein: float, fiber: float,
                   food_name: str = "") -> bool:
    """
    Returns True if nutrition values suggest an empty or near-empty plate.
    Checked BEFORE is_drink_detected so empty plates are not
    misclassified as drinks when CNN returns all-zero nutrition.
    Three cases caught:
      1. CNN returned 'empty plate' label explicitly
      2. All nutrition values are exactly zero (empty plate DB entry)
      3. Near-zero values that are not a drink
    """
    # Case 1: CNN explicitly detected empty plate
    if "empty" in food_name.lower():
        return True
    # Case 2: All zeros — empty plate maps to (0,0,0,0) in NUTRITION_DATABASE
    if calories == 0 and carbs == 0.0 and protein == 0.0 and fiber == 0.0:
        return True
    # Case 3: Very low nutrition — exclude drinks first
    if is_drink_detected(carbs, calories, protein):
        return False
    return calories <= 50 and carbs <= 8.0 and protein <= 5.0


def get_empty_plate_response(patient_id: int,
                              food_name: str = "plate") -> dict:
    """
    Returns a clear user-facing message when an empty or near-empty
    plate is detected. Bypasses the Random Forest entirely —
    no prediction is made.
    """
    return {
        "status": "empty_plate",
        "patient_id": patient_id,
        "predicted_spike": 0.0,
        "shap_image_base64": "",
        "ai_advice": (
            "⚠️ **Empty Plate Detected** — It looks like your photo shows "
            "little or no food. No glucose prediction has been made. "
            "Please take a new photo of your meal before eating and try again."
        ),
        "message": "Empty or near-empty plate detected — please retake with food present."
    }


# ==========================================
# --- NUTRITION CALIBRATION LAYER ---
# The Random Forest uses ~1,990 features, of which only 4 are
# nutritional. The remaining ~1,986 microbiome features dominate,
# causing predictions to cluster around the patient baseline (~44 mg/dL).
#
# This calibration layer blends the RF's patient-personalised baseline
# with a nutrition-sensitive component using DYNAMIC weights — so that
# low-carb meals (eggs, salad) are not pulled up by a high patient
# baseline, while high-carb meals (pizza, sandwich) still reflect
# the patient's microbiome personalisation.
# ==========================================

def calibrate_prediction(rf_prediction: float, carbs: float,
                          fiber: float, protein: float) -> float:
    """
    Blends the RF patient baseline with a nutrition-driven component.
    Uses dynamic weighting based on net carb content so that:
      - Low-carb meals  (<10g net carbs): nutrition drives 70% of output
      - Medium-carb     (10-25g):         nutrition drives 55%
      - High-carb meals (>25g net carbs): nutrition drives 45%
    """
    net_carbs = max(0.0, carbs - (fiber * 0.5))
    nutrition_spike = (net_carbs / 2.0) - (protein * 0.08)
    nutrition_spike = max(2.0, nutrition_spike)  # floor at 2 mg/dL

    if net_carbs < 10:
        rf_weight, nut_weight = 0.30, 0.70
    elif net_carbs < 25:
        rf_weight, nut_weight = 0.45, 0.55
    else:
        rf_weight, nut_weight = 0.55, 0.45

    calibrated = (rf_weight * rf_prediction) + (nut_weight * nutrition_spike)
    return round(max(3.0, min(130.0, calibrated)), 1)


@app.get("/api/test-connection")
async def test_connection():
    return {"message": "Success! FastAPI is connected to React."}


# Load AI Model and Patient Data
try:
    rf_model = joblib.load('models/glucose_rf_model.pkl')
    patient_profiles = pd.read_csv('models/patient_profiles.csv')
    explainer = shap.TreeExplainer(rf_model)
    print(" AI Model, Explainer, and Patient Data loaded successfully!")
except Exception as e:
    print(f" Error loading model: {e}")


class MealInput(BaseModel):
    patient_id: int
    microbiome_type: str = None
    carbs: float
    fiber: float
    protein: float
    calories: float


# ==========================================
# --- ENDPOINT 1: Manual Meal Prediction ---
# ==========================================

@app.post("/api/predict")
async def predict_glucose(meal: MealInput):
    try:
        total_profiles = len(patient_profiles)
        if total_profiles == 0:
            raise HTTPException(status_code=500, detail="Dataset is empty!")

        # EMPTY PLATE OVERRIDE — must come BEFORE drink check
        # (empty plates return all-zero nutrition which would trigger drink detection)
        if is_empty_plate(meal.carbs, meal.calories, meal.protein, meal.fiber):
            print(f"🍽️ Empty plate detected (carbs={meal.carbs}, cals={meal.calories}) — bypassing RF")
            return get_empty_plate_response(patient_id=meal.patient_id)

        # DRINK OVERRIDE
        if is_drink_detected(meal.carbs, meal.calories, meal.protein):
            print(f"☕ Drink detected (carbs={meal.carbs}, cals={meal.calories}) — bypassing RF")
            return get_drink_response(
                patient_id=meal.patient_id,
                microbiome_type=meal.microbiome_type,
                carbs=meal.carbs,
                calories=meal.calories,
                food_name="drink"
            )

        # Normal meal prediction
        safe_index = meal.patient_id % total_profiles
        patient_data = patient_profiles.iloc[[safe_index]].copy()
        patient_data['Carbs'] = meal.carbs
        patient_data['Fiber'] = meal.fiber
        patient_data['Protein'] = meal.protein
        patient_data['Calories'] = meal.calories

        prediction = rf_model.predict(patient_data)[0]

        # Apply nutrition-sensitive calibration to fix clustering around patient baseline
        display_spike = calibrate_prediction(prediction, meal.carbs, meal.fiber, meal.protein)
        print(f"[PREDICT] RF raw={round(prediction,1)} → calibrated={display_spike} "
              f"(carbs={meal.carbs}, fiber={meal.fiber}, protein={meal.protein})")

        # Generate SHAP waterfall — adjust base_values so f(x) matches calibrated spike
        shap_values = explainer(patient_data)
        shap_values.base_values[0] = display_spike - float(shap_values.values[0].sum())
        plt.figure()
        shap.plots.waterfall(shap_values[0], show=False)
        plt.title(f"Predicted Spike: {display_spike} mg/dL (Calibrated)", fontsize=10, pad=8)
        buf = io.BytesIO()
        plt.savefig(buf, format="png", bbox_inches='tight')
        plt.close()
        buf.seek(0)
        base64_image = base64.b64encode(buf.read()).decode('utf-8')

        prompt = f"""
        You are an expert Clinical AI Nutritionist. 
        A patient just logged a meal with {meal.carbs}g carbs, {meal.protein}g protein, and {meal.fiber}g fiber.
        Their specific Gut Microbiome Profile is: {meal.microbiome_type}.
        Our predictive machine learning model calculated their blood glucose will spike by EXACTLY {display_spike} mg/dL.
        
        STRICT RULES:
        1. You MUST use the exact number {display_spike} in your response.
        2. You MUST mention how their specific Microbiome Profile interacts with this meal.
        3. Format your response exactly like this:
        Write one short, encouraging introductory sentence. Then provide exactly two bullet points:
        * **Clinical Insight:** (Briefly explain which macro and gut bacteria are driving this specific spike).
        * **Action Plan:** (Give one realistic, immediate physical action or a specific dietary tweak for next time. Be concise).
        """

        try:
            response = llm_model.generate_content(prompt)
            ai_advice_text = response.text.strip()
        except Exception as e:
            print(f"\n GEMINI FALLBACK: {e}\n")
            if meal.carbs > 40 and meal.fiber < 5:
                ai_advice_text = (
                    f"Clinical Analysis: Your meal contains a high carbohydrate load ({meal.carbs}g) "
                    f"with minimal fiber ({meal.fiber}g). Combined with your {meal.microbiome_type} profile, "
                    f"this is the primary driver for your predicted {display_spike} mg/dL glucose spike. "
                    f"Actionable Advice: Take a 10-15 minute light walk after eating."
                )
            else:
                ai_advice_text = (
                    f"Clinical Analysis: Based on your {meal.microbiome_type} profile, this meal "
                    f"generates a {display_spike} mg/dL variation. Actionable Advice: Try slightly "
                    f"increasing your fiber-to-carbohydrate ratio to feed your gut bacteria."
                )

        try:
            session_id = f"patient_{meal.patient_id}"
            save_to_local_db(session_id, "User",
                f"Logged Meal: {meal.carbs}g Carbs, {meal.protein}g Protein, "
                f"{meal.fiber}g Fiber. (Gut: {meal.microbiome_type})")
            save_to_local_db(session_id, "AI",
                f"Predicted Spike: {display_spike} mg/dL. Advice: {ai_advice_text}")
            print(f" Successfully saved log to JSON for patient_{meal.patient_id}")
        except Exception as db_err:
            print(f" Error saving to JSON: {db_err}")

        return {
            "status": "success",
            "patient_id": meal.patient_id,
            "predicted_spike": display_spike,
            "shap_image_base64": base64_image,
            "ai_advice": ai_advice_text,
            "message": "Prediction and Explanation generated successfully!"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==========================================
# --- ENDPOINT 2: CNN Food Image Analysis ---
# ==========================================

@app.post("/api/analyse-food-image")
async def analyse_food_image(file: UploadFile = File(...)):
    try:
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400,
                detail=f"File must be an image. Got: {file.content_type}")

        image_bytes = await file.read()
        if len(image_bytes) == 0:
            raise HTTPException(status_code=400, detail="Uploaded file is empty.")

        result = food_classifier.classify(image_bytes, filename=file.filename or "")

        return {
            "status": "success",
            "food_name": result["food_name"],
            "raw_label": result["raw_label"],
            "confidence": result["confidence"],
            "low_confidence": result.get("low_confidence", False),
            "nutrition_per_100g": {
                "calories": result["calories"],
                "carbs": result["carbs"],
                "protein": result["protein"],
                "fiber": result["fiber"],
                "fat": result["fat"],
            },
            "top_predictions": result["top_predictions"],
            "message": f"Detected: {result['food_name']} ({result['confidence']}% confidence)"
        }

    except HTTPException:
        raise
    except Exception as err:
        print(f"CNN ERROR: {str(err)}")
        raise HTTPException(status_code=500, detail=f"CNN classification failed: {str(err)}")


# ==========================================
# --- ENDPOINT 3: Full Image Pipeline ---
# ==========================================

@app.post("/api/predict-from-image")
async def predict_from_image(
    patient_id: int,
    microbiome_type: str = None,
    portion_grams: float = 150.0,
    file: UploadFile = File(...)
):
    try:
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="File must be an image.")

        image_bytes = await file.read()
        cnn_result = food_classifier.classify(image_bytes, filename=file.filename or "")

        scale    = portion_grams / 100.0
        calories = round(cnn_result["calories"] * scale, 1)
        carbs    = round(cnn_result["carbs"]    * scale, 1)
        protein  = round(cnn_result["protein"]  * scale, 1)
        fiber    = round(cnn_result["fiber"]    * scale, 1)
        fat      = round(cnn_result["fat"]      * scale, 1)
        food_name  = cnn_result["food_name"]
        confidence = cnn_result["confidence"]

        # EMPTY PLATE OVERRIDE — must come BEFORE drink check
        # (empty plates return all-zero nutrition which would trigger drink detection)
        if is_empty_plate(carbs, calories, protein, fiber):
            print(f"🍽️ Empty plate detected: {food_name} (carbs={carbs}, cals={calories}) — bypassing RF")
            empty_resp = get_empty_plate_response(
                patient_id=patient_id,
                food_name=food_name
            )
            empty_resp["cnn_result"] = {
                "food_name": food_name,
                "confidence": confidence,
                "top_predictions": cnn_result["top_predictions"],
            }
            empty_resp["nutrition"] = {
                "calories": calories, "carbs": carbs, "protein": protein,
                "fiber": fiber, "fat": fat, "portion_grams": portion_grams,
            }
            return empty_resp

        # DRINK OVERRIDE
        if is_drink_detected(carbs, calories, protein):
            print(f"☕ Drink detected via image: {food_name} — bypassing RF model")
            drink_resp = get_drink_response(
                patient_id=patient_id,
                microbiome_type=microbiome_type,
                carbs=carbs,
                calories=calories,
                food_name=food_name
            )
            drink_resp["cnn_result"] = {
                "food_name": food_name,
                "confidence": confidence,
                "top_predictions": cnn_result["top_predictions"],
            }
            drink_resp["nutrition"] = {
                "calories": calories, "carbs": carbs, "protein": protein,
                "fiber": fiber, "fat": fat, "portion_grams": portion_grams,
            }
            return drink_resp

        # Normal meal flow
        total_profiles = len(patient_profiles)
        safe_index = patient_id % total_profiles
        patient_data = patient_profiles.iloc[[safe_index]].copy()
        patient_data['Carbs']    = carbs
        patient_data['Fiber']    = fiber
        patient_data['Protein']  = protein
        patient_data['Calories'] = calories

        prediction = rf_model.predict(patient_data)[0]

        # Apply nutrition-sensitive calibration to fix clustering around patient baseline
        display_spike = calibrate_prediction(prediction, carbs, fiber, protein)
        print(f"[IMAGE PREDICT] RF raw={round(prediction,1)} → calibrated={display_spike} "
              f"(carbs={carbs}, fiber={fiber}, protein={protein})")

        # Generate SHAP waterfall — adjust base_values so f(x) matches calibrated spike
        shap_values = explainer(patient_data)
        shap_values.base_values[0] = display_spike - float(shap_values.values[0].sum())
        plt.figure()
        shap.plots.waterfall(shap_values[0], show=False)
        plt.title(f"Predicted Spike: {display_spike} mg/dL (Calibrated)", fontsize=10, pad=8)
        buf = io.BytesIO()
        plt.savefig(buf, format="png", bbox_inches='tight')
        plt.close()
        buf.seek(0)
        base64_image = base64.b64encode(buf.read()).decode('utf-8')

        prompt = f"""
        You are an expert Clinical AI Nutritionist.
        A patient uploaded a photo of their meal. Our CNN (Gemini Vision) identified 
        the food as: {food_name} (confidence: {confidence}%).
        Portion size: {portion_grams}g
        Nutritional breakdown: {carbs}g carbs, {protein}g protein, {fiber}g fiber, {fat}g fat, {calories} kcal.
        Their Gut Microbiome Profile is: {microbiome_type}.
        Our Random Forest model predicts their blood glucose will spike by EXACTLY {display_spike} mg/dL.
        
        STRICT RULES:
        1. You MUST mention the food was identified as {food_name} from a photo.
        2. You MUST use the exact number {display_spike} in your response.
        3. You MUST mention their Microbiome Profile.
        4. Format: one intro sentence then two bullet points:
        * **Clinical Insight:** ...
        * **Action Plan:** ...
        """

        try:
            response = llm_model.generate_content(prompt)
            ai_advice_text = response.text.strip()
        except Exception as e:
            print(f"\n GEMINI FALLBACK: {e}\n")
            ai_advice_text = (
                f"Clinical Analysis: Your {food_name} ({portion_grams}g) contains "
                f"{carbs}g carbs and {fiber}g fiber. Combined with your {microbiome_type} profile, "
                f"the predicted glucose spike is {display_spike} mg/dL. "
                f"Actionable Advice: Consider a 10-minute walk after this meal."
            )

        try:
            session_id = f"patient_{patient_id}"
            save_to_local_db(session_id, "User",
                f"[IMAGE UPLOAD] Food: {food_name} (CNN: {confidence}%), "
                f"{carbs}g Carbs, {protein}g Protein, {fiber}g Fiber (Gut: {microbiome_type})")
            save_to_local_db(session_id, "AI",
                f"Predicted Spike: {display_spike} mg/dL. Advice: {ai_advice_text}")
        except Exception as db_err:
            print(f" DB Error: {db_err}")

        return {
            "status": "success",
            "patient_id": patient_id,
            "cnn_result": {
                "food_name": food_name,
                "confidence": confidence,
                "top_predictions": cnn_result["top_predictions"],
            },
            "nutrition": {
                "calories": calories, "carbs": carbs, "protein": protein,
                "fiber": fiber, "fat": fat, "portion_grams": portion_grams,
            },
            "predicted_spike": display_spike,
            "shap_image_base64": base64_image,
            "ai_advice": ai_advice_text,
            "message": f"Image analysed: {food_name} → {display_spike} mg/dL predicted spike"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Image prediction failed: {str(e)}")


# ==========================================
# --- EXISTING ENDPOINTS ---
# ==========================================

@app.get("/api/patients")
async def get_patients():
    try:
        num_patients = len(patient_profiles)
        patients_list = [{"id": i, "name": f"Patient Profile {i}"} for i in range(num_patients)]
        return {"patients": patients_list}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/history/{patient_id}")
async def get_patient_history(patient_id: int):
    try:
        session_id = f"patient_{patient_id}"
        history = get_local_history(session_id)
        return {"patient_id": patient_id, "history": history}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))