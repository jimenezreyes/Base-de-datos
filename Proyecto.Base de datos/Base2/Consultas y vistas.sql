-- Proyecto final - Fundamentos de bases de datos - Consultas y vistas correspondientes a los ejercicios 10 y 11.
-- Javier Alejandro Rivera Zavala y Abraham Jimenez Reyes
------------------------------------10-----------------------------------------------
----Consulta 1
SELECT MAX(Salario) AS Salario_Maximo
FROM Salarios;

----Consulta 2
SELECT *
FROM Historial_de_Empleo
WHERE Empresa = 'Global Solutions';

----Consutla 3
SELECT Nombre
FROM Departamentos
WHERE Nombre = 'Comercial';


------------------------------------11----------------------------------------------

----Vista 1
CREATE VIEW Vista_Empleados AS
SELECT e.ID_empleados, e.Nombre, e.Apellido, d.Nombre AS Departamento, s.Salario
FROM Empleados e
JOIN Departamentos d ON e.ID_departamento = d.ID_departamento
JOIN Salarios s ON e.ID_Salarios = s.ID_Salarios;
--Ejemplo vista 1
SELECT *
FROM Vista_Empleados;


----Vista 2
CREATE VIEW Vista_Direccion_Dependientes AS
SELECT e.ID_empleados, e.Nombre, d.Calle, d.Ciudad, d.Estado, dd.Nombre AS Nombre_Dependiente, dd.Parentesco
FROM Empleados e
JOIN Direcciones d ON e.ID_direcciones = d.ID_direcciones
JOIN Dependientes dd ON e.ID_dependientes = dd.ID_dependientes;
--Ejemplo vista 2
SELECT *
FROM Vista_Direccion_Dependientes;


----Vista 3
CREATE VIEW Vista_Historial_Supervisor AS
SELECT h.ID_historial, h.Empresa, h.Cargo, h.Fecha_de_inicio, h.Fecha_de_termino, e.Nombre AS Nombre_Empleado, s.Nombre AS Nombre_Supervisor
FROM Historial_de_Empleo h
JOIN Empleados e ON h.ID_Empleado = e.ID_empleados
JOIN Supervisor s ON e.ID_supervisor = s.ID_supervisor;
--Ejemplo vista 3
SELECT *
FROM Vista_Historial_Supervisor;
