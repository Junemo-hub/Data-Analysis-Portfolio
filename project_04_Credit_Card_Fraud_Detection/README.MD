https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud

# 💳 Credit Card Fraud Detection

This project aims to detect fraudulent credit card transactions using a variety of classification models on highly imbalanced data. It covers data preprocessing, feature engineering, multiple model training, SMOTE-based resampling, evaluation, and visualization.

---

## 📁 Project Structure
```
notebooks/
├── 01_eda.ipynb # Exploratory Data Analysis
├── 02_feature_eng.ipynb # Feature Engineering
├── 03a_logistic.ipynb # Logistic Regression
├── 03b_tree.ipynb # Random Forest
├── 03c_boosting.ipynb # LightGBM
├── 03d_sampling.ipynb # SMOTE & Sampling Experiments
├── 04_evaluation.ipynb # Performance Evaluation & Comparison
├── 05_visualization.ipynb # ROC, PR Curves & Metric Visuals
outputs/ # Saved .pkl models & test sets
```

---

### 📊 Dataset Info
- `Time`: Seconds elapsed since first transaction in dataset
- `V1` to `V28`: PCA-transformed anonymized features
- `Amount`: Transaction amount
- `Class`: Fraud label (0 = normal, 1 = fraud)

---

## 🧪 Models Compared

| Model         | Recall | Precision | F1   | AUC    |
|---------------|--------|-----------|------|--------|
| Logistic      | 0.92   | 0.06      | 0.11 | 0.972  |
| Lasso         | 0.02   | 0.02      | 0.02 | 0.511  |
| Random Forest | 0.74   | 0.96      | 0.84 | 0.953  |
| LightGBM      | 0.87   | 0.82      | 0.84 | 0.977  |
| LGBM+SMOTE    | 0.89   | 0.50      | 0.64 | 0.969  |



Precision-Recall curves are included, as they provide more informative evaluation than ROC curves under heavy class imbalance.

---

## 🧠 Key Insights

- **LightGBM** shows the best overall performance and class balance.
- **Random Forest** yields the highest precision with low false positives.
- **LGBM + SMOTE** improves recall for high-risk applications, but with more false positives.
- **Logistic** and **Lasso** models are less practical due to imbalance sensitivity.

- **Lasso** failed to generalize due to extreme regularization on sparse, imbalanced data.

---

## ⚙️ Technologies Used

- Python, Jupyter Notebook
- Scikit-learn, LightGBM, imbalanced-learn
- Matplotlib, Seaborn
- Joblib for model serialization

---

## ✅ How to Run

```bash
# Step 1: Install requirements
pip install -r requirements.txt

# Step 2: Run notebooks in order
01_eda.ipynb → 05_visualization.ipynb

# Step 3: View final results in 04_evaluation and 05_visualization


📌 Author Notes
All models were evaluated on the same untouched test set.

Precision-Recall tradeoff curves are included for model selection.

SMOTE was applied only to training data.

📬 Contact
For feedback or collaboration, please open an issue or contact me directly!
---