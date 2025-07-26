from flask import Flask
from db.models import db
from routes import register_routes
from dotenv import load_dotenv
import os

def create_app():
    app = Flask(__name__)
    
    load_dotenv()
    
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)

    register_routes(app)

    return app

app = create_app()

if __name__ == "__main__":
    app.run(port=5000, debug=True)