import React, { useState } from 'react';
import { DatePicker, Select, Table, Button, Card, Row, Col } from 'antd';
import { getReportePrestamos } from '../services/reportService';
import dayjs from 'dayjs';

const { RangePicker } = DatePicker;

const ReportePrestamos = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filters, setFilters] = useState({
    fecha_inicio: dayjs().subtract(1, 'month').format('YYYY-MM-DD'),
    fecha_fin: dayjs().format('YYYY-MM-DD'),
    estado: 'Activo'
  });

  const generarReporte = async () => {
    setLoading(true);
    try {
      const reporte = await getReportePrestamos(filters);
      setData(reporte);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleDateChange = (dates) => {
    if (dates) {
      setFilters({
        ...filters,
        fecha_inicio: dates[0].format('YYYY-MM-DD'),
        fecha_fin: dates[1].format('YYYY-MM-DD')
      });
    }
  };

  const columns = [
    { title: 'ID Préstamo', dataIndex: 'prestamo_id', key: 'prestamo_id' },
    { title: 'Usuario', dataIndex: 'usuario', key: 'usuario' },
    { title: 'Libro', dataIndex: 'libro', key: 'libro' },
    { title: 'Código Barras', dataIndex: 'codigo_barras', key: 'codigo_barras' },
    { title: 'Fecha Préstamo', dataIndex: 'fecha_prestamo', key: 'fecha_prestamo' },
    { title: 'Fecha Devolución', dataIndex: 'fecha_devolucion_esperada', key: 'fecha_devolucion_esperada' },
    { 
      title: 'Estado', 
      dataIndex: 'estado', 
      key: 'estado',
      render: (text) => (
        <span style={{ color: text === 'Retrasado' ? 'red' : 'green' }}>
          {text}
        </span>
      )
    },
  ];

  return (
    <Card title="Reporte de Préstamos" style={{ margin: '20px' }}>
      <Row gutter={16} style={{ marginBottom: '20px' }}>
        <Col span={8}>
          <RangePicker 
            style={{ width: '100%' }}
            defaultValue={[dayjs().subtract(1, 'month'), dayjs()]}
            onChange={handleDateChange}
          />
        </Col>
        <Col span={4}>
          <Select
            style={{ width: '100%' }}
            defaultValue="Activo"
            onChange={(value) => setFilters({...filters, estado: value})}
            options={[
              { value: 'Activo', label: 'Activos' },
              { value: 'Retrasado', label: 'Retrasados' },
              { value: 'Todos', label: 'Todos' }
            ]}
          />
        </Col>
        <Col span={4}>
          <Button 
            type="primary" 
            onClick={generarReporte}
            loading={loading}
          >
            Generar Reporte
          </Button>
        </Col>
      </Row>
      
      <Table 
        columns={columns} 
        dataSource={data} 
        rowKey="prestamo_id"
        loading={loading}
        pagination={{ pageSize: 10 }}
        scroll={{ x: true }}
      />
    </Card>
  );
};

export default ReportePrestamos;