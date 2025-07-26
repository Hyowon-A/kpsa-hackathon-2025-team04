from flask import Blueprint, request, jsonify, make_response
from utils.security import generate_jwt, token_required
from sqlalchemy import select
from db.models import db, Booking
from datetime import datetime, timedelta


booking_bp = Blueprint("booking", __name__, url_prefix="/booking")


@booking_bp.route("/available", methods=['GET'])
def available_slots():
    date_str = request.args.get("date", datetime.now().strftime("%Y-%m-%d"))
    pharmacy_id = int(request.args.get("pharmacy_id"))
    
    start_time = datetime.strptime(f"{date_str} 09:00", "%Y-%m-%d %H:%M")
    end_time = datetime.strptime(f"{date_str} 17:00", "%Y-%m-%d %H:%M")
    
    all_slots = []
    current_time = start_time
    while current_time < end_time:
        all_slots.append(current_time)
        current_time += timedelta(minutes=30)

    booked_slots = (
        db.session.query(Booking.booked_time)
        .filter(
            Booking.pharmacy_id == pharmacy_id,
            Booking.booked_time >= start_time,
            Booking.booked_time < end_time
        )
        .all()
    )
    booked_times = {time for (time,) in booked_slots}
    
    available = [slot.strftime("%H:%M") for slot in all_slots if slot not in booked_times]
    
    return jsonify({"date": date_str, "available_slots": available})


@booking_bp.route("/create", methods=['POST'])
@token_required
def create_booking(current_user, user_id):
    try:
        pharmacy_id = request.json.get("pharmacy_id")
        date_str = request.json.get("date", datetime.now().strftime("%Y-%m-%d"))
        booked_time_str = request.json.get("time")
        comment = request.json.get("comment", "")

        if not pharmacy_id or not booked_time_str:
            return jsonify({"message": "Missing required fields (pharmacy_id or time)."}), 400

        try:
            pharmacy_id = int(pharmacy_id)
        except ValueError:
            return jsonify({"message": "Invalid pharmacy_id"}), 400

        # Convert date + time to datetime
        booked_time = datetime.strptime(f"{date_str} {booked_time_str}", "%Y-%m-%d %H:%M")

        new_booking = Booking(
            user_id=user_id,
            pharmacy_id=pharmacy_id,
            booked_time=booked_time,
            comment=comment
        )
        db.session.add(new_booking)
        db.session.commit()

        return jsonify({
            "message": "Booking successful",
            "booking_id": new_booking.id,
            "pharmacy_id": pharmacy_id,
            "date": date_str,
            "time": booked_time_str
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({"message": "Booking failed", "error": str(e)}), 500