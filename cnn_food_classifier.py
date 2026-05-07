"""
NutriAI - Food Classifier using Google Gemini Vision
Multi-model fallback chain ensures system works even when quota is hit.
Primary: gemini-2.5-flash (20/day)
Backup 1: gemini-2.5-flash-lite (1500/day)
Backup 2: gemini-2.0-flash-lite (1500/day)
Final: Smart offline color + filename detection

v2: Multi-label detection — identifies multiple food components
on a single plate and sums their nutrition proportionally.
"""

import json
import os
import re
import numpy as np
from pathlib import Path
from dotenv import load_dotenv
import google.generativeai as genai
from PIL import Image
import io

_env_path = Path(__file__).resolve().parent / '.env'
load_dotenv(dotenv_path=_env_path, override=True)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
print(f"🔑 Gemini Vision Key: {'LOADED ✅' if GEMINI_API_KEY else 'MISSING ❌'}")

if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

NUTRITION_DATABASE = {
    "banana":           (89,   23.0,  1.1,  2.6,  0.3,  "Banana"),
    "apple":            (52,   14.0,  0.3,  2.4,  0.2,  "Apple"),
    "orange":           (47,   12.0,  0.9,  2.4,  0.1,  "Orange"),
    "clementine":       (47,   12.0,  0.9,  1.7,  0.1,  "Clementine"),
    "tangerine":        (47,   12.0,  0.9,  1.7,  0.1,  "Tangerine"),
    "mango":            (60,   15.0,  0.8,  1.6,  0.4,  "Mango"),
    "kiwi":             (61,   15.0,  1.1,  3.0,  0.5,  "Kiwi"),
    "strawberry":       (32,    7.7,  0.7,  2.0,  0.3,  "Strawberry"),
    "grapes":           (69,   18.0,  0.7,  0.9,  0.2,  "Grapes"),
    "watermelon":       (30,    7.6,  0.6,  0.4,  0.2,  "Watermelon"),
    "pineapple":        (50,   13.1,  0.5,  1.4,  0.1,  "Pineapple"),
    "avocado":          (160,   9.0,  2.0,  7.0, 15.0,  "Avocado"),
    "blueberry":        (57,   14.5,  0.7,  2.4,  0.3,  "Blueberries"),
    "broccoli":         (34,    7.0,  2.8,  2.6,  0.4,  "Broccoli"),
    "carrot":           (41,    9.6,  0.9,  2.8,  0.2,  "Carrot"),
    "spinach":          (23,    3.6,  2.9,  2.2,  0.4,  "Spinach"),
    "tomato":           (18,    3.9,  0.9,  1.2,  0.2,  "Tomato"),
    "potato":           (77,   17.0,  2.0,  2.2,  0.1,  "Potato"),
    "sweet potato":     (86,   20.0,  1.6,  3.0,  0.1,  "Sweet Potato"),
    "corn":             (86,   19.0,  3.2,  2.7,  1.2,  "Corn"),
    "mushroom":         (22,    3.3,  3.1,  1.0,  0.3,  "Mushroom"),
    "lettuce":          (15,    2.9,  1.4,  1.3,  0.2,  "Lettuce/Salad"),
    "pepper":           (31,    6.0,  1.0,  2.1,  0.3,  "Bell Pepper"),
    "rice":             (130,  28.0,  2.7,  0.4,  0.3,  "White Rice"),
    "fried rice":       (163,  22.0,  3.4,  0.7,  7.0,  "Fried Rice"),
    "brown rice":       (112,  24.0,  2.6,  1.8,  0.9,  "Brown Rice"),
    "bread":            (265,  49.0,  9.0,  2.7,  3.2,  "Bread"),
    "pasta":            (158,  31.0,  5.8,  1.8,  0.9,  "Pasta"),
    "noodles":          (138,  25.0,  4.5,  1.2,  2.0,  "Noodles"),
    "oats":             (389,  66.0, 17.0, 11.0,  7.0,  "Oats/Porridge"),
    "pizza":            (266,  33.0, 11.0,  2.3, 10.4,  "Pizza"),
    "burger":           (295,  24.0, 17.0,  1.3, 14.0,  "Burger"),
    "hamburger":        (295,  24.0, 17.0,  1.3, 14.0,  "Hamburger"),
    "hotdog":           (290,  18.3, 10.4,  0.9, 20.0,  "Hot Dog"),
    "sandwich":         (250,  30.0, 12.0,  2.5,  8.0,  "Sandwich"),
    "french fries":     (312,  41.0,  3.4,  3.8, 15.0,  "French Fries"),
    "fried chicken":    (246,   8.0, 22.0,  0.5, 14.0,  "Fried Chicken"),
    "taco":             (226,  20.0, 11.0,  2.9, 11.0,  "Taco"),
    "burrito":          (217,  26.0,  9.0,  2.8,  8.0,  "Burrito"),
    "sushi":            (150,  20.0,  7.5,  0.5,  4.0,  "Sushi"),
    "ramen":            (436,  54.0, 18.0,  2.0, 16.0,  "Ramen"),
    "curry":            (150,  12.0,  9.0,  2.8,  7.0,  "Curry"),
    "biryani":          (200,  28.0,  9.0,  1.5,  6.0,  "Biryani"),
    "stir fry":         (150,  10.0, 12.0,  2.5,  7.0,  "Stir Fry"),
    "dumpling":         (200,  25.0,  8.0,  1.5,  7.0,  "Dumplings"),
    "pad thai":         (320,  34.0, 18.0,  2.0, 12.0,  "Pad Thai"),
    "dal":              (116,  20.0,  9.0,  8.0,  0.4,  "Dal/Lentils"),
    "naan":             (310,  50.0,  9.0,  2.0,  8.0,  "Naan"),
    "chapati":          (297,  52.0,  9.0,  4.0,  6.0,  "Chapati/Roti"),
    "samosa":           (262,  28.0,  5.0,  2.5, 14.0,  "Samosa"),
    "kebab":            (172,   5.0, 20.0,  0.8,  8.0,  "Kebab"),
    "hummus":           (177,  14.0,  8.0,  6.0, 10.0,  "Hummus"),
    "shawarma":         (220,  18.0, 16.0,  1.5, 10.0,  "Shawarma"),
    "chicken":          (165,   0.0, 31.0,  0.0,  3.6,  "Chicken"),
    "steak":            (271,   0.0, 26.0,  0.0, 18.0,  "Steak"),
    "beef":             (250,   0.0, 26.0,  0.0, 17.0,  "Beef"),
    "fish":             (136,   0.0, 20.0,  0.0,  5.0,  "Fish"),
    "salmon":           (208,   0.0, 20.0,  0.0, 13.0,  "Salmon"),
    "egg":              (155,   1.1, 13.0,  0.0, 11.0,  "Egg"),
    "bacon":            (541,   1.4, 37.0,  0.0, 42.0,  "Bacon"),
    "tofu":             (76,    1.9,  8.0,  0.3,  4.8,  "Tofu"),
    "cheese":           (402,   1.3, 25.0,  0.0, 33.0,  "Cheese"),
    "yogurt":           (59,    3.6,  3.5,  0.0,  3.3,  "Yogurt"),
    "chocolate":        (546,  60.0,  5.0,  7.0, 31.0,  "Chocolate"),
    "cake":             (347,  53.0,  4.0,  0.9, 13.0,  "Cake"),
    "donut":            (452,  51.0,  7.0,  1.6, 25.0,  "Donut"),
    "ice cream":        (207,  24.0,  3.5,  0.6, 11.0,  "Ice Cream"),
    "soup":             (50,    7.0,  2.5,  1.2,  1.5,  "Soup"),
    "salad":            (15,    2.8,  1.3,  1.5,  0.2,  "Green Salad"),
    "grain bowl":       (280,  35.0, 12.0,  6.0,  9.0,  "Grain Bowl"),
    "coffee":           (2,     0.0,  0.3,  0.0,  0.0,  "Black Coffee"),
    "black coffee":     (2,     0.0,  0.3,  0.0,  0.0,  "Black Coffee"),
    "espresso":         (2,     0.0,  0.3,  0.0,  0.0,  "Espresso"),
    "latte":            (120,  12.0,  6.0,  0.0,  5.0,  "Latte"),
    "cappuccino":       (80,    8.0,  5.0,  0.0,  3.0,  "Cappuccino"),
    "tea":              (1,     0.3,  0.0,  0.0,  0.0,  "Tea"),
    "juice":            (45,   11.0,  0.7,  0.2,  0.1,  "Fruit Juice"),
    "smoothie":         (80,   18.0,  1.5,  1.5,  0.5,  "Smoothie"),
    "water":            (0,     0.0,  0.0,  0.0,  0.0,  "Water"),
    # ── EMPTY PLATE ─────────────────────────────────────────
    "empty plate":      (0,     0.0,  0.0,  0.0,  0.0,  "Empty Plate"),
    "empty_plate":      (0,     0.0,  0.0,  0.0,  0.0,  "Empty Plate"),
    # ────────────────────────────────────────────────────────
    "unknown_food":     (200,  25.0,  8.0,  2.0,  7.0,  "Mixed Meal (estimated)"),
}


def find_nutrition(food_name: str):
    """Look up nutrition for a single food item."""
    name_lower = food_name.lower().strip()
    if name_lower in NUTRITION_DATABASE:
        return NUTRITION_DATABASE[name_lower]
    for key in NUTRITION_DATABASE:
        if key in name_lower:
            return NUTRITION_DATABASE[key]
    for key in NUTRITION_DATABASE:
        if name_lower in key and len(name_lower) > 3:
            return NUTRITION_DATABASE[key]
    return NUTRITION_DATABASE["unknown_food"]


def combine_nutrition(foods: list) -> tuple:
    """
    Takes a list of {"food_name": ..., "portion_percent": ...} dicts.
    Normalises portions to 100% then returns weighted-average nutrition.
    Falls back gracefully if portion data is missing.

    Returns: (calories, carbs, protein, fiber, fat, friendly_name)
    """
    if not foods:
        return NUTRITION_DATABASE["unknown_food"]

    # Single food — no blending needed
    if len(foods) == 1:
        n = find_nutrition(foods[0]["food_name"])
        return n

    # Normalise portions so they always sum to 100
    total_pct = sum(f.get("portion_percent", 0) for f in foods)
    if total_pct <= 0:
        # No portion info — split evenly
        for f in foods:
            f["portion_percent"] = 100.0 / len(foods)
        total_pct = 100.0

    cal = carb = prot = fib = fat_val = 0.0
    names = []

    for f in foods:
        pct = f.get("portion_percent", 100.0 / len(foods)) / total_pct
        n = find_nutrition(f["food_name"])
        cal      += n[0] * pct
        carb     += n[1] * pct
        prot     += n[2] * pct
        fib      += n[3] * pct
        fat_val  += n[4] * pct
        names.append(n[5])  # friendly name

    friendly = " + ".join(names)
    return (round(cal), round(carb, 1), round(prot, 1),
            round(fib, 1), round(fat_val, 1), friendly)


def offline_classify(img: Image.Image, filename: str = "") -> tuple:
    """Smart offline fallback — filename + color analysis."""
    if filename:
        name = filename.lower().replace('_', ' ').replace('-', ' ')
        name = re.sub(r'\.(jpg|jpeg|png|gif|webp|bmp)$', '', name)
        name = re.sub(r'\d+', '', name).strip()
        for key in NUTRITION_DATABASE:
            if key in name and key != "unknown_food":
                print(f"📁 Filename match: {key}")
                return key, 75.0

    img_small = img.resize((50, 50))
    pixels = np.array(img_small).reshape(-1, 3).astype(float)
    avg = pixels.mean(axis=0)
    r, g, b = avg

    if r < 80 and g < 60 and b < 50:   return "coffee", 70.0
    if r > 180 and 80 < g < 160 and b < 80: return "orange", 65.0
    if r > 180 and g > 160 and b < 100: return "banana", 65.0
    if g > r and g > b and g > 80 and r < 120: return "salad", 60.0
    if r > 150 and g < 80 and b < 80:   return "tomato", 60.0
    if r > 180 and g > 160 and b > 130: return "rice", 55.0
    if 100 < r < 180 and 60 < g < 120 and b < 80: return "chicken", 55.0
    return "unknown_food", 30.0


def try_gemini_model(model, img: Image.Image, prompt: str) -> tuple:
    """
    Try a single Gemini model.
    Handles BOTH response formats:
      - Multi-food: {"foods": [{"food_name": ..., "portion_percent": ...}, ...], "confidence": ...}
      - Single food: {"food_name": ..., "confidence": ...}  ← backward compatible

    Returns (foods_list, confidence) where foods_list is always a list.
    """
    response = model.generate_content([prompt, img])
    response_text = response.text.strip()
    response_text = re.sub(r'```json\s*', '', response_text)
    response_text = re.sub(r'```\s*', '', response_text)
    response_text = response_text.strip()
    gemini_data = json.loads(response_text)

    confidence = float(gemini_data.get("confidence", 50))

    # ── Multi-food format ──────────────────────────────────
    if "foods" in gemini_data and isinstance(gemini_data["foods"], list):
        foods = []
        for item in gemini_data["foods"]:
            name = item.get("food_name", "unknown food").lower().strip()
            pct  = float(item.get("portion_percent", 100.0 / len(gemini_data["foods"])))
            foods.append({"food_name": name, "portion_percent": pct})
        return foods, confidence

    # ── Single food format (backward compatible) ───────────
    food_name = gemini_data.get("food_name", "unknown food").lower().strip()
    return [{"food_name": food_name, "portion_percent": 100.0}], confidence


class FoodCNNClassifier:
    """
    Food classifier with multi-model fallback chain.

    Fallback order:
    1. gemini-2.5-flash      (20 req/day)
    2. gemini-2.5-flash-lite (1,500 req/day)
    3. gemini-2.0-flash-lite (1,500 req/day)
    4. Smart offline          (unlimited)

    v2 improvement: multi-label detection for complex plates.
    Single-food images work exactly as before.
    """

    def __init__(self):
        self.models = [
            ("gemini-2.5-flash",      genai.GenerativeModel('gemini-2.5-flash')),
            ("gemini-2.5-flash-lite", genai.GenerativeModel('gemini-2.5-flash-lite')),
            ("gemini-2.0-flash-lite", genai.GenerativeModel('gemini-2.0-flash-lite')),
        ]
        print("✅ Gemini Vision Food Classifier v2 ready! (Multi-label detection)")
        print(f"   Models: {[m[0] for m in self.models]}")

    def classify(self, image_bytes: bytes, filename: str = "") -> dict:
        """
        Classify food image using fallback chain.
        Returns combined nutrition for multi-component plates.
        Always returns a result — never fails completely.
        """
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')

        # ── PROMPT v2: Multi-label + Empty plate detection ──────────────
        prompt = """You are a food recognition expert for a nutrition tracking app.

STEP 1 — Check if the plate has actual food:
- If EMPTY, NEARLY EMPTY, or shows only RESIDUE/STAINS/SCRAPS with no real meal,
  return EXACTLY:
  {"foods": [{"food_name": "empty plate", "portion_percent": 100}], "confidence": 99}

STEP 2 — If real food is present, identify ALL visible food components:
- List every distinct food item you can see on the plate
- Estimate what percentage of the plate each item takes up (must sum to 100)
- Use simple common names: rice, chicken, broccoli, egg, salad, pizza, coffee

Return ONLY this JSON — no markdown, no backticks, no extra text:
{
    "foods": [
        {"food_name": "rice", "portion_percent": 50},
        {"food_name": "chicken", "portion_percent": 30},
        {"food_name": "broccoli", "portion_percent": 20}
    ],
    "confidence": 85
}

Rules:
- If only ONE food is visible, still use the foods array with one item at 100%
- If it is a drink (coffee, tea, water), return one item at 100%
- portion_percent values must sum to 100
- confidence is a number 0-100
"""
        # ───────────────────────────────────────────────────────────────

        foods = None
        confidence = 0.0
        model_used = "offline"

        for model_name, model in self.models:
            try:
                foods, confidence = try_gemini_model(model, img, prompt)
                model_used = model_name
                names = [f["food_name"] for f in foods]
                print(f"✅ {model_name}: {names} ({confidence}%)")
                break
            except Exception as err:
                err_str = str(err)
                if "429" in err_str or "quota" in err_str.lower():
                    print(f"⚠️ {model_name} quota exceeded — trying next model...")
                    continue
                else:
                    print(f"⚠️ {model_name} error: {err_str[:80]}")
                    continue

        # All Gemini models failed — use offline fallback
        if foods is None:
            print("🔄 All Gemini models exhausted — using offline fallback")
            food_name, confidence = offline_classify(img, filename)
            foods = [{"food_name": food_name, "portion_percent": 100.0}]
            model_used = "offline"

        # Check if any food in list is unknown/empty
        primary_name = foods[0]["food_name"] if foods else "unknown food"
        if primary_name in ("unknown food", "unknown_food"):
            print("🔄 Unknown food — using offline fallback")
            food_name, confidence = offline_classify(img, filename)
            foods = [{"food_name": food_name, "portion_percent": 100.0}]
            model_used = "offline"

        # Combine nutrition across all detected foods
        nutrition = combine_nutrition(foods)
        calories, carbs, protein, fiber, fat, friendly_name = nutrition
        low_confidence = confidence < 50

        # Build top_predictions list from all detected foods
        top_predictions = [
            {
                "label": f["food_name"],
                "confidence": round(confidence * f["portion_percent"] / 100, 1)
            }
            for f in foods
        ]

        print(f"🍽️ Final: {friendly_name} | "
              f"carbs={carbs}g protein={protein}g "
              f"({confidence}% via {model_used})")

        return {
            "food_name": friendly_name,
            "raw_label": primary_name,
            "confidence": round(confidence, 1),
            "low_confidence": low_confidence,
            "calories": calories,
            "carbs": carbs,
            "protein": protein,
            "fiber": fiber,
            "fat": fat,
            "top_predictions": top_predictions,
            "all_labels": [f["food_name"] for f in foods],
            "model_used": model_used
        }


# Singleton instance
food_classifier = FoodCNNClassifier()