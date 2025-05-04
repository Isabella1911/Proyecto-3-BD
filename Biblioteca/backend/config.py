import os
from dotenv import load_dotenv

# Carga el archivo .env al entorno del sistema
load_dotenv()

class Config:
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_NAME = os.getenv('DB_NAME', 'Proyecto 3')
    DB_USER = os.getenv('DB_USER', 'postgres')
    DB_PASSWORD = os.getenv('DB_PASSWORD', 'tu_password')
    DB_PORT = os.getenv('DB_PORT', '5432')
