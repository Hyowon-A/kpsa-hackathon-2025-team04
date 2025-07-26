from .auth import auth_bp
from .booking import booking_bp
from .survey import survey_bp

def register_routes(app):
    app.register_blueprint(auth_bp)
    app.register_blueprint(booking_bp)
    app.register_blueprint(survey_bp)