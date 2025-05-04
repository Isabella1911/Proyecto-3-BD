import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import Reportes from './pages/Reportes';
import MainLayout from './Layout'; // Asegúrate que el archivo se llame así

import './App.css';

function App() {
  return (
    <Router>
      <MainLayout>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/reportes" element={<Reportes />} />
        </Routes>
      </MainLayout>
    </Router>
  );
}

export default App;
