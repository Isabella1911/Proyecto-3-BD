-- SE RECOMIENDA CREAR UNA TABLA UNA POR UNA PARA QUE AL INSERTAR DATOS NO AFECTE EL SERIAL


-- Se crea una base de datos que soporte todos los caracteres especiales
CREATE DATABASE "Proyecto 3" WITH ENCODING 'UTF8' TEMPLATE template0;



-- Tabla de Usuarios (Socios de la biblio)
CREATE TABLE Usuarios (
    usuario_id SERIAL PRIMARY KEY,
    dpi VARCHAR(13) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    direccion VARCHAR(200) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_fecha_nacimiento CHECK (fecha_nacimiento < CURRENT_DATE)
);

-- Tabla de Categorías de Usuarios
CREATE TABLE CategoriasUsuarios (
    categoria_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    max_prestamos INT NOT NULL DEFAULT 3,
    dias_prestamo INT NOT NULL DEFAULT 7,
    CONSTRAINT chk_max_prestamos CHECK (max_prestamos > 0),
    CONSTRAINT chk_dias_prestamo CHECK (dias_prestamo > 0)
);

-- Relación entre Usuarios y Categorías (1:N)
CREATE TABLE UsuarioCategorias (
    usuario_id INT,
    categoria_id INT,
    fecha_asignacion DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (usuario_id, categoria_id),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (categoria_id) REFERENCES CategoriasUsuarios(categoria_id) ON DELETE RESTRICT
);

-- Tabla de Autores
CREATE TABLE Autores (
    autor_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE,
    nacionalidad VARCHAR(50),
    biografia TEXT,
    CONSTRAINT uq_autor UNIQUE (nombre, apellido)
);

-- Tabla de Editoriales
CREATE TABLE Editoriales (
    editorial_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(50),
    direccion VARCHAR(200),
    telefono VARCHAR(15),
    email VARCHAR(100),
    CONSTRAINT chk_editorial_email CHECK (email IS NULL OR email LIKE '%@%.%')
);

-- Tabla de Categorías de Libros (Géneros)
CREATE TABLE CategoriasLibros (
    categoria_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);

-- Tabla de Libros
CREATE TABLE Libros (
    libro_id SERIAL PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    subtitulo VARCHAR(200),
    editorial_id INT NOT NULL,
    anio_publicacion INT,
    idioma VARCHAR(30) NOT NULL DEFAULT 'Español',
    paginas INT,
    descripcion TEXT,
    fecha_adquisicion DATE NOT NULL DEFAULT CURRENT_DATE,
    precio DECIMAL(10, 2),
    FOREIGN KEY (editorial_id) REFERENCES Editoriales(editorial_id) ON DELETE RESTRICT,
    CONSTRAINT chk_anio_publicacion CHECK (anio_publicacion > 1000 AND anio_publicacion <= EXTRACT(YEAR FROM CURRENT_DATE)),
    CONSTRAINT chk_paginas CHECK (paginas > 0),
    CONSTRAINT chk_precio CHECK (precio > 0)
);

-- Tabla de relación entre Libros y Autores (N:M)
CREATE TABLE LibroAutores (
    libro_id INT,
    autor_id INT,
    rol VARCHAR(50) DEFAULT 'Autor principal',
    PRIMARY KEY (libro_id, autor_id),
    FOREIGN KEY (libro_id) REFERENCES Libros(libro_id) ON DELETE CASCADE,
    FOREIGN KEY (autor_id) REFERENCES Autores(autor_id) ON DELETE RESTRICT
);

-- Tabla de relación entre Libros y Categorías (N:M)
CREATE TABLE LibroCategorias (
    libro_id INT,
    categoria_id INT,
    PRIMARY KEY (libro_id, categoria_id),
    FOREIGN KEY (libro_id) REFERENCES Libros(libro_id) ON DELETE CASCADE,
    FOREIGN KEY (categoria_id) REFERENCES CategoriasLibros(categoria_id) ON DELETE RESTRICT
);

-- Tabla de Ejemplares (instancias fisicas de los libros)
CREATE TABLE Ejemplares (
    ejemplar_id SERIAL PRIMARY KEY,
    libro_id INT NOT NULL,
    codigo_barras VARCHAR(50) UNIQUE NOT NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'Disponible',
    ubicacion VARCHAR(100) NOT NULL,
    fecha_alta DATE NOT NULL DEFAULT CURRENT_DATE,
    notas TEXT,
    FOREIGN KEY (libro_id) REFERENCES Libros(libro_id) ON DELETE CASCADE,
    CONSTRAINT chk_estado CHECK (estado IN ('Disponible', 'Prestado', 'En reparación', 'Extraviado', 'Reservado'))
);

-- Tabla de Prestamos
CREATE TABLE Prestamos (
    prestamo_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    fecha_prestamo DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion_esperada DATE NOT NULL,
    fecha_devolucion_real DATE,
    estado VARCHAR(30) NOT NULL DEFAULT 'Activo',
    notas TEXT,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE RESTRICT,
    CONSTRAINT chk_fecha_prestamo CHECK (fecha_prestamo <= CURRENT_DATE),
    CONSTRAINT chk_fecha_devolucion_esperada CHECK (fecha_devolucion_esperada >= fecha_prestamo),
    CONSTRAINT chk_fecha_devolucion_real CHECK (fecha_devolucion_real IS NULL OR fecha_devolucion_real >= fecha_prestamo),
    CONSTRAINT chk_estado_prestamo CHECK (estado IN ('Activo', 'Devuelto', 'Retrasado', 'Perdido'))
);

-- Tabla de detalle de préstamos (relación entre préstamos y ejemplares)
CREATE TABLE DetallePrestamos (
    prestamo_id INT,
    ejemplar_id INT,
    PRIMARY KEY (prestamo_id, ejemplar_id),
    FOREIGN KEY (prestamo_id) REFERENCES Prestamos(prestamo_id) ON DELETE CASCADE,
    FOREIGN KEY (ejemplar_id) REFERENCES Ejemplares(ejemplar_id) ON DELETE RESTRICT
);

-- Tabla de Reservas
CREATE TABLE Reservas (
    reserva_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    libro_id INT NOT NULL, -- Reservamos libros, no ejemplares específicos
    fecha_reserva DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_limite DATE NOT NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (libro_id) REFERENCES Libros(libro_id) ON DELETE CASCADE,
    CONSTRAINT chk_fecha_limite CHECK (fecha_limite >= fecha_reserva),
    CONSTRAINT chk_estado_reserva CHECK (estado IN ('Pendiente', 'Completada', 'Cancelada', 'Expirada'))
);

-- Tabla de Multas
CREATE TABLE Multas (
    multa_id SERIAL PRIMARY KEY,
    prestamo_id INT NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    fecha_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_fin DATE,
    pagada BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (prestamo_id) REFERENCES Prestamos(prestamo_id) ON DELETE CASCADE,
    CONSTRAINT chk_monto_multa CHECK (monto > 0),
    CONSTRAINT chk_fecha_fin CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

-- Tabla de Comentarios/Reseñas (usuarios pueden dejar comentarios sobre libros que prestan)
CREATE TABLE Comentarios (
    comentario_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL,
    libro_id INT NOT NULL,
    calificacion INT,
    comentario TEXT,
    fecha_comentario TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (libro_id) REFERENCES Libros(libro_id) ON DELETE CASCADE,
    CONSTRAINT chk_calificacion CHECK (calificacion IS NULL OR (calificacion >= 1 AND calificacion <= 5))
);

-- Vista para ver disponibilidad de libros (atributo derivado)
CREATE VIEW DisponibilidadLibros AS
SELECT 
    l.libro_id,
    l.titulo,
    l.isbn,
    COUNT(e.ejemplar_id) AS total_ejemplares,
    SUM(CASE WHEN e.estado = 'Disponible' THEN 1 ELSE 0 END) AS ejemplares_disponibles,
    COUNT(e.ejemplar_id) - SUM(CASE WHEN e.estado = 'Disponible' THEN 1 ELSE 0 END) AS ejemplares_no_disponibles
FROM Libros l
JOIN Ejemplares e ON l.libro_id = e.libro_id
GROUP BY l.libro_id, l.titulo, l.isbn;

-- Tabla de Eventos de la Biblioteca
CREATE TABLE EventosBiblioteca (
    evento_id SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    ubicacion VARCHAR(100) NOT NULL,
    aforo_maximo INT,
    organizador VARCHAR(100),
    CONSTRAINT chk_fecha_evento CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT chk_aforo CHECK (aforo_maximo > 0)
);

-- Tabla de Participación en Eventos (relación N:M entre usuarios y eventos)
CREATE TABLE ParticipacionEventos (
    usuario_id INT,
    evento_id INT,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    asistio BOOLEAN DEFAULT NULL,
    PRIMARY KEY (usuario_id, evento_id),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (evento_id) REFERENCES EventosBiblioteca(evento_id) ON DELETE CASCADE
);

