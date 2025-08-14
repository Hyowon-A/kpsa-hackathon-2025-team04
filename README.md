# 🩺 KPSA Hackathon 2025 – Backend (Team 04)

This backend powers **YakCare+**, a personalized health scoring and supplement recommendation service built for the **KPSA Hackathon 2025**. It enables users to receive health assessments based on both subjective and objective inputs, and integrates GPT to deliver personalized supplement ingredient recommendations.

---

## 🧠 Backend Features

### ✅ Health Scoring System
- Computes a **composite health score (0–100)** using:
  - Blood pressure (systolic/diastolic)
  - Fasting glucose
  - BMI
  - Liver function (AST, ALT)
  - Kidney function (eGFR)
  - Past conditions, medications, supplements, family history
- Assigns risk levels to each metric: `Normal`, `Caution`, or `Danger`
- Supports both uploaded health reports and survey-based data input

---

### 🤖 GPT-Driven Ingredient Recommendation
- Leverages **OpenAI GPT-4o** to suggest **2 personalized supplement ingredients** based on:
  - Demographics (age, gender), lifestyle, and existing health data
- Output is limited to a curated whitelist of 20+ functional ingredients
- Results are parsed and matched to real-world supplements in the database

---

### 🔍 Smart Supplement Matching (Relational DB Query)
- **Schema Design:**
  - `medicines`: Supplement product catalog
  - `ingredients`: Active ingredient list
  - `medicines_ingredients`: Many-to-many mapping table
- Returns **up to 3 random supplements** that include **at least one** of the recommended ingredients
- Product images are hosted on **AWS S3** and returned with metadata for frontend rendering

---

### 💊 Booking System
- Users can schedule 1:1 consultations with registered pharmacists
- `booking` table captures:
  - User ID, Pharmacy ID, Appointment time, User notes, Timestamps
- Each pharmacist is tied to a registered `pharmacy` account

---

### 🔐 Authentication
- **JWT-based** token authentication system
- Secures protected endpoints (e.g., health surveys, bookings)
- Supports user registration and login flows

---

## 🗃️ Database Schema

![YakCare DB schema](https://github.com/user-attachments/assets/01208074-105c-47e9-883a-9aa771c8dce3)

---

## ⚙️ Tech Stack

| Layer               | Tech                                               |
|---------------------|----------------------------------------------------|
| **Backend Framework** | Python + Flask                                     |
| **ORM**             | SQLAlchemy (PostgreSQL)                            |
| **Database**        | PostgreSQL via **AWS RDS**                         |
| **Authentication**  | JWT                                                |
| **AI Integration**  | OpenAI GPT-4o (Mini)                               |
| **Image Hosting**   | AWS S3 (product image delivery)                    |
