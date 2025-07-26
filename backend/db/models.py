from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from db import Base
from sqlalchemy.dialects.postgresql import JSONB

db = SQLAlchemy()


class Account(Base):
    __tablename__ = "accounts"
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(100))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    users = db.relationship("User", back_populates="account", lazy=True)
    pharmacists = db.relationship("Pharmacist", back_populates="account", lazy=True)

    def __repr__(self):
        return f"<Account {self.id} - {self.email}>"


class User(Base):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    account_id = db.Column(db.Integer, db.ForeignKey("accounts.id"), nullable=False)
    name = db.Column(db.String(100))
    gender = db.Column(db.String(100))
    dob = db.Column(db.DateTime)
    occupation = db.Column(db.String(150))
    work_style = db.Column(db.String(150))

    account = db.relationship("Account", back_populates="users")
    survey_responses = db.relationship("SurveyResponse", back_populates="user", lazy=True)
    reports = db.relationship("Report", back_populates="user", lazy=True)
    bookings = db.relationship("Booking", back_populates="user", lazy=True)

    def __repr__(self):
        return f"<User {self.id} - {self.name}>"


class Pharmacist(Base):
    __tablename__ = "pharmacists"
    
    id = db.Column(db.Integer, primary_key=True)
    account_id = db.Column(db.Integer, db.ForeignKey("accounts.id"), nullable=False)
    name = db.Column(db.String(100))
    license_number = db.Column(db.String(150))

    account = db.relationship("Account", back_populates="pharmacists")
    pharmacies = db.relationship("Pharmacy", back_populates="pharmacist", lazy=True)

    def __repr__(self):
        return f"<Pharmacist {self.id} - {self.name}>"


class Pharmacy(Base):
    __tablename__ = "pharmacies"

    id = db.Column(db.Integer, primary_key=True)
    pharmacist_id = db.Column(db.Integer, db.ForeignKey("pharmacists.id"), nullable=False)
    name = db.Column(db.String(100))
    address = db.Column(db.String(255))

    pharmacist = db.relationship("Pharmacist", back_populates="pharmacies")
    bookings = db.relationship("Booking", back_populates="pharmacy", lazy=True)

    def __repr__(self):
        return f"<Pharmacy {self.id} - {self.name}>"


class Booking(Base):
    __tablename__ = "booking"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    pharmacy_id = db.Column(db.Integer, db.ForeignKey("pharmacies.id"), nullable=False)
    booked_time = db.Column(db.DateTime, nullable=False)
    comment = db.Column(db.String(255))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship("User", back_populates="bookings")
    pharmacy = db.relationship("Pharmacy", back_populates="bookings")

    def __repr__(self):
        return f"<Booking {self.id} - User {self.user_id} at Pharmacy {self.pharmacy_id}>"


class Report(Base):
    __tablename__ = "reports"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    image_url = db.Column(db.String(500), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship("User", back_populates="reports")

    def __repr__(self):
        return f"<Report {self.id} - User {self.user_id}>"


class SurveyResponse(Base):
    __tablename__ = "survey_responses"
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    responses = db.Column(JSONB, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship("User", back_populates="survey_responses")

    def __repr__(self):
        return f"<SurveyResponse {self.id} - User {self.user_id}>"
