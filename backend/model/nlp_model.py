#model/nlp_model.py    file
import re
import random
import os
import pickle
import sys
import numpy as np
import json
from tensorflow.keras.models import load_model, Model
from tensorflow.keras.layers import Input, Embedding, LSTM, Dense, Bidirectional
from tensorflow.keras.callbacks import EarlyStopping
import logging
# Add the backend directory to the system path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../')))

from model.preprocess import prepare_data_for_training, clean_text, save_tokenizer, load_tokenizer


class RecipeChatbot:
    def __init__(self, csv_filepath, intents_path='intents.json', model_path='recipe_model.h5', tokenizer_path='tokenizer.json', max_words=10000, max_sequence_length=100, embedding_dim=128):
        self.X, self.y, self.df, self.tokenizer, self.label_encoder = prepare_data_for_training(csv_filepath, max_words, max_sequence_length)
        self.max_sequence_length = max_sequence_length

        if os.path.exists(model_path):
            self.model = load_model(model_path)
            logging.info(f"Loaded model from {model_path}.")
        else:
            self.model = self.build_model(max_words, max_sequence_length, embedding_dim)
            logging.info("Model built successfully.")

        with open(intents_path, 'r') as file:
            self.intents = json.load(file)

        logging.info("RecipeChatbot initialized.")

    def build_model(self, max_words, max_sequence_length, embedding_dim):
        input_text = Input(shape=(max_sequence_length,))
        embedding = Embedding(input_dim=max_words, output_dim=embedding_dim, input_length=max_sequence_length)(input_text)
        lstm = Bidirectional(LSTM(units=128, return_sequences=False))(embedding)
        dense = Dense(units=128, activation='relu')(lstm)
        output = Dense(units=self.X.shape[0], activation='softmax')(dense)
        model = Model(inputs=input_text, outputs=output)
        model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
        logging.info("Model built successfully.")
        return model

    def train(self, epochs=100, batch_size=32, validation_split=0.2):
        y = np.arange(self.X.shape[0])
        logging.info("Training started.")
        self.model.fit(self.X, y, epochs=epochs, batch_size=batch_size, validation_split=validation_split)
        logging.info("Training completed.")
        self.evaluate_model()

    def evaluate_model(self):
        y = np.arange(self.X.shape[0])
        loss, accuracy = self.model.evaluate(self.X, y, verbose=0)
        logging.info(f"Evaluation - Loss: {loss}, Accuracy: {accuracy}")

    def save_model(self, model_path, tokenizer_path):
        self.model.save(model_path)
        logging.info(f"Model saved to {model_path}.")
        
        # Save the tokenizer as well
        # Save the tokenizer as JSON using the save_tokenizer function
        save_tokenizer(self.tokenizer, tokenizer_path)
        logging.info(f"Tokenizer saved to {tokenizer_path}.")

    def generate_response(self, user_input, max_sequence_length=100):
        cleaned_input = clean_text(user_input.lower().strip())

        # Check if the user is asking for more options
        if cleaned_input == 'more':
            return self.handle_more_options()

        for intent in self.intents['intents']:
            # Match the user input with the patterns defined in each intent
            for pattern in intent['patterns']:
                if re.search(pattern.replace("*", ".*"), cleaned_input):
                    # If a matching pattern is found, execute the associated action
                    if intent['action']:
                        response_function = getattr(self, intent['action'], None)
                        if response_function:
                            query = re.sub("|".join([re.escape(p.replace("*", "")) for p in intent['patterns']]), '', cleaned_input).strip()
                            return response_function(query)
                    # If no action is defined, return a random response
                    if intent['responses']:
                        return random.choice(intent['responses'])

        # Default response if no matching pattern is found
        return "I'm not sure how to help with that. Could you ask your question in a different way?"

    def handle_recipe_query(self, recipe_name):
        return self.search_by_recipe_name(recipe_name)

    def handle_ingredient_query(self, ingredients):
        return self.search_by_ingredient(ingredients)

    def handle_cooking_time_query(self, recipe_name):
        return self.search_by_cooking_time(recipe_name)

    def handle_nutritional_info_query(self, recipe_name):
        return self.search_by_nutritional_info(recipe_name)

    # New methods added below

    def search_by_ingredient(self, ingredients):
        ingredients_list = [ingredient.strip().lower() for ingredient in ingredients.split(',')]
        query = '(?=.*' + ')(?=.*'.join(ingredients_list) + ')'
        matched_recipes = self.df[self.df['RecipeIngredientParts'].str.lower().str.contains(query, case=False, na=False, regex=True)]
        
        if matched_recipes.empty:
            return f"No recipes found containing all of these ingredients: {', '.join(ingredients_list)}."

        if len(matched_recipes) > 1:
            return self.handle_multiple_options(matched_recipes, "ingredient")
        else:
            return self.display_recipe_details(matched_recipes.iloc[0])


    def search_by_cooking_time(self, recipe_name):
        matched_recipes = self.df[self.df['CleanedName'].str.contains(recipe_name, case=False, na=False)]
        if matched_recipes.empty:
            return f"No cooking time found for {recipe_name}."

        matched_row = matched_recipes.iloc[0]
        response = (
            f"\n**Recipe**: \n{matched_row['Name']}\n\n"
            f"**Total Time**: \n{matched_row.get('TotalTime', 'N/A')}\n\n"
        )
        return response

    def search_by_nutritional_info(self, recipe_name):
        cleaned_recipe_name = clean_text(recipe_name.strip().lower())
        
        matched_recipes = self.df[self.df['CleanedName'].str.contains(cleaned_recipe_name, case=False, na=False)]
        
        if matched_recipes.empty:
            return f"No nutritional information found for {recipe_name}."

        matched_row = matched_recipes.iloc[0]
        response = (
            f"\n**Nutritional Information** for {matched_row['Name']}:\n"
            f" - Calories: {matched_row.get('Calories', 'N/A')}\n"
            f" - Protein: {matched_row.get('ProteinContent', 'N/A')}\n"
            f" - Fat: {matched_row.get('FatContent', 'N/A')}\n"
            f" - Saturated Fat: {matched_row.get('SaturatedFatContent', 'N/A')}\n"
            f" - Carbohydrates: {matched_row.get('CarbohydrateContent', 'N/A')}\n"
            f" - Fiber: {matched_row.get('FiberContent', 'N/A')}\n"
            f" - Sugar: {matched_row.get('SugarContent', 'N/A')}\n"
            f" - Sodium: {matched_row.get('SodiumContent', 'N/A')}\n"
            f" - Cholesterol: {matched_row.get('CholesterolContent', 'N/A')}\n"
        )
        return response



    def search_by_recipe_name(self, recipe_name):
        matched_recipes = self.df[self.df['CleanedName'].str.contains(recipe_name, case=False, na=False)]
        if matched_recipes.empty:
            return f"No recipes found for {recipe_name}."

        if len(matched_recipes) > 1:
            return self.handle_multiple_options(matched_recipes, "recipe_name")
        else:
            return self.display_recipe_details(matched_recipes.iloc[0])

    def handle_multiple_options(self, matched_recipes, query_type):
        response = "I found multiple options. Please select one:\n"
        
        # Display the first 10 options
        for idx, row in matched_recipes.head(10).iterrows():
            if query_type == "recipe_name":
                response += f"{idx + 1}. {row['Name']}\n"
            elif query_type == "ingredient":
                response += (
                    f"\n**Recipe {idx + 1}:** {row['Name']}\n"
                    f"**Ingredients:** {row.get('RecipeIngredientParts', 'No ingredients available.')}\n"
                )

        # Store the remaining indices for future use
        self.last_indices = matched_recipes.index[10:].tolist()
        self.last_type = query_type

        if self.last_indices:
            response += "\nType 'more' to see more options."
        else:
            response += "\nAll recipes are shown."

        return response

    def display_recipe_details(self, matched_row):
        response = (
            f"\n**Recipe**: \n{matched_row['Name']}\n\n"
            f"**Total Time**: \n{matched_row.get('TotalTime', 'N/A')}\n\n"
            f"**Description**: \n{matched_row.get('Description', 'No description available.')}\n\n"
            f"**Ingredients**: \n{matched_row.get('RecipeIngredientParts', 'No ingredients available.')}\n\n"
            f"**Instructions**: \n{matched_row.get('RecipeInstructions', 'No instructions available.')}\n\n"
            f"**Nutritional Information**:\n"
            f" - Calories: {matched_row.get('Calories', 'N/A')}\n"
            f" - Protein: {matched_row.get('ProteinContent', 'N/A')}\n"
            f" - Fat: {matched_row.get('FatContent', 'N/A')}\n"
            f" - Saturated Fat: {matched_row.get('SaturatedFatContent', 'N/A')}\n"
            f" - Carbohydrates: {matched_row.get('CarbohydrateContent', 'N/A')}\n"
            f" - Fiber: {matched_row.get('FiberContent', 'N/A')}\n"
            f" - Sugar: {matched_row.get('SugarContent', 'N/A')}\n"
            f" - Sodium: {matched_row.get('SodiumContent', 'N/A')}\n"
            f" - Cholesterol: {matched_row.get('CholesterolContent', 'N/A')}\n"
        )
        return response

    def handle_more_options(self):
        if not self.last_indices:
            return "No more options available."

        # Fetch the next 10 options
        next_indices = self.last_indices[:10]
        self.last_indices = self.last_indices[10:]

        response = "Here are more options:\n"
        matched_recipes = self.df.loc[next_indices]
        
        for idx, row in matched_recipes.iterrows():
            if self.last_type == "recipe_name":
                response += f"{idx + 1}. {row['Name']}\n"
            elif self.last_type == "ingredient":
                response += (
                    f"\n**Recipe {idx + 1}:** {row['Name']}\n"
                    f"**Ingredients:** {row.get('RecipeIngredientParts', 'No ingredients available.')}\n"
                )

        if self.last_indices:
            response += "\nType 'more' to see more options."
        else:
            response += "\nAll recipes are shown."

        return response

