from db import Base, engine
from db import models

def create_tables():
    # Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    print("All tables created!")