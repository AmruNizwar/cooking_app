# model/preprocess.py   file

import os
import pandas as pd
import numpy as np
import re
import json
from sklearn.model_selection import train_test_split
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
from tensorflow.keras.utils import to_categorical
from sklearn.preprocessing import LabelEncoder

def clean_text(text):
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)
    return text

def prepare_data_for_training(csv_filepath, max_words=10000, max_sequence_length=100, test_size=0.2):
    df = pd.read_csv(csv_filepath)
    df['CleanedName'] = df['Name'].apply(clean_text)
    tokenizer = Tokenizer(num_words=max_words, oov_token="<OOV>")
    tokenizer.fit_on_texts(df['CleanedName'])
    sequences = tokenizer.texts_to_sequences(df['CleanedName'])
    X = pad_sequences(sequences, maxlen=max_sequence_length, padding='post', truncating='post')

    y = None
    label_encoder = None

    if 'Intent' in df.columns:
        label_encoder = LabelEncoder()
        y = label_encoder.fit_transform(df['Intent'])
        y = to_categorical(y)
    
    return X, y, df, tokenizer, label_encoder


def save_tokenizer(tokenizer, filepath):
    with open(filepath, 'w') as file:
        json.dump(tokenizer.to_json(), file)

def load_tokenizer(filepath):
    with open(filepath, 'r') as file:
        tokenizer_json = json.load(file)
    return tokenizer_json
