# model/preprocess.py   file

import pandas as pd
import re
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences

def clean_text(text):
    text = re.sub(r'[^a-zA-Z0-9\s]', '', text)
    text = text.lower()
    return text

def prepare_data_for_training(csv_file, max_words=10000, max_sequence_length=100):
    df = pd.read_csv(csv_file)
    df['CleanedName'] = df['Name'].apply(clean_text)
    
    tokenizer = Tokenizer(num_words=max_words)
    tokenizer.fit_on_texts(df['CleanedName'])
    
    sequences = tokenizer.texts_to_sequences(df['CleanedName'])
    padded_sequences = pad_sequences(sequences, maxlen=max_sequence_length, padding='post')
    
    return padded_sequences, df, tokenizer

if __name__ == "__main__":
    X_train, df, tokenizer = prepare_data_for_training('../data/recipes.csv')
    # Save tokenizer for later use
    with open('model/tokenizer.json', 'w') as f:
        f.write(tokenizer.to_json())
