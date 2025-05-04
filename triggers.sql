-- TRIGGER 1: actualizar ek estado de ejemplar cuando se realiza un prestamo
CREATE OR REPLACE FUNCTION actualizar_estado_ejemplar_prestamo()
RETURNS TRIGGER AS $$
BEGIN
    -- Cuando se inserta un nuevo detalle de prestamo se debe actualizar el estado del ejemplar a 'Prestado'
    UPDATE Ejemplares 
    SET estado = 'Prestado' 
    WHERE ejemplar_id = NEW.ejemplar_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_actualizar_ejemplar_prestado
AFTER INSERT ON DetallePrestamos
FOR EACH ROW
EXECUTE FUNCTION actualizar_estado_ejemplar_prestamo();


-- TRIGGER 2: Actualizar estado de ejemplar y prestamo cuando se realiza una devolución
CREATE OR REPLACE FUNCTION registrar_devolucion_libro()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se actualiza la fecha de devolución real quiere decir que se devolvio el libro 
    IF OLD.fecha_devolucion_real IS NULL AND NEW.fecha_devolucion_real IS NOT NULL THEN
        -- Actualizar estado del prestamo a 'Devuelto'
        NEW.estado := 'Devuelto';
        
        -- Actualizar estado de todos los ejemplares asociados a un prestamo a 'Disponible'
        UPDATE Ejemplares 
        SET estado = 'Disponible'
        FROM DetallePrestamos
        WHERE DetallePrestamos.prestamo_id = NEW.prestamo_id 
          AND DetallePrestamos.ejemplar_id = Ejemplares.ejemplar_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_registrar_devolucion
BEFORE UPDATE ON Prestamos
FOR EACH ROW
EXECUTE FUNCTION registrar_devolucion_libro();


-- TRIGGER 3: Generar una multa automatica para prestamos retrasados
CREATE OR REPLACE FUNCTION generar_multa_automatica()
RETURNS TRIGGER AS $$
DECLARE
    dias_retraso INT;
    monto_por_dia DECIMAL(10,2) := 5.00; -- 5 quelzales por día de retraso
    monto_total DECIMAL(10,2);
BEGIN
    -- Si se cambia el estado a 'Retrasado'
    IF NEW.estado = 'Retrasado' AND OLD.estado != 'Retrasado' THEN
        -- Calcular días de retraso
        dias_retraso := EXTRACT(DAY FROM CURRENT_DATE - NEW.fecha_devolucion_esperada);
        
        -- Calcular monto total
        monto_total := dias_retraso * monto_por_dia;
        
        -- Insertar nueva multa
        INSERT INTO Multas (multa_id, prestamo_id, monto, fecha_inicio)
        VALUES (
            (SELECT COALESCE(MAX(multa_id), 0) + 1 FROM Multas), -- Generar ID auto-incrementado
            NEW.prestamo_id,
            monto_total,
            CURRENT_DATE
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_generar_multa
AFTER UPDATE ON Prestamos
FOR EACH ROW
EXECUTE FUNCTION generar_multa_automatica();


-- TRIGGER 4: Verificar la disponibilidad de ejemplares y el limite de prestamos por usuario
CREATE OR REPLACE FUNCTION verificar_prestamo()
RETURNS TRIGGER AS $$
DECLARE
    estado_ejemplar VARCHAR(30);
    num_prestamos_activos INT;
    max_prestamos_permitidos INT;
BEGIN
    -- Verificar que el ejemplar este en disponible
    SELECT estado INTO estado_ejemplar
    FROM Ejemplares
    WHERE ejemplar_id = NEW.ejemplar_id;
    
    IF estado_ejemplar != 'Disponible' THEN
        RAISE EXCEPTION 'Este ejemplar no está disponible para prestamo. Estado actual: %', estado_ejemplar;
    END IF;
    
    -- Obtener el número max de prestamos permitidos para el usuario
    SELECT cu.max_prestamos INTO max_prestamos_permitidos
    FROM UsuarioCategorias uc
    JOIN CategoriasUsuarios cu ON uc.categoria_id = cu.categoria_id
    WHERE uc.usuario_id = (
        SELECT usuario_id 
        FROM Prestamos 
        WHERE prestamo_id = NEW.prestamo_id
    )
    LIMIT 1;
    
    -- Si no tiene categoria asignada se usa un valor predeterminado
    IF max_prestamos_permitidos IS NULL THEN
        max_prestamos_permitidos := 3; -- valor predeterminado
    END IF;
    
    -- Contar prestamos activos del usuario
    SELECT COUNT(*) INTO num_prestamos_activos
    FROM Prestamos
    WHERE usuario_id = (
        SELECT usuario_id 
        FROM Prestamos 
        WHERE prestamo_id = NEW.prestamo_id
    )
    AND estado IN ('Activo', 'Retrasado');
    
    -- Verificar si excede el limite (considerando el nuevo prestamo que este acaba de realizar)
    IF num_prestamos_activos >= max_prestamos_permitidos THEN
        RAISE EXCEPTION 'El usuario ha alcanzado el limite máximo de prestamos permitidos (%).',
            max_prestamos_permitidos;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_verificar_prestamo
BEFORE INSERT ON DetallePrestamos
FOR EACH ROW
EXECUTE FUNCTION verificar_prestamo();


-- TRIGGER 5: Actualizar reservas cuando un libro vuelve a estar disponible
CREATE OR REPLACE FUNCTION actualizar_reserva_disponible()
RETURNS TRIGGER AS $$
DECLARE
    libro_id_disponible INT;
    reserva_pendiente RECORD;
BEGIN
    -- Obtener el libro_id del ejemplar que acaba de ser devuelto
    SELECT libro_id INTO libro_id_disponible
    FROM Ejemplares
    WHERE ejemplar_id = NEW.ejemplar_id;
    
    -- Buscar si hay alguna reserva pendiente para este libro
    SELECT r.* INTO reserva_pendiente
    FROM Reservas r
    WHERE r.libro_id = libro_id_disponible 
      AND r.estado = 'Pendiente'
    ORDER BY r.fecha_reserva ASC
    LIMIT 1;
    
    -- Si hay una reserva pendiente se actualiza su estado a 'Completada'
    IF FOUND THEN
        UPDATE Reservas
        SET estado = 'Completada'
        WHERE reserva_id = reserva_pendiente.reserva_id;
        
        -- Y cambiar el estado del ejemplar a 'Reservado'
        UPDATE Ejemplares
        SET estado = 'Reservado'
        WHERE ejemplar_id = NEW.ejemplar_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_actualizar_reserva
AFTER UPDATE ON Ejemplares
FOR EACH ROW
WHEN (OLD.estado = 'Prestado' AND NEW.estado = 'Disponible')
EXECUTE FUNCTION actualizar_reserva_disponible();

