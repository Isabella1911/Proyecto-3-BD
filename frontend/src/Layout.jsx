import React from 'react';
import { Layout, Menu } from 'antd';
import { Link, useLocation } from 'react-router-dom';

const { Header, Content, Footer } = Layout;

const MainLayout = ({ children }) => {
  const location = useLocation();

  return (
    <Layout className="layout">
      <Header>
        <div style={{ float: 'left', color: 'white', fontWeight: 'bold', fontSize: '18px', marginRight: '24px' }}>
          Sistema de Biblioteca
        </div>
        <Menu
          theme="dark"
          mode="horizontal"
          selectedKeys={[location.pathname]}
          style={{ lineHeight: '64px' }}
        >
          <Menu.Item key="/">
            <Link to="/">Inicio</Link>
          </Menu.Item>
          <Menu.Item key="/reportes">
            <Link to="/reportes">Reportes</Link>
          </Menu.Item>
        </Menu>
      </Header>

      <Content style={{ padding: '0 50px', minHeight: 'calc(100vh - 134px)' }}>
        {children}
      </Content>

      <Footer style={{ textAlign: 'center' }}>
        Sistema de Biblioteca ©2025
      </Footer>
    </Layout>
  );
};

export default MainLayout;
