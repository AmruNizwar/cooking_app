#model/train.py   file
import os
print(os.getcwd())

from model.nlp_model import RecipeChatbot

# Paths to your files
csv_filepath = 'data/recipes.csv'
model_path = 'model/recipe_model.h5'
tokenizer_path = 'model/tokenizer.json'
intents_path = 'model/intents.json'

# Initialize the chatbot
chatbot = RecipeChatbot(csv_filepath, intents_path, model_path)

# Train the model
chatbot.train(epochs=100, batch_size=32)  # Adjust epochs and batch_size as needed

# Save the trained model and tokenizer
chatbot.save_model(model_path, tokenizer_path)
