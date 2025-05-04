from flask import Blueprint, request, jsonify
from report_service import ReportService

api = Blueprint('api', __name__)

@api.route('/reportes/prestamos', methods=['GET'])
def reporte_prestamos():
    fecha_inicio = request.args.get('fecha_inicio')
    fecha_fin = request.args.get('fecha_fin')
    categoria_id = request.args.get('categoria_id')
    estado = request.args.get('estado')
    
    try:
        reporte = ReportService.generar_reporte_prestamos(
            fecha_inicio, fecha_fin, categoria_id, estado
        )
        return jsonify(reporte)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
@api.route('/reportes/libros-populares', methods=['GET'])
def reporte_libros_populares():
    try:
        limit = request.args.get('limit', default=10, type=int)
        reporte = ReportService.generar_reporte_libros_populares(limit)
        return jsonify(reporte)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api.route('/reportes/multas-pendientes')
def obtener_reporte_multas():
    data = ReportService.generar_reporte_multas()
    return jsonify(data)


@api.route('/reportes/disponibilidad', methods=['GET'])
def reporte_disponibilidad():
    try:
        reporte = ReportService.generar_reporte_disponibilidad()
        return jsonify(reporte)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
@api.route('/reportes/eventos', methods=['GET'])
def reporte_eventos():
    try:
        reporte = ReportService.generar_reporte_eventos()
        return jsonify(reporte)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Añadir las rutas para otros reportes (etsan indicadas en report_service)
@api.route('/')
def index():
    return 'API del Proyecto 3 funcionando 🚀'
