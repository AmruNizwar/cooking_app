import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.utils import to_categorical
import pickle
import json

# Load preprocessed data
with open("../backend/models/data.pickle", "rb") as f:
    data = pickle.load(f)
    words = data['words']
    word_indices = data['word_indices']

# Example dummy data (replace with real data)
X = np.random.rand(100, len(words))  # Random feature vectors, replace with real features
y = np.random.randint(0, 2, 100)  # Random binary labels, replace with real labels

# Split data into train and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Convert labels to categorical format
y_train_cat = to_categorical(y_train)
y_test_cat = to_categorical(y_test)

# Build a simple neural network model
model = Sequential()
model.add(Dense(64, input_shape=(len(words),), activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(32, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(2, activation='softmax'))  # Adjust the output layer size based on the number of classes

# Compile the model
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Train the model
model.fit(X_train, y_train_cat, epochs=10, batch_size=8, validation_data=(X_test, y_test_cat))

# Save the trained model
model.save("../backend/models/recipe_model.h5")

# Convert int32 objects to int
words = [str(w) for w in words]  # Convert word list to strings, if needed
categories = [int(c) for c in list(set(y))]  # Convert categories to int

# Save the vocabulary and category information
vocabulary_data = {
    "words": words,
    "categories": categories
}

with open('../backend/models/vocabulary.json', 'w') as f:
    json.dump(vocabulary_data, f)

print("Model and vocabulary saved successfully.")