import json
import pickle
from keras.models import load_model
import nltk
import os

nltk.download('punkt')

class BotData:
    def __init__(self, model, categories, words, intents, conversation_flows):
        self.model = model
        self.categories = categories
        self.words = words
        self.intents = intents
        self.conversation_flows = conversation_flows

def load_data(dataset_name):
    try:
        with open('models/data.pickle', 'rb') as f:
            data = pickle.load(f)
            words = data['words']
            categories = data['categories']

        model = load_model(f'models/{dataset_name}_model.h5')

        intents_path = 'intents.json'
        conversation_flows_path = 'conversation_flows.json'

        if not os.path.exists(intents_path):
            raise FileNotFoundError(f"File not found: {intents_path}")

        if not os.path.exists(conversation_flows_path):
            raise FileNotFoundError(f"File not found: {conversation_flows_path}")

        with open(intents_path, 'r') as f:
            intents = json.load(f)

        with open(conversation_flows_path, 'r') as f:
            conversation_flows = json.load(f)

        return BotData(model, categories, words, intents, conversation_flows)
    except Exception as e:
        print(f"An error occurred while loading data: {e}")
        return None
