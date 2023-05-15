import base64
import sys

import pyrebase
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from flask import Flask, request, jsonify
import uuid

# Initialize pyrebase with user credentials
config = {
    'apiKey': "AIzaSyCRaKSS_ANuUa1QibLkWuntJ135EYK9CXY",
    'authDomain': "plantitdb1.firebaseapp.com",
    'projectId': "plantitdb1",
    'storageBucket': "plantitdb1.appspot.com",
    'messagingSenderId': "959335294179",
    'appId': "1:959335294179:web:21f768d3aab7a7c5b191d6",
    'measurementId': "G-JNXM9WXHXZ",
    'databaseURL': ''}

firebase = pyrebase.initialize_app(config)
# Use pyrebase to authenticate users
auth = firebase.auth()
storage = firebase.storage()

# Initialize firebase_admin with service account credentials
cred = credentials.Certificate("plantitdb1-firebase-adminsdk-y2grh-c4930ddb02.json")
firebase_admin.initialize_app(cred)

# Use firebase_admin to perform administrative tasks, such as managing user accounts or accessing the Cloud Firestore
# database
db = firestore.client()

# Initialize Flask app
app = Flask(__name__)


# with open(sys.argv[1], "rb") as image_file:
#  encoded_string = base64.b64encode(image_file.read())


# Firebase Authentication
@app.route('/register', methods=['POST'])
def register():
    """
    Register a new user with the given email and password.
    """
    data = request.get_json()
    email = data['email']
    password = data['password']
    username = data['username']
    try:
        user = auth.create_user_with_email_and_password(email=email, password=password)
        print(user)
        auth.update_profile(
            user['idToken'],
            display_name=username
        )
        return jsonify({"message": "User created successfully."}), 201
    except Exception as e:
        error_message = str(e)
        print(error_message)
        return jsonify({"message": f"Unable to create user. Reason: {error_message}"}), 400


@app.route('/login', methods=['POST'])
def login():
    """
    Log in a user with the given email and password.
    """
    data = request.get_json()
    email = data['email']
    password = data['password']
    try:
        user = auth.sign_in_with_email_and_password(email, password)
        return jsonify({"message": "Login successful."}), 200
    except:
        return jsonify({"message": "Invalid email or password."}), 400


# @app.route('/logout', methods=['POST'])
# def logout():
#     """
#     Log out the current user.
#     """
#     data = request.get_json()
#     id_token = data['id_token']
#     try:
#         auth.revoke_refresh_tokens(id_token)
#         return jsonify({"message": "Logout successful."}), 200
#     except:
#         return jsonify({"message": "Unable to logout."}), 400

@app.route('/resetPass', methods=['POST'])
def reset():
    """
    Reset password of user.
    """
    data = request.get_json()
    email = data['email']
    try:
        auth.send_password_reset_email(email)
        return jsonify({"message": "reset successful."}), 201
    except:
        return jsonify({"message": "Invalid email."}), 400


# Define routes for CRUD operations
@app.route('/users', methods=['POST'])
def create_user():
    """
    Create a new user with the given data.
    """
    data = request.get_json()
    user_ref = db.collection('users').document(data['email'])
    user_ref.set(data)
    # user_ref.collection("User_Plants").add({})
    return jsonify({"message": "User created successfully."}), 201


@app.route('/users', methods=['GET'])
def read_users():
    """
    Retrieve all users from Firestore DB.
    """
    users = [doc.to_dict() for doc in db.collection('users').stream()]
    return jsonify(users), 200


@app.route('/users/<user_id>', methods=['GET'])
def read_user(user_id):
    """
    Retrieve a specific user by ID from Firestore DB.
    """
    user_doc = db.collection('users').document(user_id).get()
    if user_doc.exists:
        return jsonify(user_doc.to_dict()), 200
    else:
        return jsonify({"message": "User not found."}), 404


@app.route('/users/<user_id>', methods=['PUT'])
def update_user(user_id):
    """
    Update a specific user by ID with the given data.
    """
    data = request.get_json()
    user_ref = db.collection('users').document(user_id)
    user_ref.update(data)
    return jsonify({"message": "User updated successfully."}), 200


@app.route('/users/<user_id>', methods=['DELETE'])
def delete_user(user_id):
    """
    Delete a specific user by ID from Firestore DB.
    """
    user_ref = db.collection('users').document(user_id)
    user_ref.delete()
    return jsonify({"message": "User deleted successfully."}), 200


@app.route('/deletPlant', methods=['DELETE'])
def delete_plant():
    user1 = request.args.get('user')
    plant = request.args.get('plant')
    user = db.collection('users').document(user1)
    plant_docs = user.collection("User_Plants").where("nickname", "==", plant).stream()
    plant_ref = None
    for doc in plant_docs:
        plant_ref = doc.reference
        break
    if plant_ref is None:
        return jsonify({"error": "Plant not found"}), 404
    plant_ref.delete()
    return jsonify({"message": "Successfully deleted"}), 201


# Define routes for CRUD operations
@app.route('/addToGarden', methods=['POST'])
def add_to_garden():
    """
    Create a new plant with the given data.
    """
    data = request.get_json()
    print(request.args.get('user'))
    p = db.collection('users').document(request.args.get('user'))
    p.collection("User_Plants").add(data)
    return jsonify({"message": "Plant created successfully."}), 201


@app.route('/addToHistory', methods=['POST'])
def add_to_history():
    user1 = request.args.get('user')
    plant = request.args.get('plant')
    user = db.collection('users').document(user1)
    plant_docs = user.collection("User_Plants").where("nickname", "==", plant).stream()
    plant_ref = None
    for doc in plant_docs:
        plant_ref = doc.reference
        break
    if plant_ref is None:
        return jsonify({"error": "Plant not found"}), 404

    # Get the uploaded file
    file = request.files['image']
    # Generate a unique filename for the file
    filename = f'users/{user1}/{plant}/{uuid.uuid4().hex}.jpg'

    # Upload the file to Firebase Storage
    storage.child(filename).put(file)

    # Add the other form data to Firestore
    plant_ref.collection('History').add({
        'image': storage.child(filename).get_url(None),
        'disease': request.form['disease'],
        'care plan': request.form['care plan'],
        'date': request.form['date']
    })

    return jsonify({"message": "Successfully added to history"}), 201




@app.route('/plants', methods=['GET'])
def read_plants():
    """
    Retrieve all plants from Firestore DB.
    """
    p = [doc.to_dict() for doc in db.collection('Plants').stream()]
    return jsonify(p), 200


@app.route('/plants/<light>/<temp>/<moist>', methods=['GET'])
def read_plant(light, temp, moist):
    """
    Retrieve a specific user by ID from Firestore DB.
    """
    # Define your functionality as a lambda function
    func = lambda obj: light in obj['Light'] and temp in obj['Temperature'] and moist in obj['Humidity']

    plant = [doc.to_dict() for doc in db.collection('Plants').where("Light", "==", light).
        where("Temperature", "==", temp).where("Humidity", "==", moist).stream()]
    # if plant.exists:
    return jsonify(plant), 200


# else:
#   return jsonify({"message": "User not found."}), 404


@app.route('/plants/<user>', methods=['GET'])
def get_user_plants(user):
    plants = [doc.to_dict() for doc in db.collection('users').document(user).collection("User_Plants").stream()]
    return jsonify(plants), 200


@app.route('/history/<user>/<plant>', methods=['GET'])
def get_plant_history(user, plant):
    plant_docs = db.collection('users').document(user).collection("User_Plants").where("nickname", "==", plant).stream()
    plant_ref = None
    for doc in plant_docs:
        plant_ref = doc.reference
        break
    if plant_ref is None:
        return jsonify({"error": "Plant not found"}), 404
    history = [doc.to_dict() for doc in plant_ref.collection("History").stream()]
    return jsonify(history), 200



@app.route('/plants/<user>/<nickname>', methods=['GET'])
def get_user_plant(user, nickname):
    plant = [doc.to_dict() for doc in db.collection('users').document(user).collection("User_Plants").
        where("nickname", "==", nickname).stream()]
    return jsonify(plant[0]), 200


# Run Flask app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')