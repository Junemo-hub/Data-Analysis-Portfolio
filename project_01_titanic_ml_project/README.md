# 🛳️ Titanic Survival Prediction (Kaggle)

A machine learning project for predicting passenger survival on the Titanic using structured data from the [Kaggle Titanic competition](https://www.kaggle.com/competitions/titanic).

---

## 📁 Project Structure

```
├── data/ # Original data files from Kaggle
│ ├── train.csv
│ ├── test.csv
│ └── gender_submission.csv
├── outputs/ # Processed files and submission
│ ├── clean_train.csv
│ ├── clean_test.csv
│ └── submission.csv
├── notebooks/
│ ├── 03_model_training.ipynb
│ └── 05_submission_generator.ipynb
├── scripts/
│ └── preprocessing.py
└── README.md
```


---

## ✅ Workflow Summary

1. **EDA**: Basic data exploration using `train.csv`
2. **Preprocessing**: Cleaned missing values, encoded categorical variables, added engineered features (`FamilySize`, `IsAlone`)
3. **Modeling**: RandomForestClassifier
4. **Prediction**: Generated `submission.csv` for Kaggle
5. **Score**: 🎯 `0.75119` (Public LB)

---

## 🧠 Key Features Used

- `Pclass`, `Sex`, `Age`, `SibSp`, `Parch`, `Fare`
- Engineered: `FamilySize`, `IsAlone`
- Encoded: `Sex`, `Embarked`

---

## 🚀 Submission Format

```csv
PassengerId,Survived
892,0
893,1
...
