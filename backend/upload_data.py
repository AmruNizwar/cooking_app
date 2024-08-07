import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

# Initialize Firestore
cred = credentials.Certificate("../backend/cooking-app-68f57-firebase-adminsdk-og98k-d4cf8bd473.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load the CSV file
df = pd.read_csv('../../recipes.csv')

# Function to upload data to Firestore
def upload_data():
    for index, row in df.iterrows():
        recipe_data = {
            'RecipeId': row['RecipeId'],
            'Name': row['Name'],
            'AuthorId': row['AuthorId'],
            'AuthorName': row['AuthorName'],
            'CookTime': row['CookTime'],
            'PrepTime': row['PrepTime'],
            'TotalTime': row['TotalTime'],
            'DatePublished': row['DatePublished'],
            'Description': row['Description'],
            'Images': row['Images'],
            'RecipeCategory': row['RecipeCategory'],
            'Keywords': row['Keywords'],
            'RecipeIngredientQuantities': row['RecipeIngredientQuantities'],
            'RecipeIngredientParts': row['RecipeIngredientParts'],
            'AggregatedRating': row['AggregatedRating'],
            'ReviewCount': row['ReviewCount'],
            'Calories': row['Calories'],
            'FatContent': row['FatContent'],
            'SaturatedFatContent': row['SaturatedFatContent'],
            'CholesterolContent': row['CholesterolContent'],
            'SodiumContent': row['SodiumContent'],
            'CarbohydrateContent': row['CarbohydrateContent'],
            'FiberContent': row['FiberContent'],
            'SugarContent': row['SugarContent'],
            'ProteinContent': row['ProteinContent'],
            'RecipeServings': row['RecipeServings'],
            'RecipeYield': row['RecipeYield'],
            'RecipeInstructions': row['RecipeInstructions'],
        }
        db.collection('recipes').add(recipe_data)

# Call the function to upload data
upload_data()
