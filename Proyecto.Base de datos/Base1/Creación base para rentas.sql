
-- Proyecto final - Fundamentos de bases de datos.
-- Javier Alejandro Rivera Zavala y Abraham Jimenez reyes


-- Dominios personalizados.
-- Para restringir las edades, los estados en que se encuentran las copias y el concepto por el cuál se paga.
CREATE DOMAIN rango_edad AS INT 
  CHECK(VALUE >= 18 AND VALUE <= 130);
CREATE DOMAIN estado_copia AS VARCHAR(8)
  CHECK(VALUE IN ('bien', 'dañada','perdida')); 
CREATE DOMAIN concepto_pago AS VARCHAR(7)
  CHECK (VALUE IN ('normal', 'adeudo'));



-- Tabla clientes.
-- Restricciones para asegurar que sólo el email o el sólo el teléfono pueda ser nulo, el email debe contener @,
-- el id debe seguir un formato y cada persona se distingue de otra en el mundo real por su nombre completo, edad y dirección
-- aunque en el contexto de nuestra base, la unicidad de su id, que se asigna tras unos tramites en el mundo real, queda asegurada
-- y servira para identificarle univocamente.
CREATE TABLE Clientes (
  id_cliente VARCHAR(11) PRIMARY KEY,
  nombres VARCHAR(30) NOT NULL,
  apellido_paterno VARCHAR(30) NOT NULL,
  apellido_materno VARCHAR(30) NOT NULL,
  direccion VARCHAR(70) NOT NULL,
  email VARCHAR(50) UNIQUE,
  telefono VARCHAR(10),
  edad rango_edad NOT NULL,
  CONSTRAINT chk_email_telefono CHECK ((email IS NOT NULL AND telefono IS NULL) OR (email IS NULL AND telefono IS NOT NULL) OR (email IS NOT NULL AND telefono IS NOT NULL)),
  CONSTRAINT chk_email_format CHECK (email IS NULL OR email LIKE '%@%'),
  CONSTRAINT chk_telefono_format CHECK (telefono IS NULL OR (telefono ~ '^55\d{8}$')),
  CONSTRAINT chk_id_cliente_format CHECK (id_cliente ~ '^[A-Za-z]{5}\d{6}$'),
  CONSTRAINT unq_cliente_datos UNIQUE (nombres, apellido_paterno, apellido_materno, edad, direccion) 
);

-- Tabla peliculas.
-- El id debe seguir un formato, su unicidad es asegurada por los estándares internacionales (como el ISBN, nosotros empleamos un
-- formato personalizado), el año de lanzamiento está entre 1900 y el año actual, en el mundo real y para evitar registrar más 
-- de una película con el mismo id por error, se restringe la combinación de titulo, año de lanzamiento y director.
CREATE TABLE Peliculas (
  id_pelicula VARCHAR(10) PRIMARY KEY CHECK (id_pelicula ~ '^[A-Za-z]{3}\d{3}[A-Za-z]{2}\d{2}$'),
  titulo VARCHAR(50) NOT NULL,
  año_lanzamiento INT NOT NULL CHECK (año_lanzamiento BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE)),
  director VARCHAR(90) NOT NULL,
  idioma VARCHAR(30) NOT NULL,
  duracion TIME NOT NULL,
  genero VARCHAR(30),
  CONSTRAINT unq_peli UNIQUE (titulo, año_lanzamiento, director)  
);


-- Tabla copias. 
-- Sólo hay 3 opciones para el estado en el que está una copia y no se puede borra una película mientras se
-- tenga registro de una copia, cada sucursal puede tener hasta 5 copias de una misma película registrada,
-- cada copia se identifica por su número y la película que reproduce.
CREATE TABLE Copias (
  no_copia INT NOT NULL CHECK (no_copia BETWEEN 1 AND 5),
  id_pelicula VARCHAR(10) NOT NULL,
  estado estado_copia NOT NULL,
  PRIMARY KEY (no_copia, id_pelicula),
  FOREIGN KEY (id_pelicula) REFERENCES Peliculas(id_pelicula) ON DELETE RESTRICT ON UPDATE RESTRICT
);


-- Tabla reseñas.
-- La calificación va en un rango de 0 a 5 y se identifican según quién la emite y de qué película hablan.
CREATE TABLE Reseñas (
  id_pelicula VARCHAR(10) NOT NULL,
  id_cliente VARCHAR(11) NOT NULL,
  calificacion INT NOT NULL CHECK (calificacion BETWEEN 0 AND 5),
  comentario TEXT,
  PRIMARY KEY (id_pelicula, id_cliente),
  FOREIGN KEY (id_pelicula) REFERENCES Peliculas(id_pelicula) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Tabla préstamos. 
-- Sólo puede estar activo un prestamo si la fecha de devolución es mayor o igual que la actual, para poder desactivar el
-- prestamo en la fecha que se devuelva la película (en un plazo convenido con el cliente), podemos cambiar el estado
-- a inactivo si la fecha es la de hoy.
-- No se pueden borrar clientes, ni peliculas y por ende sus copias respectivas mientras estén registrados préstamos
-- con tales entidades (obliga a ver el historial respectivo) ó modificar sus respectivas ids, la fecha de devolución 
-- y de préstamo deben ser consistentes.
-- Sólo puede prestarse una copia a un cleinte al mismo tiempo, un mismo cliente sólo puede rentar una misma película una vez, 
-- no se pueden prestar películas dañadas o perdidas y no se le pueden prestar películas a clientes con adeudos.
CREATE TABLE Prestamos (
  no_prestamo SERIAL,
  id_cliente VARCHAR(11) NOT NULL,
  id_pelicula VARCHAR(10) NOT NULL,
  no_copia INT NOT NULL,
  fecha_prestamo DATE NOT NULL,
  fecha_devolucion DATE NOT NULL,
  monto DECIMAL(11, 5) NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT false CHECK ((activo = (fecha_devolucion >= CURRENT_DATE)) OR (activo = false AND fecha_devolucion = CURRENT_DATE)),
  PRIMARY KEY (no_prestamo, id_cliente, id_pelicula, no_copia),
  FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (id_pelicula, no_copia) REFERENCES Copias(id_pelicula,no_copia) ON DELETE RESTRICT ON UPDATE RESTRICT, 
  CONSTRAINT check_fechas CHECK (fecha_devolucion >= fecha_prestamo),
  CONSTRAINT unq_copia_activo EXCLUDE (no_copia WITH =, id_pelicula WITH =) WHERE (activo = true), 
  CONSTRAINT unq_peli_simul EXCLUDE (id_cliente WITH =, id_pelicula WITH =) WHERE (activo = true),
  CONSTRAINT unq_fecha_prestamo UNIQUE (id_cliente, id_pelicula, fecha_prestamo, fecha_devolucion)  
);

-- Función para el trigger que impide prestar copias dañadas o perdidas.
CREATE OR REPLACE FUNCTION verificar_estado_copia() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM Copias
    WHERE id_pelicula = NEW.id_pelicula AND no_copia = NEW.no_copia
      AND estado IN ('dañada', 'perdida')
  ) THEN
    RAISE EXCEPTION 'Error: La copia está en estado dañada o perdida';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que impide prestar copias dañadas o perdidas.
CREATE TRIGGER trg_verificar_estado_copia
BEFORE INSERT OR UPDATE ON Prestamos
FOR EACH ROW
EXECUTE FUNCTION verificar_estado_copia();

-- Función para el trigger que impide prestar películas a clientes con adeudos activos.
CREATE OR REPLACE FUNCTION verificar_adeudo_activo() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM Adeudos
    WHERE id_cliente = NEW.id_cliente
      AND activo = true
  ) THEN
    RAISE EXCEPTION 'Error: El cliente tiene un adeudo activo';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que impide prestar películas a clientes con adeudos activos.
CREATE TRIGGER trg_verificar_adeudo_activo
BEFORE INSERT OR UPDATE ON Prestamos
FOR EACH ROW
EXECUTE FUNCTION verificar_adeudo_activo();

-- Función para el trigger que impide prestar más de 3 películas a un mismo cliente al mismo tiempo.
CREATE OR REPLACE FUNCTION verificar_cantidad_copias()
  RETURNS TRIGGER AS $$
BEGIN
  IF NEW.activo = true THEN
    IF (SELECT COUNT(*) FROM Prestamos WHERE id_cliente = NEW.id_cliente AND activo = true) >= 3 THEN
      RAISE EXCEPTION 'No se puede asociar más de 3 copias a un mismo cliente cuando activo es true.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que impide prestar más de 3 películas a un mismo cliente al mismo tiempo.
CREATE TRIGGER trigger_verificar_cantidad_copias
  BEFORE INSERT OR UPDATE ON Prestamos
  FOR EACH ROW
  EXECUTE FUNCTION verificar_cantidad_copias();

--Tabla adeudos.
-- No se pueden borrar clientes y prestamos asociados a los adeudos (obliga a ver historial) ó modificar las respectivas id.
-- El monto del adeudo es mayor al del préstamo del que parte, la fecha del adeudo se registra con la misma que la de la devolución o 
-- a lo más un día después, sirve para gestionar adeudos por extravio, retraso, daño y de momento sólo nos interesa la fecha de inicio del adeudo.
-- Un adeudo sólo puede estar activo si el préstamo asociado a él no lo está.
CREATE TABLE Adeudos (
  no_adeudo SERIAL,  
  no_prestamo INT NOT NULL,
  id_cliente VARCHAR(11) NOT NULL,
  id_pelicula VARCHAR(10) NOT NULL,
  no_copia INT NOT NULL,
  fecha_adeudo DATE NOT NULL,
  monto DECIMAL(11, 5) NOT NULL,
  activo BOOLEAN NOT NULL,
  PRIMARY KEY (no_adeudo, no_prestamo, id_cliente, id_pelicula, no_copia),   
  FOREIGN KEY (no_prestamo, id_cliente, id_pelicula, no_copia) REFERENCES Prestamos(no_prestamo, id_cliente, id_pelicula, no_copia) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT unq_fecha_adeudo UNIQUE (id_cliente, id_pelicula, fecha_adeudo)
);

-- Función para el trigger que se asegura que se registre una penalización sobre el pago.
CREATE OR REPLACE FUNCTION verificar_monto_adeudo() RETURNS TRIGGER AS $$
BEGIN
  DECLARE
    prestamo_monto DECIMAL(11, 5);
  BEGIN
    SELECT monto INTO prestamo_monto
    FROM Prestamos
    WHERE no_prestamo = NEW.no_prestamo
      AND id_cliente = NEW.id_cliente
      AND id_pelicula = NEW.id_pelicula
      AND no_copia = NEW.no_copia;
      
    IF NEW.monto <= prestamo_monto THEN
      RAISE EXCEPTION 'Error: El monto del adeudo debe ser mayor que el monto del préstamo asociado';
    END IF;
    
    RETURN NEW;
  END;
END;
$$ LANGUAGE plpgsql;

-- Trigger que se asegura que se registre una penalización sobre el pago.
CREATE TRIGGER trg_verificar_monto_adeudo
BEFORE INSERT OR UPDATE ON Adeudos
FOR EACH ROW
EXECUTE FUNCTION verificar_monto_adeudo();


-- Función para el trigger que se asegura de la consistencia entre las fechas del adeudo y el préstamo.
CREATE OR REPLACE FUNCTION verificar_fecha_adeudo() RETURNS TRIGGER AS $$
BEGIN
  DECLARE
    prestamo_fecha_devolucion DATE;
  BEGIN
    SELECT fecha_devolucion INTO prestamo_fecha_devolucion
    FROM Prestamos
    WHERE no_prestamo = NEW.no_prestamo
      AND id_cliente = NEW.id_cliente
      AND id_pelicula = NEW.id_pelicula
      AND no_copia = NEW.no_copia;
      
    IF NEW.fecha_adeudo < prestamo_fecha_devolucion OR NEW.fecha_adeudo > prestamo_fecha_devolucion + INTERVAL '1 day' THEN
      RAISE EXCEPTION 'Error: La fecha de adeudo debe ser igual o un día después de la fecha de devolución del préstamo asociado';
    END IF;
    
    RETURN NEW;
  END;
END;
$$ LANGUAGE plpgsql;

-- Trigger que se asegura de la consistencia entre las fechas del adeudo y el préstamo.
CREATE TRIGGER trg_verificar_fecha_adeudo
BEFORE INSERT OR UPDATE ON Adeudos
FOR EACH ROW
EXECUTE FUNCTION verificar_fecha_adeudo();

-- Función para el trigger que se asegura de la consistencia entre el estado del préstamo y el adeudo.
CREATE OR REPLACE FUNCTION verificar_actividad_prestamo() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM Prestamos
    WHERE no_prestamo = NEW.no_prestamo
      AND id_cliente = NEW.id_cliente
      AND id_pelicula = NEW.id_pelicula
      AND no_copia = NEW.no_copia
      AND activo = true
  ) THEN
    RAISE EXCEPTION 'Error: No se puede activar el adeudo si el préstamo asociado está activo';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que se asegura de la consistencia entre el estado del préstamo y el adeudo.
CREATE TRIGGER trg_verificar_actividad_prestamo
BEFORE INSERT OR UPDATE ON Adeudos
FOR EACH ROW
EXECUTE FUNCTION verificar_actividad_prestamo();


-- Tabla pagos.
-- El pago puede ser por un préstamo normal o préstamo con adeudo, no se pueden borrar clientes ni prestamos si están asociados a un pago 
-- (obliga a ver el historial) ó modificar las respectivas id y la fecha de pago ha de ser mayor o igual a la fecha de devolución del DVD.
CREATE TABLE Pagos (
  no_pago SERIAL,
  no_prestamo INT NOT NULL,
  id_cliente VARCHAR(11) NOT NULL,
  id_pelicula VARCHAR(10) NOT NULL,
  no_copia INT NOT NULL,
  fecha_pago DATE NOT NULL,
  monto DECIMAL(11, 5) NOT NULL,
  concepto concepto_pago NOT NULL,  
  PRIMARY KEY (no_pago, no_prestamo, id_cliente, id_pelicula, no_copia),
  FOREIGN KEY (no_prestamo, id_cliente, id_pelicula, no_copia) REFERENCES Prestamos(no_prestamo, id_cliente, id_pelicula, no_copia) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT unq_fecha_pago UNIQUE (id_cliente, id_pelicula, fecha_pago)
);

-- Función para el trigger que se asegura de la consistencia entre las fechas del pago y el préstamo.
CREATE OR REPLACE FUNCTION verificar_fecha_pago() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fecha_pago < (SELECT fecha_devolucion FROM Prestamos WHERE no_prestamo = NEW.no_prestamo) THEN
    RAISE EXCEPTION 'Error: La fecha de pago debe ser mayor o igual a la fecha de devolución del préstamo asociado';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que se asegura de la consistencia entre las fechas del pago y el préstamo.
CREATE TRIGGER trg_verificar_fecha_pago
BEFORE INSERT OR UPDATE ON Pagos
FOR EACH ROW
EXECUTE FUNCTION verificar_fecha_pago();







