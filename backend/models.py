from database import Database

class Usuario:
    @staticmethod
    def get_all():
        conn = Database.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Usuarios")
        usuarios = cursor.fetchall()
        cursor.close()
        Database.return_connection(conn)
        return usuarios

class Libro:
    @staticmethod
    def get_by_id(libro_id):
        conn = Database.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Libros WHERE libro_id = %s", (libro_id,))
        libro = cursor.fetchone()
        cursor.close()
        Database.return_connection(conn)
        return libro

# Añadir la demas base de datos