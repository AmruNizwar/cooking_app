import pandas as pd
import nltk
import pickle
from nltk.tokenize import word_tokenize
from nltk.stem.lancaster import LancasterStemmer

nltk.download('punkt')

stemmer = LancasterStemmer()

def preprocess_input_data():
    data = pd.read_csv('data/recipe.csv')
    data['RecipeIngredientParts'] = data['RecipeIngredientParts'].apply(lambda x: word_tokenize(x.lower()))
    
    words = []
    categories = []
    documents = []
    ignore_words = ['?', '!', ',', '.', "'s", "'m"]

    for index, row in data.iterrows():
        word_list = row['RecipeIngredientParts']
        words.extend(word_list)
        documents.append((word_list, row['RecipeCategory']))
        if row['RecipeCategory'] not in categories:
            categories.append(row['RecipeCategory'])

    words = [stemmer.stem(w.lower()) for w in words if w not in ignore_words]
    words = sorted(list(set(words)))
    categories = sorted(list(set(categories)))

    training_data = {
        "words": words,
        "categories": categories,
        "documents": documents
    }

    with open('models/training_data.pickle', 'wb') as f:
        pickle.dump(training_data, f)