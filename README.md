# cooking_app

A new Flutter project.

## Getting Started

# Cook With AI - How to Run the Project on Windows (VS Code)

## 1. Install Flutter and Dart SDK

### Step 1: Download and Set Up Flutter

- Go to [Flutter's official website](https://flutter.dev/docs/get-started/install/windows) and download Flutter for Windows.
- Extract the Flutter ZIP file to `C:\src\flutter` (or another location you prefer).

## 2. Set Up VS Code for Flutter Development

### Step 1: Install VS Code

- Download and install Visual Studio Code from (https://code.visualstudio.com/).

### Step 2: Install Flutter and Dart Extensions

- Open VS Code and click on the **Extensions** icon (or press `Ctrl + Shift + X`).
- In the search bar, type **Flutter** and install the **Flutter** extension. It will also install **Dart** automatically.

### Step 3: Set Up Android Emulator (Optional)

If you need to run the app on an emulator (instead of a real phone):

- Install **Android Studio** from (https://developer.android.com/studio).
- Set up an Android Virtual Device (AVD) in **Android Studio**.
- After setting up the emulator, go back to VS Code, press `Ctrl + Shift + P`, and type **Flutter: Launch Emulator**.

## 3. Run the "Cook With AI" Flutter App

### Step 1: Clone the Project

- Open **Command Prompt** or **VS Code terminal** and run:

  git clone https://github.com/AmruNizwar/cooking_app.git
  cd cook-with-ai

### Step 2: Install Flutter Dependencies

- Inside the project folder, run this command to install required
  -------flutter pub get

### Step 3: Run the App

- To run the app, type:

  -------flutter run

## 4. Set Up the Python Backend (Flask API)

### Step 1: Install Python

- Download and install Python from (https://www.python.org/downloads/).

### Step 3: Install Required Libraries

- Install the required Python libraries by running the file is in backend:

  -------pip install -r requirements.txt

### Step 4: Start the Flask Server

- Run the Flask API server:

  -------python app.py

Now you're ready to run **Cook With AI** on your local machine using VS Code!
