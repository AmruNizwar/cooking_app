import random
import nltk
import numpy as np
import pandas as pd
import json
import pickle
from nltk.stem.lancaster import LancasterStemmer
from sklearn.model_selection import train_test_split
from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.optimizers import SGD

nltk.download('punkt')
stemmer = LancasterStemmer()

def preprocess_data():
    # Load existing data from pickle file
    with open(r'backend\models\data.pickle', 'rb') as f:
        data = pickle.load(f)
    
    # Adjust this based on how the data is structured in the pickle file
    if isinstance(data, dict):
        words = data.get('words', [])
        classes = data.get('classes', [])
    else:
        words, classes = data  # Assumes data is a tuple/list with 2 items

    # Process the new CSV data
    data = pd.read_csv(r'backend\data\recipe_original.csv')
    data['RecipeIngredientParts'] = data['RecipeIngredientParts'].apply(lambda x: nltk.word_tokenize(x.lower()))
    
    documents = []
    ignore_words = ['?', '!', ',', '.', "'s", "'m"]
    
    # Collect data from CSV
    for index, row in data.iterrows():
        word_list = row['RecipeIngredientParts']
        words.extend(word_list)
        # Convert categories to strings to avoid mixed types
        category = str(row['RecipeCategory'])
        documents.append((word_list, category))
        if category not in classes:
            classes.append(category)
    
    # Process the words
    words = [stemmer.stem(w.lower()) for w in words if w not in ignore_words]
    words = sorted(list(set(words)))
    classes = sorted(list(set(classes)))  # Sorting should now work since all classes are strings

    # Save updated words and classes back to pickle
    with open(r"backend\models\data.pickle", "wb") as f:
        pickle.dump((words, classes), f)

    # Create training data
    training = []
    output_empty = [0] * len(classes)
    
    for doc in documents:
        bag = []
        pattern_words = doc[0]
        pattern_words = [stemmer.stem(word.lower()) for word in pattern_words]

        # Create the bag of words array
        bag = [1 if w in pattern_words else 0 for w in words]

        output_row = list(output_empty)
        output_row[classes.index(doc[1])] = 1

        training.append([bag, output_row])
    
    # Shuffle the training data
    random.shuffle(training)
    
    # Convert to numpy array with proper dtype for consistency
    training = np.array(training, dtype=object)
    
    train_x = np.array([element[0] for element in training], dtype=np.float32)
    train_y = np.array([element[1] for element in training], dtype=np.float32)

    return train_x, train_y, words, classes

def train_model():
    train_x, train_y, words, classes = preprocess_data()

    model = Sequential()
    model.add(Dense(128, input_shape=(len(train_x[0]),), activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(64, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(len(classes), activation='softmax'))

    sgd = SGD(learning_rate=0.01, momentum=0.9, nesterov=True)
    model.compile(loss='categorical_crossentropy', optimizer=sgd, metrics=['accuracy'])

    model.fit(train_x, train_y, epochs=200, batch_size=5, verbose=1)
    model.save(r'backend\models\recipe_model.h5')

    print("Model training completed and saved as 'recipe_model.h5'.")

if __name__ == "__main__":
    train_model()