-- Proyecto final - Fundamentos de bases de datos.
-- Javier Alejandro Rivera Zavala y Abraham Jimenez reyes
-- Script para la base de datos para empleados, generado a partir de un dump, ya incluye las vistas
-- sin embargo se incluyen las mismas en otro script para facilitar su lectura.
-- El esquema definido ha de ser public.
--
-- Name: correoelectronico; Type: DOMAIN; Schema: public; 
--

CREATE DOMAIN public.correoelectronico AS character varying(50)
	CONSTRAINT correoelectronico_check CHECK (((VALUE)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text));


--
-- Name: fechainicio; Type: DOMAIN; Schema: public; 
--

CREATE DOMAIN public.fechainicio AS integer
	CONSTRAINT fechainicio_check CHECK (((VALUE >= 19500101) AND (VALUE <= 21000101)));


--
-- Name: fechatermino; Type: DOMAIN; Schema: public; 
--

CREATE DOMAIN public.fechatermino AS integer
	CONSTRAINT fechatermino_check CHECK (((VALUE >= 19500201) AND (VALUE <= 21000101)));


SET default_tablespace = '';

--
-- Name: departamentos; Type: TABLE; Schema: public; 
--

CREATE TABLE public.departamentos (
    id_departamento integer NOT NULL,
    nombre character varying(30) NOT NULL,
    descripcion character varying(30) NOT NULL
);

--
-- Name: dependientes; Type: TABLE; Schema: public; 
--

CREATE TABLE public.dependientes (
    id_dependientes integer NOT NULL,
    id_empleado integer NOT NULL,
    nombre character varying(20) NOT NULL,
    parentesco character varying(10) NOT NULL,
    fecha_de_nacimiento integer,
    CONSTRAINT chk_nombre_parentesco CHECK ((((nombre IS NULL) AND (parentesco IS NULL)) OR ((nombre IS NOT NULL) AND (parentesco IS NOT NULL))))
);

--
-- Name: direcciones; Type: TABLE; Schema: public; 
--

CREATE TABLE public.direcciones (
    id_direcciones integer NOT NULL,
    id_empleado integer NOT NULL,
    calle character varying(50) NOT NULL,
    ciudad character varying(30) NOT NULL,
    estado character varying(30) NOT NULL,
    codigo_postal character varying(5) NOT NULL,
    CONSTRAINT chk_codigo_postal_length CHECK ((length((codigo_postal)::text) <= 5))
);

--
-- Name: empleados; Type: TABLE; Schema: public; 
--

CREATE TABLE public.empleados (
    id_empleados integer NOT NULL,
    nombre character varying(10) NOT NULL,
    apellido character varying(20) NOT NULL,
    fecha_de_nacimiento numeric,
    direccion character varying(45) NOT NULL,
    correo_electronio public.correoelectronico NOT NULL,
    id_departamento integer NOT NULL,
    id_salarios integer NOT NULL,
    id_direcciones integer NOT NULL,
    id_dependientes integer NOT NULL,
    id_historial integer NOT NULL,
    id_supervisor integer NOT NULL
);

--
-- Name: historial_de_empleo; Type: TABLE; Schema: public; 
--

CREATE TABLE public.historial_de_empleo (
    id_historial integer NOT NULL,
    id_empleado integer NOT NULL,
    empresa character varying(20) NOT NULL,
    cargo character varying(50) NOT NULL,
    fecha_de_inicio integer,
    fecha_de_termino integer,
    CONSTRAINT chk_empresa_cargo CHECK ((((empresa IS NULL) AND (cargo IS NULL)) OR ((empresa IS NOT NULL) AND (cargo IS NOT NULL)))),
    CONSTRAINT chk_fecha_inicio CHECK ((fecha_de_inicio > 19500101)),
    CONSTRAINT chk_fecha_termino CHECK ((fecha_de_termino < 21000101))
);

--
-- Name: salarios; Type: TABLE; Schema: public; 
--

CREATE TABLE public.salarios (
    id_salarios integer NOT NULL,
    id_empleado integer NOT NULL,
    salario integer,
    fecha_de_inicio public.fechainicio NOT NULL,
    fecha_de_termino public.fechatermino,
    CONSTRAINT chk_salario_positive CHECK ((salario >= 0))
);

--
-- Name: supervisor; Type: TABLE; Schema: public; 
--

CREATE TABLE public.supervisor (
    id_supervisor integer NOT NULL,
    nombre character varying(20) NOT NULL,
    descripcion character varying(60) NOT NULL,
    id_empleado integer NOT NULL
);

--
-- Name: vista_direccion_dependientes; Type: VIEW; Schema: public; 
--

CREATE VIEW public.vista_direccion_dependientes AS
 SELECT e.id_empleados,
    e.nombre,
    d.calle,
    d.ciudad,
    d.estado,
    dd.nombre AS nombre_dependiente,
    dd.parentesco
   FROM ((public.empleados e
     JOIN public.direcciones d ON ((e.id_direcciones = d.id_direcciones)))
     JOIN public.dependientes dd ON ((e.id_dependientes = dd.id_dependientes)));

--
-- Name: vista_empleados; Type: VIEW; Schema: public;
--

CREATE VIEW public.vista_empleados AS
 SELECT e.id_empleados,
    e.nombre,
    e.apellido,
    d.nombre AS departamento,
    s.salario
   FROM ((public.empleados e
     JOIN public.departamentos d ON ((e.id_departamento = d.id_departamento)))
     JOIN public.salarios s ON ((e.id_salarios = s.id_salarios)));

--
-- Name: vista_historial_supervisor; Type: VIEW; Schema: public; 
--

CREATE VIEW public.vista_historial_supervisor AS
 SELECT h.id_historial,
    h.empresa,
    h.cargo,
    h.fecha_de_inicio,
    h.fecha_de_termino,
    e.nombre AS nombre_empleado,
    s.nombre AS nombre_supervisor
   FROM ((public.historial_de_empleo h
     JOIN public.empleados e ON ((h.id_empleado = e.id_empleados)))
     JOIN public.supervisor s ON ((e.id_supervisor = s.id_supervisor)));
--
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; 
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id_departamento);


--
-- Name: dependientes dependientes_pkey; Type: CONSTRAINT; Schema: 
--

ALTER TABLE ONLY public.dependientes
    ADD CONSTRAINT dependientes_pkey PRIMARY KEY (id_dependientes);


--
-- Name: direcciones direcciones_pkey; Type: CONSTRAINT; Schema: public; 
--

ALTER TABLE ONLY public.direcciones
    ADD CONSTRAINT direcciones_pkey PRIMARY KEY (id_direcciones);


--
-- Name: empleados empleados_pkey; Type: CONSTRAINT; Schema: public; 
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_pkey PRIMARY KEY (id_empleados);


--
-- Name: historial_de_empleo historial_de_empleo_pkey; Type: CONSTRAINT; 
--

ALTER TABLE ONLY public.historial_de_empleo
    ADD CONSTRAINT historial_de_empleo_pkey PRIMARY KEY (id_historial);


--
-- Name: salarios salarios_pkey; Type: CONSTRAINT; Schema: public; 
--

ALTER TABLE ONLY public.salarios
    ADD CONSTRAINT salarios_pkey PRIMARY KEY (id_salarios);


--
-- Name: supervisor supervisor_pkey; Type: CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY public.supervisor
    ADD CONSTRAINT supervisor_pkey PRIMARY KEY (id_supervisor);


--
-- Name: empleados empleados_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; 
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.departamentos(id_departamento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: empleados empleados_id_dependientes_fkey; Type: FK CONSTRAINT; Schema: public; 
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_dependientes_fkey FOREIGN KEY (id_dependientes) REFERENCES public.dependientes(id_dependientes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: empleados empleados_id_direcciones_fkey; Type: FK CONSTRAINT; Schema: public; 
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_direcciones_fkey FOREIGN KEY (id_direcciones) REFERENCES public.direcciones(id_direcciones) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: empleados empleados_id_historial_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_historial_fkey FOREIGN KEY (id_historial) REFERENCES public.historial_de_empleo(id_historial) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: empleados empleados_id_salarios_fkey; Type: FK CONSTRAINT; Schema: public; 
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_salarios_fkey FOREIGN KEY (id_salarios) REFERENCES public.salarios(id_salarios) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: empleados empleados_id_supervisor_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_supervisor_fkey FOREIGN KEY (id_supervisor) REFERENCES public.supervisor(id_supervisor) ON UPDATE CASCADE ON DELETE CASCADE;



