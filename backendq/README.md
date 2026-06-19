# Online Quiz App — Backend

A RESTful API for the Online Quiz App built with **Node.js**, **Express**, and **MongoDB**.

---

## Prerequisites
- Node.js >= 16
- MongoDB running locally (`mongod`)

---

## Setup & Run

```bash
# 1. Navigate to backend folder
cd backendq

# 2. Install dependencies
npm install

# 3. Seed the database (creates users + sample quizzes)
npm run seed

# 4. Start the server (development with auto-reload)
npm run dev

# OR: start in production mode
npm start
```

Server will run at: `http://localhost:5000`

---

## Default Login Credentials (after seed)

| Role    | Email                  | Password     |
|---------|------------------------|--------------|
| Teacher | teacher@quiz.com       | password123  |
| Student | student1@quiz.com      | password123  |
| Student | student2@quiz.com      | password123  |

---

## API Endpoints

### Auth
| Method | Endpoint              | Description         | Auth |
|--------|-----------------------|---------------------|------|
| POST   | /api/auth/register    | Register a user     | No   |
| POST   | /api/auth/login       | Login, get JWT      | No   |
| GET    | /api/auth/me          | Get current user    | Yes  |

### Quizzes
| Method | Endpoint                  | Description                   | Auth         |
|--------|---------------------------|-------------------------------|--------------|
| GET    | /api/quizzes              | List all active quizzes       | Yes          |
| GET    | /api/quizzes/categories   | Get distinct categories       | Yes          |
| GET    | /api/quizzes/teacher/mine | Teacher's own quizzes         | Teacher only |
| GET    | /api/quizzes/:id          | Get quiz with questions       | Yes          |
| POST   | /api/quizzes              | Create a quiz                 | Teacher only |
| PUT    | /api/quizzes/:id          | Update a quiz                 | Teacher only |
| DELETE | /api/quizzes/:id          | Delete a quiz                 | Teacher only |

### Results
| Method | Endpoint                    | Description               | Auth         |
|--------|-----------------------------|---------------------------|--------------|
| POST   | /api/results                | Submit quiz attempt       | Yes          |
| GET    | /api/results/my             | My quiz history           | Yes          |
| GET    | /api/results/quiz/:quizId   | All results for a quiz    | Teacher only |

---

## Project Structure

```
backendq/
├── config/
│   └── db.js           # MongoDB connection
├── middleware/
│   └── auth.js         # JWT protect + teacherOnly
├── models/
│   ├── User.js
│   ├── Quiz.js
│   └── Result.js
├── routes/
│   ├── auth.js
│   ├── quiz.js
│   └── result.js
├── .env
├── package.json
├── seed.js
└── server.js
```

---

## Environment Variables (`.env`)
```
PORT=5000
MONGO_URI=mongodb://localhost:27017/quizapp
JWT_SECRET=quizapp_super_secret_jwt_key_2024
JWT_EXPIRE=7d
```
