# Import necessary libraries
import pandas as pd
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from keras.models import Sequential
from keras.layers import Dense
from keras.utils import to_categorical
from sklearn.preprocessing import LabelEncoder
from flask import Flask, request, jsonify

# Load the dataset
data = pd.read_csv('recipes.csv')

# Preprocess text function
def preprocess_text(text):
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)
    text = re.sub(r'\d+', '', text)
    return text

# Apply preprocessing to the queries
data['query'] = data['query'].apply(preprocess_text)

# Split the dataset into training and test sets
X_train, X_test, y_train, y_test = train_test_split(data['query'], data['intent'], test_size=0.2, random_state=42)

# Convert text data to TF-IDF features
vectorizer = TfidfVectorizer(max_features=5000)
X_train_tfidf = vectorizer.fit_transform(X_train)
X_test_tfidf = vectorizer.transform(X_test)

# Encode the labels
label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train)
y_test_encoded = label_encoder.transform(y_test)

# Convert labels to categorical (one-hot encoding)
y_train_categorical = to_categorical(y_train_encoded)
y_test_categorical = to_categorical(y_test_encoded)

# Build a simple neural network model
model = Sequential()
model.add(Dense(512, input_dim=X_train_tfidf.shape[1], activation='relu'))
model.add(Dense(256, activation='relu'))
model.add(Dense(len(label_encoder.classes_), activation='softmax'))

# Compile the model
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

# Train the model
model.fit(X_train_tfidf.toarray(), y_train_categorical, epochs=10, batch_size=32, validation_data=(X_test_tfidf.toarray(), y_test_categorical))

# Rule-based entity recognition function
def extract_entities(query):
    entities = {}
    ingredients = ["chicken", "beef", "pork", "tofu"]
    for ingredient in ingredients:
        if ingredient in query:
            entities['ingredient'] = ingredient
            break

    recipes = data['recipe_name'].unique()
    for recipe in recipes:
        if recipe in query:
            entities['recipe_name'] = recipe
            break

    return entities

# NLU function to classify intent and extract entities
def nlu(query):
    query_preprocessed = preprocess_text(query)
    query_tfidf = vectorizer.transform([query_preprocessed])
    intent_pred = model.predict(query_tfidf.toarray())
    intent = label_encoder.inverse_transform([intent_pred.argmax()])[0]
    entities = extract_entities(query_preprocessed)
    return intent, entities

# NLG function to generate responses
def nlg(intent, entities):
    if intent == "get_recipe":
        recipe_name = entities.get('recipe_name', 'the recipe')
        return f"Here are the steps to make {recipe_name}."
    elif intent == "list_ingredients":
        ingredient = entities.get('ingredient', 'ingredient')
        return f"You'll need the following ingredients: {ingredient}."
    else:
        return "I'm sorry, I didn't understand your request."

# Flask app setup
app = Flask(__name__)

@app.route('/message', methods=['POST'])
def message():
    data = request.json
    query = data.get('message', '')
    intent, entities = nlu(query)
    response = nlg(intent, entities)
    return jsonify({'reply': response})

if __name__ == '__main__':
    app.run(debug=True)
