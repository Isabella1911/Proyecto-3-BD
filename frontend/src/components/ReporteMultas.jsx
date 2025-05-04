import React, { useState } from 'react';
import { Table, Card, Button } from 'antd';
import { getReporteMultas } from '../services/reportService';

const ReporteMultas = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);

  const generarReporte = async () => {
    setLoading(true);
    try {
      const reporte = await getReporteMultas();
      setData(reporte);
    } catch (error) {
      console.error('Error al obtener reporte de multas:', error);
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { title: 'Usuario', dataIndex: 'usuario', key: 'usuario' },
    { title: 'Correo', dataIndex: 'email', key: 'email' },
    { title: 'Total Multas (Q)', dataIndex: 'total_multas', key: 'total_multas' },
  ];

  return (
    <Card title="Reporte de Multas Pendientes" style={{ margin: '20px' }}>
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

export default ReporteMultas;
