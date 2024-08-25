# main.py   file
from model.nlp_model import RecipeChatbot
import logging

def main():
    chatbot = RecipeChatbot(csv_filepath='data/recipes.csv',intents_path='model/intents.json')
    logging.basicConfig(level=logging.INFO)

    while True:
        user_input = input("You: ").strip()
        if not user_input:
            print("Please enter a valid input.")
            continue

        try:
            response = chatbot.generate_response(user_input)
            print(f"Bot: {response}")
        except ValueError as e:
            print(f"Error: {e}. The model might be untrained or unable to find a match.")
        except Exception as e:
            logging.error(f"An unexpected error occurred: {e}")
            print("An unexpected error occurred. Please try again.")
        
if __name__ == "__main__":
    main()
