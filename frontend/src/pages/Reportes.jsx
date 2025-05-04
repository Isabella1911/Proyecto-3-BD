import React from 'react';
import { Tabs } from 'antd';
import ReportePrestamos from '../components/ReportePrestamos';
import ReporteLibrosPopulares from '../components/ReporteLibrosPopulares';
import ReporteMultas from '../components/ReporteMultas';
import ReporteEventos from '../components/ReporteEventos';
import ReporteDisponibilidad from '../components/ReporteDisponibilidad';

const items = [
  {
    key: '1',
    label: 'Préstamos',
    children: <ReportePrestamos />,
  },
  {
    key: '2',
    label: 'Libros Populares',
    children: <ReporteLibrosPopulares />,
  },
  {
    key: '3',
    label: 'Multas',
    children: <ReporteMultas />,
  },
  {
    key: '4',
    label: 'Eventos',
    children: <ReporteEventos />,
  },
  {
    key: '5',
    label: 'Disponibilidad',
    children: <ReporteDisponibilidad />,
  },
];

const Reportes = () => {
  return (
    <div style={{ padding: '24px' }}>
      <Tabs defaultActiveKey="1" items={items} />
    </div>
  );
};

export default Reportes;
