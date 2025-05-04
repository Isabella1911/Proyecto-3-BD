import psycopg2
from psycopg2 import pool
from config import Config

class Database:
    __connection_pool = None

    @classmethod
    def initialize(cls):
        cls.__connection_pool = psycopg2.pool.SimpleConnectionPool(
            1, 10,
            host=Config.DB_HOST,
            database=Config.DB_NAME,
            user=Config.DB_USER,
            password=Config.DB_PASSWORD,
            port=Config.DB_PORT
        )

    @classmethod
    def get_connection(cls):
        return cls.__connection_pool.getconn()

    @classmethod
    def return_connection(cls, connection):
        cls.__connection_pool.putconn(connection)

    @classmethod
    def close_all_connections(cls):
        cls.__connection_pool.closeall()