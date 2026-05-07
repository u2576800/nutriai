# NutriAI - Project Wireframe & Blueprint Documentation

## Project Overview
A full-stack Explainable AI system for personalized nutrition recommendations using:
- Food image recognition (CNN)
- Machine learning glucose prediction (Random Forest)
- Explainability analysis (SHAP)
- LLM-based clinical insights (Google Gemini)
- Secure encrypted data storage

---

## 1. SYSTEM ARCHITECTURE DIAGRAM

### Layers:
1. **Frontend Layer** (React 18 + Vite)
   - Login Component
   - Onboarding Component
   - Premium Dashboard (Main UI)
   - Patient History Timeline
   - Image Upload Interface
   - Manual Entry Form
   - Header/Footer Navigation

2. **Backend Layer** (FastAPI + Uvicorn)
   - 3 REST API Endpoints
   - Input Validation
   - Drink Detection Filter

3. **ML/AI Layer**
   - CNN Food Classifier (Gemini Vision Multi-model Fallback)
   - Random Forest Model (Glucose Prediction)
   - SHAP Explainer (Feature Attribution)
   - Google Gemini LLM (Clinical Advice)

4. **Data Layer**
   - SQLite Database (Encrypted)
   - JSON Cache
   - Patient Profiles CSV
   - Nutrition Database (75+ foods)

5. **Security Layer**
   - Fernet Encryption (At-Rest)
   - CORS Configuration
   - Environment Variables (API Keys)

---

## 2. USER FLOW & NAVIGATION

### Entry Point
1. **Login Page**
   - Enter Patient ID
   - Select Microbiome Type
   - Authenticate

### First-Time User
   ↓
2. **Onboarding Page**
   - Tutorial Guide
   - System Usage Explanation
   - Privacy Information

### Main Interface
   ↓
3. **Premium Dashboard** (Central Hub)
   - Choose Input Method:
     - Option A: Upload Food Image
     - Option B: Manual Meal Entry

### Option A: Image Upload Path
   ↓
4. **Image Upload Interface**
   - Select Image File
   - Live Preview
   - Adjust Portion Size (100-500g slider)
   - Analyze Food

   ↓
5. **CNN Results**
   - Detected Food Name
   - Confidence Score %
   - Nutritional Facts
   - Edit/Confirm Option

### Option B: Manual Entry Path
   ↓
4. **Manual Form**
   - Input Carbohydrates (0-300g)
   - Input Protein (0-100g)
   - Input Fiber (0-50g)
   - Input Calories (0-2000 kcal)

### Convergence Point
   ↓
6. **Processing State**
   - Random Forest Prediction
   - SHAP Analysis
   - LLM Generation
   - Loading Indicator

### Results Display
   ↓
7. **Results Page**
   - **Predicted Glucose Spike** (Large, highlighted)
   - **SHAP Waterfall Chart** (Visual explanation)
   - **Clinical Insight** (LLM-generated)
   - **Action Plan** (Specific recommendation)
   - Save to History Button

### Follow-up Actions
   ↓
8. **Options**
   - Log Another Meal → Return to Dashboard
   - View Full History → Patient History Timeline
   - Settings → Adjust Preferences

### History & Analytics
   ↓
9. **Patient History Page**
   - Timeline of all predictions
   - Glucose response trends
   - Dietary patterns analysis
   - Export data option

---

## 3. FRONTEND UI COMPONENT LAYOUT

### Premium Dashboard Structure

```
╔════════════════════════════════════════════════════════════╗
║  🎯 NUTRI-AI | Patient: [ID] | Microbiome: [Type] ⚙️ 📋  ║
╠════════════════════════════════════════════════════════════╣
║                       INPUT SECTION                        ║
║  ┌─────────────────────────────────────────────────────┐  ║
║  │ 📷 IMAGE UPLOAD          📝 MANUAL ENTRY   🔄 SWITCH │  ║
║  └─────────────────────────────────────────────────────┘  ║
║                                                            ║
║  ┌─────────────────────────────────────────────────────┐  ║
║  │ ACTIVE INPUT PANEL (Image OR Manual)                │  ║
║  │                                                     │  ║
║  │ [Upload Preview] [Portion Slider] [Analyze →]      │  ║
║  │         OR                                          │  ║
║  │ [Carbs: __] [Protein: __] [Fiber: __] [Cal: __]    │  ║
║  │                         [Predict →]                │  ║
║  └─────────────────────────────────────────────────────┘  ║
║                                                            ║
║                     RESULTS SECTION                        ║
║  ┌─────────────────────────────────────────────────────┐  ║
║  │ ⏱️ Processing... (or Results if ready)              │  ║
║  │                                                     │  ║
║  │ 🔴 GLUCOSE SPIKE: 28 mg/dL                          │  ║
║  │                                                     │  ║
║  │ ┌───────────────────────────────────────────────┐  │  ║
║  │ │ 📊 SHAP Waterfall Chart (Visual)              │  │  ║
║  │ │ [Feature Importance Visualization]            │  │  ║
║  │ └───────────────────────────────────────────────┘  │  ║
║  │                                                     │  ║
║  │ 💡 Clinical Insight:                               │  ║
║  │ Your apple contains moderate carbs (21g) with      │  ║
║  │ beneficial fiber, driving a moderate glucose      │  ║
║  │ response in your microbiome profile.               │  ║
║  │                                                     │  ║
║  │ ✅ Action Plan:                                    │  ║
║  │ Take a 10-minute walk after meals to reduce       │  ║
║  │ blood glucose spikes by 15%.                       │  ║
║  │                                                     │  ║
║  │ [Save to History] [Log Another] [View Trends →]   │  ║
║  └─────────────────────────────────────────────────────┘  ║
║                                                            ║
║              RECENT HISTORY (Last 5 Meals)                 ║
║  ┌─────────────────────────────────────────────────────┐  ║
║  │ 🍎 Apple (150g) → 28 mg/dL  [3 hours ago]          │  ║
║  │ 🥗 Salad (200g) → 15 mg/dL  [8 hours ago]          │  ║
║  │ 🍝 Pasta (250g) → 42 mg/dL  [Yesterday]            │  ║
║  │ 📊 View Full History →                             │  ║
║  └─────────────────────────────────────────────────────┘  ║
╠════════════════════════════════════════════════════════════╣
║  Help | Privacy | About | Logout                          ║
╚════════════════════════════════════════════════════════════╝
```

---

## 4. BACKEND API PIPELINE

### Three Main Endpoints:

#### **Endpoint 1: Manual Prediction**
```
POST /api/predict
Input: {
  patient_id: int,
  microbiome_type: str,
  carbs: float,
  fiber: float,
  protein: float,
  calories: float
}
Process: Validation → RF Prediction → SHAP Analysis → LLM Advice → Database
Output: {
  status: "success",
  predicted_spike: float,
  shap_image_base64: str,
  ai_advice: str
}
```

#### **Endpoint 2: Food Image Analysis**
```
POST /api/analyse-food-image
Input: Image File (JPEG/PNG)
Process: Validate → CNN Classification (4-fallback chain) → Nutrition Lookup
Output: {
  food_name: str,
  confidence: int,
  nutrition_per_100g: {calories, carbs, protein, fiber, fat}
}
```

#### **Endpoint 3: Full Image Pipeline**
```
POST /api/predict-from-image
Input: Image File + patient_id + microbiome_type + portion_grams
Process: CNN → Nutrition Scale → RF Prediction → SHAP → LLM → Database
Output: Complete prediction with all visualizations
```

### Request/Response Flow:

```
1. REQUEST PHASE
   ├─ Frontend sends HTTP request
   ├─ CORS validation
   └─ Pydantic validation & parsing

2. PROCESSING PHASE
   ├─ Drink detection filter
   ├─ If drink: Return 1 mg/dL spike
   ├─ If meal:
   │  ├─ Get patient profile
   │  ├─ Random Forest prediction
   │  ├─ SHAP value calculation
   │  └─ Generate waterfall visualization

3. LLM PHASE
   ├─ Create clinical prompt
   ├─ Call Google Gemini API
   ├─ If success: Generate advice
   └─ If failed: Rule-based fallback

4. PERSISTENCE PHASE
   ├─ Encrypt data (Fernet)
   ├─ Save to SQLite
   └─ Save to JSON cache

5. RESPONSE PHASE
   ├─ Format JSON response
   ├─ Include base64 SHAP image
   └─ Send to frontend
```

---

## 5. DATA FLOW: IMAGE TO PREDICTION (Complete Pipeline)

```
User Upload Image
    ↓
Frontend: FormData preparation
    ↓
POST /api/analyse-food-image
    ↓
CNN Classifier (Multi-model Fallback):
├─ Attempt 1: Gemini 2.5 Flash (20/day)
├─ Attempt 2: Gemini 1.5 Flash (1500/day)
├─ Attempt 3: Gemini 1.5 Flash-8B (1500/day)
└─ Attempt 4: Offline detection
    ↓
Food Detected: "Apple"
Confidence: 95%
    ↓
Nutrition DB Lookup:
├─ Calories: 52
├─ Carbs: 14g
├─ Protein: 0.3g
├─ Fiber: 2.4g
└─ Fat: 0.2g
    ↓
User confirms portion: 150g
    ↓
Scale nutrition (1.5x):
├─ Calories: 78
├─ Carbs: 21g
├─ Protein: 0.45g
├─ Fiber: 3.6g
└─ Fat: 0.3g
    ↓
POST /api/predict-from-image
    ↓
DRINK CHECK: Carbs≤1 & Cal≤15 & Protein≤1?
├─ YES → 1 mg/dL spike (minimal)
└─ NO → Continue
    ↓
Get Patient Profile from CSV
    ↓
Random Forest Input:
[Carbs, Protein, Fiber, Calories, PatientData]
    ↓
RF Model Prediction: 28 mg/dL spike
    ↓
SHAP Analysis:
├─ Carbs: +18 mg/dL contribution
├─ Fiber: -5 mg/dL contribution
└─ Protein: +3 mg/dL contribution
    ↓
Generate Waterfall Plot (PNG)
    ↓
Create LLM Prompt with:
├─ Food name
├─ Macronutrients
├─ Spike magnitude
└─ Microbiome profile
    ↓
Google Gemini API
    ↓
Generate Clinical Insight + Action Plan
    ↓
Database Operations:
├─ Encrypt all data
├─ Save to SQLite
└─ Save to JSON cache
    ↓
Return JSON Response:
{
  status: "success",
  spike: 28,
  shap_image: base64_encoded_png,
  clinical_insight: "...",
  action_plan: "..."
}
    ↓
Frontend renders all results
    ↓
Display to user
```

---

## 6. SECURITY & DATA FLOW

### Encryption:
- **At-Rest**: Fernet symmetric encryption
- **In-Transit**: HTTPS (production)
- **API Keys**: Environment variables (.env)

### Database Strategy:
- **Primary**: SQLite (encrypted persistent storage)
- **Secondary**: JSON cache (session-based, encrypted)
- **Dual storage** ensures high availability

### CORS Protection:
- Allowed origins: localhost:3000, localhost:5173 (dev)
- Production: Updated to actual domain

---

## 7. KEY FEATURES

### Microbiome Integration
- User-specified microbiome profile (Firmicutes, Bacteroides, Dysbiotic, etc.)
- Incorporated into RF model features
- Used in LLM prompt for personalized advice

### Portion Flexibility
- Adjustable portion size (100-500g)
- Automatic nutrition scaling
- Accurate glucose predictions for real-world meals

### Resilience & Fallbacks
- CNN: 4-step fallback chain
- LLM: Rule-based fallback if API unavailable
- Safe indexing: Modulo-based patient record retrieval
- Error handling at all external API points

### Clinical Context
- Every recommendation linked to specific data
- Feature contributions visible via SHAP
- Microbiome profile explicitly referenced
- Actionable, evidence-based advice

---

## 8. COMPONENT RELATIONSHIPS

```
React Components:
├─ Login.jsx
│  └─ Validates patient & session
├─ Onboarding.jsx
│  └─ First-time user guide
├─ PremiumDashboard.jsx (Main Hub)
│  ├─ Image Upload Section
│  ├─ Manual Entry Section
│  ├─ Results Display Section
│  └─ Recent History Display
├─ PatientHistory.jsx
│  └─ Timeline & trends
├─ Header.jsx
│  └─ Navigation & profile
├─ Footer.jsx
│  └─ Links & support
└─ ConnectionTest.jsx
   └─ Backend connectivity check

FastAPI Routes:
├─ POST /api/test-connection
├─ POST /api/predict
├─ POST /api/analyse-food-image
└─ POST /api/predict-from-image

ML Models:
├─ Random Forest (glucose_rf_model.pkl)
├─ SHAP TreeExplainer
├─ CNN (Gemini Vision)
└─ LLM (Gemini 2.5)

Data Sources:
├─ patient_profiles.csv
├─ history.db (SQLite)
├─ clinical_history.json
└─ Nutrition database (embedded)
```

---

## 9. TECHNOLOGY STACK SUMMARY

| Layer | Technology |
|-------|-----------|
| **Frontend** | React 18, Vite, CSS Modules |
| **Backend** | FastAPI, Uvicorn, Python |
| **ML/Prediction** | Scikit-learn (Random Forest) |
| **Explainability** | SHAP, Matplotlib |
| **Vision/CNN** | Google Gemini Vision API |
| **LLM** | Google Gemini 2.5 Flash |
| **Database** | SQLite, JSON |
| **Security** | Fernet Encryption, CORS |
| **Environment** | Python .venv, npm packages |

---

## 10. DEPLOYMENT ARCHITECTURE

```
Production:
├─ Frontend
│  ├─ Built with Vite
│  ├─ Deployed to static hosting (Vercel/Netlify)
│  └─ HTTPS enabled
├─ Backend
│  ├─ FastAPI + Gunicorn/Uvicorn
│  ├─ Docker containerized
│  └─ Deployed to cloud (AWS/GCP/Azure)
├─ Database
│  ├─ SQLite → PostgreSQL (production)
│  └─ Encrypted backups
└─ External APIs
   ├─ Google Gemini (Vision + LLM)
   └─ Rate limiting & quota management
```

---

## Summary

This NutriAI system integrates **5 distinct AI technologies**:
1. **Computer Vision** (food recognition)
2. **Ensemble Learning** (glucose prediction)
3. **Explainability** (SHAP visualization)
4. **Large Language Models** (clinical advice)
5. **Secure Data Management** (encryption)

All components work seamlessly together to provide transparent, trustworthy, personalized nutrition recommendations backed by data science and clinical context.
