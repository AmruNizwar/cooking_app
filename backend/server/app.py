# server/app.py     file
import os
import sys
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
# Append the absolute path of the model directory
sys.path.append(os.path.abspath('../model'))

from nlp_model import RecipeChatbot

import logging

app = Flask(__name__)
CORS(app)
chatbot = RecipeChatbot(csv_filepath='../data/recipes.csv', intents_path='../model/intents.json')

# New route to fetch random recipes
@app.route('/api/random_recipes', methods=['GET'])
def get_random_recipes():
    count = int(request.args.get('count', 10))  
    df = pd.read_csv('../data/recipes.csv')

    # Replace NaN with None 
    df = df.replace({np.nan: None})

    
    df = df[df['Images'].notna() & df['Images'].str.startswith('https://', na=False)]

    recipes = df.sample(n=count).to_dict(orient='records')

    return jsonify(recipes)

@app.route('/train', methods=['POST'])
def train():
    chatbot.train()
    chatbot.save_model('../model/recipe_model.h5')
    return jsonify({'message': 'Model trained successfully!'})

# chat with chatbot
@app.route('/chat', methods=['POST'])
def chat():
    user_input = request.json.get('message')
    print(f"Received message: {user_input}")
    response = chatbot.generate_response(user_input)
    print(f"Generated response: {response}")
    return jsonify({'response': response})


@app.route('/test', methods=['GET'])
def test():
    return jsonify({'message': 'API is working!'})

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    app.run(host='0.0.0.0', port=5000)
