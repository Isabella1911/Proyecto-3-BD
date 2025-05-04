import api from './api';

export const getReportePrestamos = async (filters) => {
  try {
    const response = await api.get('/reportes/prestamos', {
      params: filters,
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching report:', error);
    throw error;
  }
};
export const getReporteLibrosPopulares = async (limit = 10) => {
  const response = await api.get('/reportes/libros-populares', {
    params: { limit }
  });
  return response.data;
};

export const getReporteMultas = async () => {
  try {
    const response = await api.get('/reportes/multas-pendientes');
    return response.data;
  } catch (error) {
    console.error('Error fetching report:', error);
    throw error;
  }
};

export const getReporteDisponibilidad = async () => {
  const response = await api.get('/reportes/disponibilidad');
  return response.data;
};

export const getReporteEventos = async () => {
  const response = await api.get('/reportes/eventos');
  return response.data;
};
