https://www.kaggle.com/datasets/fedesoriano/the-boston-houseprice-data

# 🏠 Boston Housing Price Prediction

This project explores housing prices in Boston using various regression models, aiming to evaluate model performance and improve interpretability. The pipeline covers everything from exploratory data analysis and preprocessing to model training, evaluation, and interpretation with SHAP and LIME.

---

## 📁 Project Structure

| Notebook/File | Description |
|---------------|-------------|
| `01_eda.ipynb` | Exploratory data analysis (EDA) and basic visualizations |
| `02_preprocessing.ipynb` | Data cleaning, scaling, and export of processed data (`.pkl`) |
| `03a~03d_modeling_*.ipynb` | Model training: Linear, Ridge, Lasso, and Random Forest |
| `04a~04e_post_model_analysis.ipynb` | Model evaluation, metrics, and prediction plots |
| `05_feature_analysis.ipynb` | Comparing feature importance across models |
| `06_summary_report.md` | Written summary of findings and model comparisons |
| `07_shap_analysis.ipynb` | Model interpretability using SHAP (global & local) |
| `08_lime_analysis.ipynb` | Local explanation of predictions using LIME |

---

## 🛠 Tech Stack

- Python 3.12+
- pandas, numpy, scikit-learn
- matplotlib, seaborn
- SHAP, LIME

---

## 🧠 Summary

- **Objective:** Compare multiple regression models on Boston housing price prediction
- **Best model:** Random Forest (RMSE ≈ 2.81, R² ≈ 0.89)
- **Key features:** `RM` (avg. number of rooms), `LSTAT` (lower-income %)
- **Interpretability:** SHAP and LIME were used to explain both global and local predictions

---

## ✅ How to Run

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run notebooks in sequence:
```
01 → 02 → 03x → 04x → 05~08
```

---

## 📌 Notes

- Dataset: [Kaggle - Boston Houseprice Data](https://www.kaggle.com/datasets/fedesoriano/the-boston-houseprice-data)
- Preprocessed data and models are saved using `.pkl` for easy reuse
- SHAP and LIME are optional, but highly recommended for interpretability

---

## 📈 Potential Extensions

- Add polynomial or interaction features  
- Deploy a basic dashboard (e.g. Streamlit)  
- Tune hyperparameters with cross-validation  
- Explore fairness, residual analysis, or outlier detection

---

Thanks for checking this out! If you’re building a portfolio or preparing for interviews, this project covers both predictive performance and explainability — a strong combination for real-world ML work.
