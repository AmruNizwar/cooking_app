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
    data = pd.read_csv('data/recipe.csv')
    data['RecipeIngredientParts'] = data['RecipeIngredientParts'].apply(lambda x: nltk.word_tokenize(x.lower()))
    words = []
    classes = []
    documents = []
    ignore_words = ['?', '!', ',', '.', "'s", "'m"]

    for index, row in data.iterrows():
        word_list = row['RecipeIngredientParts']
        words.extend(word_list)
        documents.append((word_list, row['RecipeCategory']))
        if row['RecipeCategory'] not in classes:
            classes.append(row['RecipeCategory'])

    words = [stemmer.stem(w.lower()) for w in words if w not in ignore_words]
    words = sorted(list(set(words)))
    classes = sorted(list(set(classes)))

    pickle.dump((words, classes), open("models/data.pickle", "wb"))

    training = []
    output_empty = [0] * len(classes)
    for doc in documents:
        bag = []
        pattern_words = doc[0]
        pattern_words = [stemmer.stem(word.lower()) for word in pattern_words]

        for w in words:
            bag.append(1) if w in pattern_words else bag.append(0)

        output_row = list(output_empty)
        output_row[classes.index(doc[1])] = 1

        training.append([bag, output_row])

    random.shuffle(training)
    training = np.array(training)

    train_x = list(training[:, 0])
    train_y = list(training[:, 1])

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

    model.fit(np.array(train_x), np.array(train_y), epochs=200, batch_size=5, verbose=1)
    model.save('../backend/models/recipe_model.h5')

    print("Model training completed and saved as 'recipe_model.h5'.")

if __name__ == "__main__":
    train_model()