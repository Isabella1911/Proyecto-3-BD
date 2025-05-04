from database import Database

class ReportService:
    @staticmethod
    def generar_reporte_prestamos(fecha_inicio, fecha_fin, categoria_id=None, estado=None):
        conn = Database.get_connection()
        cursor = conn.cursor()
        
        query = """
            SELECT p.prestamo_id, u.nombre || ' ' || u.apellido as usuario, 
                   l.titulo as libro, e.codigo_barras,
                   p.fecha_prestamo, p.fecha_devolucion_esperada,
                   CASE WHEN p.fecha_devolucion_esperada < CURRENT_DATE THEN 'Retrasado' ELSE 'Activo' END as estado
            FROM Prestamos p
            JOIN DetallePrestamos dp ON p.prestamo_id = dp.prestamo_id
            JOIN Ejemplares e ON dp.ejemplar_id = e.ejemplar_id
            JOIN Libros l ON e.libro_id = l.libro_id
            JOIN Usuarios u ON p.usuario_id = u.usuario_id
            JOIN UsuarioCategorias uc ON u.usuario_id = uc.usuario_id
            WHERE p.fecha_prestamo BETWEEN %s AND %s
        """
        
        params = [fecha_inicio, fecha_fin]
        
        if categoria_id:
            query += " AND uc.categoria_id = %s"
            params.append(categoria_id)

        if estado and estado != 'Todos':
            if estado == 'Retrasado':
                query += " AND p.fecha_devolucion_esperada < CURRENT_DATE"
            else:
                query += " AND p.fecha_devolucion_esperada >= CURRENT_DATE"
        
        cursor.execute(query, params)
        columnas = [desc[0] for desc in cursor.description]
        resultados = cursor.fetchall()
        reporte = [dict(zip(columnas, row)) for row in resultados]

        cursor.close()
        Database.return_connection(conn)
        return reporte

    @staticmethod
    def generar_reporte_libros_populares(limit=10):
        conn = Database.get_connection()
        cursor = conn.cursor()

        query = """
            SELECT 
                l.libro_id,
                l.titulo,
                COUNT(*) AS cantidad_prestamos
            FROM prestamos p
            JOIN detalleprestamos dp ON p.prestamo_id = dp.prestamo_id
            JOIN ejemplares e ON dp.ejemplar_id = e.ejemplar_id
            JOIN libros l ON e.libro_id = l.libro_id
            GROUP BY l.libro_id, l.titulo
            ORDER BY cantidad_prestamos DESC
            LIMIT %s;
        """
        cursor.execute(query, (limit,))
        columnas = [desc[0] for desc in cursor.description]
        resultados = cursor.fetchall()
        reporte = [dict(zip(columnas, row)) for row in resultados]

        cursor.close()
        Database.return_connection(conn)
        return reporte

    @staticmethod
    def generar_reporte_multas():
        conn = Database.get_connection()
        cursor = conn.cursor()

        query = """
            SELECT 
                u.nombre || ' ' || u.apellido AS usuario,
                u.email,
                SUM(m.monto) AS total_multas
            FROM multas m
            JOIN prestamos p ON m.prestamo_id = p.prestamo_id
            JOIN usuarios u ON p.usuario_id = u.usuario_id
            WHERE m.pagada = FALSE
            GROUP BY u.nombre, u.apellido, u.email
            ORDER BY total_multas DESC;
        """

        cursor.execute(query)
        columnas = [desc[0] for desc in cursor.description]
        resultados = cursor.fetchall()
        reporte = [dict(zip(columnas, row)) for row in resultados]

        cursor.close()
        Database.return_connection(conn)
        return reporte

    @staticmethod
    def generar_reporte_disponibilidad():
        conn = Database.get_connection()
        cursor = conn.cursor()

        query = """
        SELECT 
            titulo,
            isbn,
            total_ejemplares,
            ejemplares_disponibles,
            ejemplares_no_disponibles
        FROM DisponibilidadLibros
        ORDER BY ejemplares_disponibles DESC;
    """

        cursor.execute(query)
        resultados = cursor.fetchall()
        columnas = [desc[0] for desc in cursor.description]
        reporte = [dict(zip(columnas, row)) for row in resultados]
        cursor.close()
        Database.return_connection(conn)
        return reporte

    @staticmethod
    def generar_reporte_eventos():
        conn = Database.get_connection()
        cursor = conn.cursor()

        query = """
            SELECT 
                u.nombre || ' ' || u.apellido AS usuario,
                u.email,
                COUNT(pe.evento_id) AS cantidad_eventos
            FROM usuarios u
            JOIN participacioneventos pe ON u.usuario_id = pe.usuario_id
            GROUP BY u.nombre, u.apellido, u.email
            ORDER BY cantidad_eventos DESC;
        """

        cursor.execute(query)
        columnas = [desc[0] for desc in cursor.description]
        resultados = cursor.fetchall()
        reporte = [dict(zip(columnas, row)) for row in resultados]

        cursor.close()
        Database.return_connection(conn)
        return reporte
