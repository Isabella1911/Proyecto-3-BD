import React, { useState } from 'react';
import { Table, Card, Button } from 'antd';
import { getReporteDisponibilidad } from '../services/reportService';

const ReporteDisponibilidad = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);

  const generarReporte = async () => {
    setLoading(true);
    try {
      const reporte = await getReporteDisponibilidad();
      setData(reporte);
    } catch (error) {
      console.error('Error al obtener reporte de disponibilidad:', error);
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { title: 'Título', dataIndex: 'titulo', key: 'titulo' },
    { title: 'ISBN', dataIndex: 'isbn', key: 'isbn' },
    { title: 'Total Ejemplares', dataIndex: 'total_ejemplares', key: 'total_ejemplares' },
    { title: 'Disponibles', dataIndex: 'ejemplares_disponibles', key: 'ejemplares_disponibles' },
    { title: 'No Disponibles', dataIndex: 'ejemplares_no_disponibles', key: 'ejemplares_no_disponibles' },
  ];

  return (
    <Card title="Reporte de Disponibilidad de Libros" style={{ margin: '20px' }}>
      <Button
        type="primary"
        onClick={generarReporte}
        loading={loading}
        style={{ marginBottom: '20px' }}
      >
        Generar Reporte
      </Button>

      <Table
        columns={columns}
        dataSource={data}
        rowKey={(record) => record.titulo + record.isbn}
        loading={loading}
        pagination={{ pageSize: 10 }}
      />
    </Card>
  );
};

export default ReporteDisponibilidad;
