import React, { useState } from 'react';
import { Table, Card, Button, InputNumber, Row, Col } from 'antd';
import { getReporteLibrosPopulares } from '../services/reportService';

const ReporteLibrosPopulares = () => {
  const [data, setData] = useState([]);
  const [limit, setLimit] = useState(10);
  const [loading, setLoading] = useState(false);

  const generarReporte = async () => {
    setLoading(true);
    try {
      const reporte = await getReporteLibrosPopulares(limit);
      setData(reporte);
    } catch (error) {
      console.error('Error al obtener libros populares:', error);
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { title: 'ID', dataIndex: 'libro_id', key: 'libro_id' },
    { title: 'Título', dataIndex: 'titulo', key: 'titulo' },
    { title: 'Cantidad de Préstamos', dataIndex: 'cantidad_prestamos', key: 'cantidad_prestamos' },
  ];

  return (
    <Card title="Reporte de Libros Más Populares" style={{ margin: '20px' }}>
      <Row gutter={16} style={{ marginBottom: '20px' }}>
        <Col span={4}>
          <InputNumber
            min={1}
            max={100}
            defaultValue={10}
            value={limit}
            onChange={(value) => setLimit(value)}
            style={{ width: '100%' }}
          />
        </Col>
        <Col span={4}>
          <Button type="primary" onClick={generarReporte} loading={loading}>
            Generar Reporte
          </Button>
        </Col>
      </Row>

      <Table
        columns={columns}
        dataSource={data}
        rowKey="libro_id"
        loading={loading}
        pagination={{ pageSize: 10 }}
      />
    </Card>
  );
};

export default ReporteLibrosPopulares;
