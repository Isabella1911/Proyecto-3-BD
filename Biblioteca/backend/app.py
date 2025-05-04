from flask import Flask
from flask_cors import CORS  # 👈 importa CORS
from database import Database
from routes import api
from config import Config

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    
    # Permitir CORS para que React pueda conectarse
    CORS(app)

    Database.initialize()
    app.register_blueprint(api, url_prefix='/api')

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)
