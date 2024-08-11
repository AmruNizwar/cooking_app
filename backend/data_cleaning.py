import pandas as pd
import nltk
import json

# Download NLTK data
nltk.download('punkt')

# Load the dataset
df = pd.read_csv('C:\\project\\cooking_app\\backend\\data\\recipe_original.csv')

# Select relevant columns
df = df[['RecipeInstructions', 'RecipeCategory']]

# Drop rows with missing values
df.dropna(subset=['RecipeInstructions', 'RecipeCategory'], inplace=True)

# Tokenize and preprocess
nltk.download('punkt')
stemmer = nltk.stem.PorterStemmer()

def preprocess_text(text):
    tokens = nltk.word_tokenize(text)
    return ' '.join([stemmer.stem(token.lower()) for token in tokens])

df['RecipeInstructions'] = df['RecipeInstructions'].apply(preprocess_text)
df['RecipeCategory'] = df['RecipeCategory'].str.lower()

# Convert to the format needed for training
processed_data = []
for _, row in df.iterrows():
    processed_data.append({
        'patterns': [row['RecipeInstructions']],
        'tag': row['RecipeCategory']
    })

# Save to a JSON format
recipe_intents = {'intents': processed_data}

with open('processed_kaggle_recipes.json', 'w') as f:
    json.dump(recipe_intents, f)
