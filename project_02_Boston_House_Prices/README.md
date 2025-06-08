https://www.kaggle.com/datasets/fedesoriano/the-boston-houseprice-data

# 🏠 Boston Housing Price Prediction Project

This project focuses on predicting housing prices in Boston using multiple regression models. It includes the full pipeline from EDA and preprocessing to modeling, evaluation, and interpretability using SHAP and LIME.

---

## 📁 Project Structure & File Descriptions

| File / Notebook | Description |
|------------------|-------------|
| `01_eda.ipynb` | Exploratory Data Analysis and visualization |
| `02_preprocessing.ipynb` | Data cleaning, feature scaling, train-test split, and `.pkl` export |
| `03a~03d_modeling_*.ipynb` | Model training for Linear, Ridge, Lasso, and Random Forest |
| `04a~04e_post_model_analysis.ipynb` | Performance evaluation and actual vs predicted plots |
| `05_feature_analysis.ipynb` | Feature importance and coefficient comparison |
| `06_summary_report.md` | Summary report of the entire project |
| `07_shap_analysis.ipynb` | Model interpretability with SHAP (global & local) |
| `08_lime_analysis.ipynb` | Sample-level explanation with LIME |

---

## 🛠 Technologies Used
- Python 3.12+
- pandas, numpy, scikit-learn
- matplotlib, seaborn
- SHAP, LIME

---

## 🧠 Project Goals & Summary

- Evaluate and compare multiple regression models
  - Random Forest yielded the best performance (RMSE ≈ 2.81, R² ≈ 0.89)
- Feature importance analysis identified key drivers: `RM` (rooms), `LSTAT` (lower-income %)
- Interpret model predictions using SHAP and LIME for explainability

---

## ✅ How to Run

1. Install required packages:
```bash
pip install -r requirements.txt  # or install individually
```
2. Follow notebook sequence: `01 → 02 → 03x → 04x → 05~08`

---

## 📌 Notes

- Dataset: `boston.csv` or sklearn's built-in Boston dataset (depending on context)
- `.pkl` files are used to save and reuse preprocessed data and trained models
- SHAP and LIME are optional but recommended for interpretable ML

---

## 🙋‍♂️ Suggestions & Next Steps

- Interpretation is just as important as prediction performance
- This project is suitable as a pre-master’s level portfolio or practical case study
- Possible extensions:
  - Build a Streamlit dashboard
  - Add polynomial features, interaction terms, log transformation
  - Improve hyperparameter tuning and cross-validation

---

Thanks for reading!
