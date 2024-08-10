from flask import Flask, request, jsonify
from bot import get_response, BotData, load_bot_data, train_model
import logging
import os

app = Flask(__name__)

# Check if vocabulary.json exists; if not, train the model
if not os.path.exists('vocabulary.json'):
    print("Training model as vocabulary.json is missing...")
    train_model()

# Load the chatbot data (pre-trained model, intents, etc.)
bot_data = load_bot_data()

# Logging configuration
logging.basicConfig(filename='logs/bot.log', level=logging.INFO)

@app.route('/get_recipe', methods=['POST'])
def get_recipe():
    user_message = request.json.get('query', '')
    logging.info(f"User query: {user_message}")
    try:
        response = get_response(user_message, bot_data)
    except Exception as e:
        logging.error(f"An error occurred: {e}")
        response = "Sorry, an error occurred while processing your request."
    logging.info(f"Bot response: {response}")
    return jsonify({'response': response})

# Call Main Function
if __name__ == '__main__':
    # Threaded option to enable multiple instances for multiple user access support
    app.run(threaded=True, port=5000)