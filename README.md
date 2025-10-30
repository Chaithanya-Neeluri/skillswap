# 💡 SkillSwap — A Real-Time Skill Exchange Platform

SkillSwap is a full-stack application that connects users who want to **exchange skills and learn from each other**.  
The platform allows users to create profiles, showcase their skills, and connect with others to learn or teach skills in real-time.  

This project consists of two main parts:
- 🧩 **Frontend** — Flutter app (`skillswap_flutter`)
- ⚙️ **Backend** — Express.js + MongoDB (`skillswap_backend`)

---

## 📁 Project Structure

```

SkillSwap/
│
├── skillswap_backend/       # Express.js backend
│   ├── routes/              # API route handlers
│   ├── models/              # Mongoose models
│   ├── controllers/         # Business logic
│   ├── .env                 # Environment variables
│   ├── server.js            # Backend entry point
│   └── package.json         # Backend dependencies
│
└── skillswap_flutter/       # Flutter frontend
├── lib/
│   ├── features/        # App features (auth, profile, etc.)
│   └── data/            # API integration and services
└── pubspec.yaml         # Flutter dependencies

````

---

## ⚙️ Prerequisites

Before you begin, make sure you have installed:
- [Node.js](https://nodejs.org/) (v18 or above)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [MongoDB](https://www.mongodb.com/)
- A code editor (VS Code recommended)

---

## 🔐 Environment Setup

### 1. Create a `.env` file in `skillswap_backend/`

The backend uses environment variables for configuration.  
Create a `.env` file inside the `skillswap_backend` folder and add the following values:

```env
PORT=5000
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret_key
GEMINI_API_KEY=your_gemini_ai_key
````

> ⚠️ Make sure to keep this file private and **do not commit** it to GitHub.

---

## 🚀 Backend Setup (Express + MongoDB)

### Steps:

1. Navigate to the backend folder:

   ```bash
   cd skillswap_backend
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Start the backend server:

   ```bash
   npm start
   ```

   or (for development)

   ```bash
   nodemon server.js
   ```

4. After successful start, you’ll see something like:

   ```
   Server running on http://localhost:5000
   Connected to MongoDB
   ```

   Note the **localhost IP and port** (e.g., `http://192.168.x.x:5000` or `http://localhost:5000`).

---

## 🧩 Frontend Setup (Flutter)

### Steps:

1. Open a new terminal and navigate to the Flutter folder:

   ```bash
   cd ../skillswap_flutter
   ```

2. Get Flutter packages:

   ```bash
   flutter pub get
   ```

3. Update API endpoint:

   * Go to `lib/features/data/` folder.
   * Open the file where the **backend base URL** is defined (for example, `api_constants.dart` or `api_service.dart`).
   * Replace the existing base URL with your backend’s local IP (from previous step):

     ```dart
     const String baseUrl = "http://192.168.x.x:5000";
     ```

     > ⚠️ Use your **system’s local network IP**, not just `localhost`, especially if testing on a physical mobile device.

4. Run the Flutter app:

   ```bash
   flutter run
   ```

---

## 🔄 Running the Complete Application

1. Start Backend First

   ```bash
   cd skillswap_backend
   npm start
   ```

2. Then Start Frontend

   ```bash
   cd ../skillswap_flutter
   flutter run
   ```

3. Ensure both are connected properly

   * Backend: `http://localhost:5000` or `http://192.168.x.x:5000`
   * Frontend API: Updated in the data file



## 🧠 Features

* 🔑 User Authentication (JWT)
* 👤 Skill Profile Management
* 🔁 Real-Time Skill Exchange
* 🧩 Chat and Collaboration
* 🤖 Gemini AI Integration (for skill suggestions and recommendations)
* 📊 Express.js + MongoDB Backend
* 🎨 Flutter Modern UI



## 🧰 Tech Stack

| Layer              | Technology             |
| ------------------ | ---------------------- |
| **Frontend**       | Flutter (Dart)         |
| **Backend**        | Node.js, Express.js    |
| **Database**       | MongoDB (Mongoose ORM) |
| **AI Integration** | Google Gemini AI       |
| **Auth**           | JWT (JSON Web Tokens)  |



## 🧾 Notes

* Always **start the backend first** before running the frontend.
* Use your **local IP** (not localhost) when testing on mobile.
* Store sensitive data (like API keys) securely in the `.env` file.
* If you deploy, update the `baseUrl` in the Flutter app to your production server URL.


## 🧑‍💻 Author

Chaithanya Neeluri
📍 Dharmavaram, India
💼 Passionate Developer | Tech Learner
📧 neelurichaithanya@gmail.com

## Co-Author

 Jagan Thappetla
📍 Kadapa, India
📧 t.jagant.jagan1234@gmail.com
 

