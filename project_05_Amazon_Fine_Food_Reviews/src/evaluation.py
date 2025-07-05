# src/evaluation.py

import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

def evaluate_model(name, model, X_test, y_test, print_report=True, plot_confusion=True):
    """
    모델 평가 함수 (분류 리포트, confusion matrix, ROC AUC)

    Parameters:
    - name (str): 모델 이름 (시각화/출력용)
    - model: 학습된 모델
    - X_test, y_test: 테스트 데이터
    - print_report (bool): classification_report 출력 여부
    - plot_confusion (bool): confusion matrix 시각화 여부
    """

    y_pred = model.predict(X_test)

    if print_report:
        print(f"\n==== {name} ====")
        print(classification_report(y_test, y_pred))

    try:
        y_proba = model.predict_proba(X_test)[:,1]
        auc = roc_auc_score(y_test, y_proba)
        print(f"ROC AUC: {auc:.4f}")
    except:
        print("ROC AUC 계산 불가 (probability 없음)")

    if plot_confusion:
        cm = confusion_matrix(y_test, y_pred)
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                    xticklabels=['Negative', 'Positive'],
                    yticklabels=['Negative', 'Positive'])
        plt.title(f'{name} - Confusion Matrix')
        plt.xlabel('Predicted')
        plt.ylabel('Actual')
        plt.show()
