# Complaint Management System (Full Stack)

## Overview

A full-stack Complaint Management System built using Flutter (Frontend) and Node.js with PostgreSQL (Backend).

This application allows users to submit complaints, upload images, and track their status, while admins can manage and resolve complaints efficiently.

---

## Key Features

### User Features

* User Registration and Login
* Submit complaints with images
* View complaint status
* Track complaint history

### Admin Features

* View all complaints
* Update complaint status
* Manage users

---

## Tech Stack

| Layer       | Technology             |
| ----------  | ---------------------- |
| Frontend    | Flutter                |
| Backend     | Node.js, Express.js    |
| Database    | PostgreSQL             |
| ORM         | Sequelize              |
| Auth        | JWT (Access + Refresh) |
| Validation  | Joi                    |
| Logging     | Winston                |
| Notification| Redis + BullMq         |

---

## Project Structure

```
complaint-app/
├── frontend/        # Flutter application
└── backend/         # Node.js API
    ├── src/
    │   ├── config/
    │   ├── middlewares/
    │   ├── modules/
    │   │   ├── auth/
    │   │   ├── complaint/
    │   │   └── notification/
    │   ├── utils/
    │   └── app.js
```

---

## Getting Started

### Backend Setup

```
cd backend
npm install
npm run dev
```

---

### Frontend Setup

```
cd frontend
flutter pub get
flutter run
```

---

## Environment Variables (Backend)

Create a `.env` file inside `backend/`:

```
PORT=5000
DB_NAME=your_database
DB_USER=your_username
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
JWT_SECRET=your_secret_key
```

---


## System Flow

```
Flutter App → API Routes → Middleware → Controller → Service → Database → Response
```

---

## Error Handling

```
Error → AppError → Global Error Handler → Logger → Client Response
```

---

## Security Features

* Password hashing using bcrypt
* JWT Authentication
* Role-based Authorization (User/Admin)
* Input validation using Joi
* Centralized error handling

---


## Future Improvements

* Password reset functionality
* Redis caching
* Cloud deployment (AWS / Render)

---

## Author

Jeewan Chaudhary
Full Stack Developer (Flutter + Node.js)

---

## License

This project is open-source and available for learning purposes.
