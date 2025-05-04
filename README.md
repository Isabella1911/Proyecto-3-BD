#  Sistema de Gestión de Biblioteca

Este proyecto es una plataforma completa para la gestión de una biblioteca, incluyendo usuarios, libros, préstamos, multas, reservas y eventos, con generación de reportes visuales.

##  Tecnologías Utilizadas

- **Backend**: Python  con Flask
- **Base de Datos**: PostgreSQL
- **Frontend**: React con Vite
- **UI**: Ant Design

---

## Instrucciones de Ejecución
- Crea la base de datos:

  CREATE DATABASE biblioteca;

- Carga la estructura y los datos de prueba:

  psql -U tu_usuario -d biblioteca -f estructura_tablas.sql

  psql -U tu_usuario -d biblioteca -f datos_iniciales.sql

- Backend (Flask)

  cd backend

  python -m venv venv

  source venv/bin/activate

  pip install -r requirements.txt

flask run

- Frontend

   cd frontend

   npm install

   npm run dev

# Funcionalidades del Sistema
- Gestión de usuarios y categorías
- Catálogo de libros y ejemplares
- Préstamos y devoluciones
- Reservas y participación en eventos
- Cálculo de multas pendientes
- Reportes:
    Libros populares
    Préstamos por libro
    Multas por usuario
    Participación en eventos
    Disponibilidad de libros

# Autores
* Anggelie Velásquez
* Mia  Fuentes 
* Isabella Obando

Curso: Bases de Datos 1

Docente: Ing. Bacilio

Universidad del Valle de Guatemala – 2025
