import React, { useState } from 'react';
import { Table, Card, Button } from 'antd';
import { getReporteEventos } from '../services/reportService';

const ReporteEventos = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);

  const generarReporte = async () => {
    setLoading(true);
    try {
      const reporte = await getReporteEventos();
      setData(reporte);
    } catch (error) {
      console.error('Error al obtener reporte de eventos:', error);
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { title: 'Usuario', dataIndex: 'usuario', key: 'usuario' },
    { title: 'Correo', dataIndex: 'email', key: 'email' },
    { title: 'Cantidad de Eventos', dataIndex: 'cantidad_eventos', key: 'cantidad_eventos' },
  ];

  return (
    <Card title="Reporte de Participación en Eventos" style={{ margin: '20px' }}>
      <Button type="primary" onClick={generarReporte} loading={loading} style={{ marginBottom: '20px' }}>
        Generar Reporte
      </Button>

      <Table
        columns={columns}
        dataSource={data}
        rowKey={(record) => record.usuario + record.correo}
        loading={loading}
        pagination={{ pageSize: 10 }}
      />
    </Card>
  );
};

export default ReporteEventos;
