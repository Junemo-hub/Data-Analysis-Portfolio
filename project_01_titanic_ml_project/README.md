# 🛳️ Titanic Survival Prediction (Kaggle)

A machine learning project for predicting passenger survival on the Titanic using structured data from the [Kaggle Titanic competition](https://www.kaggle.com/competitions/titanic).

---

## 📁 Project Structure

```
project_01_titanic_ml_project/
├── data/
│   ├── train.csv
│   ├── test.csv
│   └── gender_submission.csv
│
├── outputs/
│   ├── clean_train.csv
│   ├── clean_test.csv
│   └── submission.csv
│
├── notebooks/
│   ├── 01_eda_titanic.ipynb
│   ├── 02_preprocessing.ipynb
│   ├── 03_model_training.ipynb
│   ├── 04_test_preprocessing.ipynb
│   └── 05_submission_generator.ipynb
│
├── scripts/
│   └── preprocessing.py
│
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
