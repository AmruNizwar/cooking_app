import nltk
from nltk.stem import PorterStemmer
from keras.models import Sequential, load_model
from keras.layers import Dense, Dropout
import numpy as np
import random
import json
import os

# Ensure the NLTK data (punkt) is downloaded
nltk.download('punkt')

# Initialize the stemmer
stemmer = PorterStemmer()

# Tokenize the sentence
def tokenize(sentence):
    return nltk.word_tokenize(sentence)

# Stem the words
def stem(word):
    return stemmer.stem(word.lower())

# Bag of words function
def bow(sentence, words):
    sentence_words = [stem(word) for word in tokenize(sentence)]
    bag = [0] * len(words)  # Create a bag of zeros
    for s_word in sentence_words:
        for i, w in enumerate(words):
            if w == s_word:
                bag[i] = 1
                break
    return np.array(bag)

# Train the model
def train_model():
    words = []
    categories = []
    documents = []
    ignore_words = ['?', '!', '.', ',']

    # Load intents
    with open('intents.json') as file:
        intents = json.load(file)

    for intent in intents['intents']:
        for pattern in intent['patterns']:
            word_list = tokenize(pattern)
            words.extend(word_list)
            documents.append((word_list, intent['tag']))
            if intent['tag'] not in categories:
                categories.append(intent['tag'])

    words = [stem(w) for w in words if w not in ignore_words]
    words = sorted(list(set(words)))
    categories = sorted(categories)

    training = []
    output_empty = [0] * len(categories)

    for document in documents:
        bag = [0] * len(words)
        word_patterns = document[0]
        word_patterns = [stem(word) for word in word_patterns]
        for word in word_patterns:
            for i, w in enumerate(words):
                if w == word:
                    bag[i] = 1

        output_row = list(output_empty)
        output_row[categories.index(document[1])] = 1
        training.append([bag, output_row])

    random.shuffle(training)
    training = np.array(training, dtype=object)  # Ensure consistent data type
    train_x = np.array(list(training[:, 0]), dtype=np.float32)
    train_y = np.array(list(training[:, 1]), dtype=np.float32)

    model = Sequential()
    model.add(Dense(128, input_shape=(len(train_x[0]),), activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(64, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(len(train_y[0]), activation='softmax'))

    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

    model.fit(train_x, train_y, epochs=200, batch_size=5, verbose=1)

    model.save('../backend/models/recipe_model.h5')

    vocabulary_data = {
        "words": words,
        "categories": categories
    }

    with open('vocabulary.json', 'w') as f:
        json.dump(vocabulary_data, f)

# Load the model and vocabulary, and create BotData
def load_bot_data():
    with open('vocabulary.json', 'r') as f:
        vocabulary_data = json.load(f)

    words = vocabulary_data["words"]
    categories = vocabulary_data["categories"]

    model = load_model('../backend/models/recipe_model.h5')

    # Load intents
    with open('intents.json') as file:
        intents = json.load(file)

    return BotData(words, categories, model, intents)

def get_response(user_message, bot_data):
    words = bot_data.words
    categories = bot_data.categories
    model = bot_data.model
    intents = bot_data.intents

    # Preprocess the user message
    input_data = bow(user_message, words)
    input_data = np.array(input_data).reshape(1, len(input_data))
    prediction = model.predict(input_data)
    
    # Debugging: Print the prediction
    print(f"Prediction: {prediction}")
    
    # Find the index with the highest probability
    max_index = np.argmax(prediction)
    
    # Debugging: Print the max index and the corresponding category
    print(f"Max index: {max_index}, Category: {categories[max_index]}")
    
    # Find the intent corresponding to the predicted category
    predicted_category = categories[max_index]
    response = None
    for intent in intents['intents']:
        if intent['tag'] == predicted_category:
            response = random.choice(intent['responses'])
            break

    # Debugging: Print the selected response
    print(f"Response: {response}")

    return response if response else "Sorry, I don't understand."

# BotData class
class BotData:
    def __init__(self, words, categories, model, intents):
        self.words = words
        self.categories = categories
        self.model = model
        self.intents = intents

    @classmethod
    def load(cls, model_path, intents_path):
        model = load_model(model_path)
        with open(intents_path) as file:
            intents = json.load(file)

        bot_data = cls(None, None, model, intents)
        return bot_data

    def initialize_bot_data(self, words, categories):
        self.words = words
        self.categories = categories
        print(f"Initialized categories: {self.categories}")  # Debugging