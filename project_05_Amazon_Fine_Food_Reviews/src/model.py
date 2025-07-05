# src/model.py

import joblib
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import MultinomialNB
from sklearn.ensemble import RandomForestClassifier

def train_model(X_train, y_train, model_type='logistic', class_weight=None, n_estimators=100):
    """
    모델 훈련 함수

    Parameters:
    - X_train, y_train: 학습 데이터
    - model_type: 'logistic', 'nb', 'rf' 중 선택
    - class_weight: None 또는 'balanced' (logistic, rf만 사용)

    Returns:
    - 학습된 모델 객체
    """
    if model_type == 'logistic':
        model = LogisticRegression(max_iter=1000, class_weight=class_weight)
    elif model_type == 'nb':
        model = MultinomialNB()
    elif model_type == 'rf':
        model = RandomForestClassifier(n_estimators=100, class_weight=class_weight)
    else:
        raise ValueError("지원하지 않는 모델입니다: logistic, nb, rf 중 선택하세요.")

    model.fit(X_train, y_train)
    return model

def save_model(model, path):
    joblib.dump(model, path)

def load_model(path):
    return joblib.load(path)
