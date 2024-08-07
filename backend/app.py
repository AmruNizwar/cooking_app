from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore

app = Flask(__name__)

# Initialize Firestore
cred = credentials.Certificate("../backend/cooking-app-68f57-firebase-adminsdk-og98k-d4cf8bd473.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

@app.route('/get_recipe', methods=['POST'])
def get_recipe():
    data = request.json
    query = data.get("query", "").lower()
    
    # Query Firestore for recipes
    recipes_ref = db.collection('recipes')
    query_ref = recipes_ref.where('ingredients', 'array_contains', query).get()
    
    response = []
    for doc in query_ref:
        recipe = doc.to_dict()
        response.append(recipe)

    if not response:
        response = "No recipes found."

    return jsonify({"response": response})

if __name__ == "__main__":
    app.run(debug=True)
