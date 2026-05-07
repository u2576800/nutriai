# 🧬 NutriAI: Personalised Nutrition using XAI and Gut-Microbiome Data

**NutriAI** is a full-stack, AI-driven web application designed to move dietary guidance beyond generic "one-size-fits-all" population averages. By integrating machine learning, Explainable AI (XAI), and gut microbiome profiles, NutriAI predicts individual postprandial blood glucose spikes and provides transparent, actionable clinical advice.

*This project was developed as part of a BSc (Hons) Computer Science Final Year Dissertation.*

---

## ✨ Key Features

* **Microbiome-Driven Predictions:** Utilises a Random Forest Regressor trained on the PhysioNet CGMacros dataset, incorporating 1,986 gut enterotype features to predict highly individualised glucose spikes.
* **Explainable AI (XAI):** Integrates SHAP (SHapley Additive exPlanations) via `TreeExplainer` to generate per-prediction waterfall plots, ensuring every glucose prediction is transparent and medically interpretable.
* **Smart Food Vision:** Employs a CNN pipeline powered by Google Gemini 2.5 Flash Vision for multi-label food detection, including complex plate analysis, empty plate rejection, and zero-carb drink bypass logic.
* **Personalised Clinical Advice:** Uses Large Language Models (LLM) to generate enterotype-specific dietary recommendations based on the precise predicted glucose spike.
* **Full-Stack Dashboard:** A modern, responsive React 18 interface featuring user onboarding, real-time prediction gauges, and a 7-meal glucose trend history with CSV export.

---

## 🛠️ Technology Stack

**Backend / Machine Learning**
* Python 3.11
* FastAPI & Uvicorn (REST API)
* scikit-learn (Random Forest Regressor)
* SHAP (TreeExplainer)
* pandas, NumPy, joblib
* Google Gemini API (2.5 Flash / Vision / Flash Lite)
* Fernet (Symmetric Encryption for clinical history)

**Frontend**
* React 18 + Vite
* CSS Modules & Recharts
* React Router

---

## 🚀 Getting Started

Follow these instructions to run the NutriAI project locally on your machine.

### Prerequisites
* Python 3.11+
* Node.js (v18+)
* A Google Gemini API Key

### 1. Clone the Repository
```bash
git clone [https://github.com/u2576800/NutriAI.git](https://github.com/u2576800/NutriAI.git)
cd NutriAI

****2. Backend Setup****
python -m venv .venv
# On Windows:
.venv\Scripts\activate
# On Mac/Linux:
source .venv/bin/activate

pip install -r requirements.txt

***Start the FastAPI server:******
uvicorn main:app --reload

********Frontend Setup********
cd frontend
npm install
npm run dev

******Disclaimer******
NutriAI is a university research prototype. The AI-generated clinical advice and glucose predictions are generated for educational and research purposes using a simulated/augmented dataset. This application should not be used to replace professional medical advice, diagnosis, or treatment.

Author: Zoya Shaikh
Institution: University of East London
Year: 2026
