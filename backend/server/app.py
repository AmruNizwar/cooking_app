# server/app.py     file
import os
import sys
from flask import Flask, request, jsonify
from flask_cors import CORS

# Append the absolute path of the model directory
sys.path.append(os.path.abspath('../model'))

from nlp_model import RecipeChatbot

import logging

app = Flask(__name__)
CORS(app)
chatbot = RecipeChatbot(csv_filepath='../data/recipes.csv')

@app.route('/train', methods=['POST'])
def train():
    chatbot.train()
    chatbot.save_model('models/model/recipe_model.h5')
    return jsonify({'message': 'Model trained successfully!'})

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
