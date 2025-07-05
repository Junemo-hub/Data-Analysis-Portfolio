https://www.kaggle.com/datasets/snap/amazon-fine-food-reviews
# 🛍️ Sentiment Analysis on Amazon Fine Food Reviews

## 📌 Project Overview
This project builds a binary text classification model that predicts sentiment (positive or negative) from Amazon Fine Food product reviews.  
It includes a complete pipeline from data preprocessing to model training, evaluation, comparison, and visualization.

---

## 📂 Dataset  
- Source: [Kaggle - Amazon Fine Food Reviews](https://www.kaggle.com/datasets/snap/amazon-fine-food-reviews)  
- ~568,000 total reviews  
- Labeling logic:
  - Score 1–2 → Negative (0)
  - Score 4–5 → Positive (1)
  - Score 3 is excluded from training

---

## 🧹 Preprocessing & Vectorization
- Cleaned review text: lowercased, removed punctuation/numbers, filtered stopwords (`src/preprocessing.py`)
- Vectorization via `TfidfVectorizer(max_features=5000, ngram_range=(1,1) or (1,2))`
- Separate vectorizer saved for each model to preserve reproducibility

---

## 🤖 Models Used
- **Multinomial Naive Bayes**
- **Logistic Regression** (with optional `class_weight='balanced'`)
- **Random Forest Classifier** (with `class_weight='balanced'`)

---

## 📊 Evaluation
- Metrics:
  - Confusion Matrix
  - Precision, Recall, F1-score
  - ROC AUC Score
- Implemented via `evaluate_model()` in `src/evaluation.py`  
  → Includes automatic visualization

---

## 📈 Performance Comparison (on Negative Class)

| Model                  | Accuracy | Recall (0) | F1 (0) | AUC   |
|------------------------|----------|------------|--------|-------|
| Naive Bayes            | 0.88     | 0.27       | 0.42   | 0.937 |
| Logistic Regression    | 0.93     | 0.67       | 0.75   | 0.957 |
| Logistic + Balanced    | 0.91     | **0.81**   | **0.80** | 0.954 |
| Random Forest + Balanced | 0.92   | 0.78       | 0.77   | 0.955 |

---

## 📁 Project Structure

project/
├── data/ # Original and preprocessed data
├── notebooks/ # Jupyter notebooks for analysis
│ ├── 1_data_eda.ipynb
│ ├── 2_modeling_nb_lr.ipynb
│ ├── 3_modeling_rf.ipynb
│ ├── 5_evaluation_summary.ipynb
│ └── 6_inspect_model.ipynb (optional)
├── outputs/
│ ├── models/ # Trained model .pkl files
│ ├── vectorizers/ # Matched TF-IDF vectorizers
│ └── reports/ # Evaluation plots, confusion matrices, etc.
├── src/
│ ├── preprocessing.py
│ ├── model.py
│ ├── evaluation.py
├── requirements.txt
└── README.md


---

## ✅ Conclusion
- Logistic Regression (with class balancing) performed best in detecting negative sentiment.
- Naive Bayes is fast but weak at identifying rare (negative) cases.
- Random Forest is well-balanced but slower to train.

---

## 🎯 Key Takeaways
- How to handle class imbalance in NLP with `class_weight`
- Importance of structured preprocessing and vectorization
- How to compare multiple models and visualize results with one pipeline

---

## 🔁 Possible Extensions
- Threshold tuning experiments (e.g., using `predict_proba()`)
- SMOTE / undersampling comparison
- Try neural models like BERT for further performance gain
