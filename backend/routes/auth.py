from flask import Blueprint, request, jsonify, make_response
from utils.security import generate_jwt, token_required
from sqlalchemy import select
from db.models import db, Account, User
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash


auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


@auth_bp.route("/signup", methods=["POST"])
def signup():
    email = request.json.get("email")
    password = request.json.get("password")
    name = request.json.get("name")
    dob = request.json.get("dob")
    gender = request.json.get("gender")
    occupation = request.json.get("occupation")
    work_style = request.json.get("work_style")
    
    existing_account = db.session.query(Account).filter_by(email=email).first()
    if existing_account:
        return jsonify({"message": "User already exists"}), 409
    
    try:
        hashed_password = generate_password_hash(password)
        
        new_account = Account(
            email = email,
            password_hash = hashed_password,
            role = "환자"
        )
        db.session.add(new_account)
        db.session.commit()
        
        new_user = User(
            account_id = new_account.id,
            name = name,
            gender = gender,
            dob = datetime.strptime(dob, "%Y-%m-%d"),
            occupation = occupation,
            work_style = work_style
        )
        db.session.add(new_user)
        db.session.commit()
    
        return jsonify({"message": "Signup successful"}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Signup failed", "error": str(e)}), 500
    

@auth_bp.route("/login", methods=["POST"])
def login():
    email = request.json.get("email")
    password = request.json.get("password")
    
    if not email or not password:
        return jsonify({"message": "Email and password are required"}), 400
    
    try:
        account = db.session.query(Account).filter_by(email=email).first()
        if account and check_password_hash(account.password_hash, password):
            token = generate_jwt({"email": email, "user_id": account.id})
            res = make_response(jsonify({"message": "Login successful", "accessToken": token}))
            # res.set_cookie("jwt", token, httponly=True, samesite="Lax", secure=False)
            return res
        else:
            return jsonify({"message": "Invalid credentials"}), 401
    except Exception as e:
        return jsonify({"message": "DB request failed", "error": str(e)}), 500