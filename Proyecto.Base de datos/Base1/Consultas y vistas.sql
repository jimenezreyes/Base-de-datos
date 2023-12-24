------------------------------------------------------------------------------------------- Consultas
-- Consulta para conocer a las películas que han recibido alguna vez la mayor puntuación en las reseñas (5 puntos).
SELECT DISTINCT titulo, director
FROM (Peliculas
JOIN Reseñas ON Peliculas.id_pelicula = Reseñas.id_pelicula) AS pelis_puntuadas
WHERE calificacion = 5;

-- Consulta para conocer la cantidad de ingresos percibida durante el mes de agosto de 2022.
SELECT SUM(monto) AS monto_total_agosto_2022
FROM Pagos
WHERE fecha_pago >= '2022-08-01' AND fecha_pago < '2022-09-01';

-- Consulta para conocer la edad promedio de los clientes que ven películas de terror.
SELECT TRUNC(AVG(edad), 0) AS promedio_edad_gustan_terror
FROM Clientes
WHERE id_cliente IN (
    SELECT DISTINCT id_cliente
    FROM (Prestamos
    JOIN Peliculas ON Prestamos.id_pelicula = Peliculas.id_pelicula) AS clientes_terror
    WHERE genero = 'Terror'
);
------------------------------------------------------------------------------------------ Vistas
-- Estás aún no se crean en la base guardada en elephant, para crearlas basta usar el query tool o la terminal sobre la base que
-- ya está ahí :)
-- Vista que registra a aquellos clientes que han puntuado más de una película con 2 puntos o menos.
CREATE VIEW clientes_insatisfechos AS
SELECT c.id_cliente, c.nombres, c.apellido_paterno, c.apellido_materno,
       COALESCE(c.email, c.telefono) AS contacto
FROM clientes c
JOIN reseñas r ON c.id_cliente = r.id_cliente
WHERE r.calificacion <= 2
GROUP BY c.id_cliente, c.nombres, c.apellido_paterno, c.apellido_materno, c.email, c.telefono
HAVING COUNT(*) > 1;

-- Vista para registrar el historial de pagos de cada usuario en forma condensada.
CREATE VIEW historial_pagos AS
SELECT c.id_cliente, c.nombres || ' ' || c.apellido_paterno || ' ' || c.apellido_materno AS cliente,
       STRING_AGG(p.fecha_pago || ' - ' || p.monto || ' - ' || p.concepto, '; ') AS historial_pagos
FROM Clientes c
JOIN Pagos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nombres, c.apellido_paterno, c.apellido_materno;


-- Vista para registrar a las películas de nuestro catálogo conforme a su popularidad.
CREATE VIEW peliculas_populares AS
SELECT
    p.id_pelicula,
    p.titulo,
    p.director,
    p.año_lanzamiento,
    COUNT(*) AS cantidad_reseñas,
    AVG(r.calificacion) AS puntuacion_promedio
FROM
    Peliculas p
LEFT JOIN
    Reseñas r ON p.id_pelicula = r.id_pelicula
GROUP BY
    p.id_pelicula,
    p.titulo,
    p.director,
    p.año_lanzamiento
ORDER BY
    cantidad_reseñas DESC;


-- Select para probar las vistas.

SELECT * FROM clientes_insatisfechos;

SELECT * FROM historial_pagos;

SELECT * FROM peliculas_populares;