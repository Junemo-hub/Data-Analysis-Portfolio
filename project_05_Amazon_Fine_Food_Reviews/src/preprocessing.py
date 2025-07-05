# src/preprocessing.py

import pandas as pd
import re
import string

def clean_text(text):
    """
    텍스트를 전처리하는 함수: 소문자화, 특수문자 제거 등
    """
    text = text.lower()
    text = re.sub(r'\d+', '', text)  # 숫자 제거
    text = text.translate(str.maketrans('', '', string.punctuation))  # 구두점 제거
    text = re.sub(r'\s+', ' ', text).strip()  # 공백 정리
    return text

def preprocess_dataframe(df):
    """
    - Score 3 제거
    - Score 1-2 → 0, 4-5 → 1 이진화
    - 텍스트 클린업 적용
    """
    df = df[df['Score'] != 3].copy()
    df['Sentiment'] = df['Score'].apply(lambda x: 1 if x > 3 else 0)
    df['Text'] = df['Text'].astype(str).apply(clean_text)
    return df

