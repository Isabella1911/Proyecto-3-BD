import React from 'react';
import { Card, Typography } from 'antd';

const { Title, Paragraph } = Typography;

const Home = () => {
  return (
    <Card style={{ margin: '40px auto', maxWidth: '800px', textAlign: 'center' }}>
      <Title>Sistema de Biblioteca</Title>
      <Paragraph>
        Bienvenida al sistema de gestión de biblioteca. Desde aquí puedes consultar los distintos reportes sobre préstamos, libros, multas, eventos y disponibilidad.
      </Paragraph>
      <Paragraph>
        Usa el menú o accede a la pestaña de <strong>Reportes</strong> para comenzar.
      </Paragraph>
    </Card>
  );
};

export default Home;
