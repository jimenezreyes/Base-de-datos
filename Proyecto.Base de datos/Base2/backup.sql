--
-- PostgreSQL database dump
--

-- Dumped from database version 11.19 (Ubuntu 11.19-1.pgdg20.04+1)
-- Dumped by pg_dump version 12.15 (Ubuntu 12.15-0ubuntu0.20.04.1)

-- Started on 2023-06-12 12:51:54 CST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 15 (class 3079 OID 17135)
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- TOC entry 4088 (class 0 OID 0)
-- Dependencies: 15
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- TOC entry 19 (class 3079 OID 17676)
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- TOC entry 4089 (class 0 OID 0)
-- Dependencies: 19
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- TOC entry 8 (class 3079 OID 16661)
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- TOC entry 4090 (class 0 OID 0)
-- Dependencies: 8
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- TOC entry 17 (class 3079 OID 17573)
-- Name: cube; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;


--
-- TOC entry 4091 (class 0 OID 0)
-- Dependencies: 17
-- Name: EXTENSION cube; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';


--
-- TOC entry 2 (class 3079 OID 16384)
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- TOC entry 4092 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- TOC entry 14 (class 3079 OID 17130)
-- Name: dict_int; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dict_int WITH SCHEMA public;


--
-- TOC entry 4093 (class 0 OID 0)
-- Dependencies: 14
-- Name: EXTENSION dict_int; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dict_int IS 'text search dictionary template for integers';


--
-- TOC entry 20 (class 3079 OID 18299)
-- Name: dict_xsyn; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dict_xsyn WITH SCHEMA public;


--
-- TOC entry 4094 (class 0 OID 0)
-- Dependencies: 20
-- Name: EXTENSION dict_xsyn; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dict_xsyn IS 'text search dictionary template for extended synonym processing';


--
-- TOC entry 18 (class 3079 OID 17660)
-- Name: earthdistance; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;


--
-- TOC entry 4095 (class 0 OID 0)
-- Dependencies: 18
-- Name: EXTENSION earthdistance; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION earthdistance IS 'calculate great-circle distances on the surface of the Earth';


--
-- TOC entry 7 (class 3079 OID 16650)
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- TOC entry 4096 (class 0 OID 0)
-- Dependencies: 7
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- TOC entry 13 (class 3079 OID 17007)
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- TOC entry 4097 (class 0 OID 0)
-- Dependencies: 13
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- TOC entry 12 (class 3079 OID 16889)
-- Name: intarray; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;


--
-- TOC entry 4098 (class 0 OID 0)
-- Dependencies: 12
-- Name: EXTENSION intarray; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION intarray IS 'functions, operators, and index support for 1-D arrays of integers';


--
-- TOC entry 4 (class 3079 OID 16444)
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- TOC entry 4099 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


--
-- TOC entry 22 (class 3079 OID 18311)
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- TOC entry 4100 (class 0 OID 0)
-- Dependencies: 22
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- TOC entry 11 (class 3079 OID 16812)
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- TOC entry 4101 (class 0 OID 0)
-- Dependencies: 11
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- TOC entry 10 (class 3079 OID 16775)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 4102 (class 0 OID 0)
-- Dependencies: 10
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 16 (class 3079 OID 17571)
-- Name: pgrowlocks; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgrowlocks WITH SCHEMA public;


--
-- TOC entry 4103 (class 0 OID 0)
-- Dependencies: 16
-- Name: EXTENSION pgrowlocks; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgrowlocks IS 'show row-level locking information';


--
-- TOC entry 5 (class 3079 OID 16619)
-- Name: pgstattuple; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgstattuple WITH SCHEMA public;


--
-- TOC entry 4104 (class 0 OID 0)
-- Dependencies: 5
-- Name: EXTENSION pgstattuple; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgstattuple IS 'show tuple-level statistics';


--
-- TOC entry 6 (class 3079 OID 16629)
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- TOC entry 4105 (class 0 OID 0)
-- Dependencies: 6
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


--
-- TOC entry 21 (class 3079 OID 18304)
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- TOC entry 4106 (class 0 OID 0)
-- Dependencies: 21
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- TOC entry 9 (class 3079 OID 16764)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 4107 (class 0 OID 0)
-- Dependencies: 9
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 3 (class 3079 OID 16430)
-- Name: xml2; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS xml2 WITH SCHEMA public;


--
-- TOC entry 4108 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION xml2; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION xml2 IS 'XPath querying and XSLT';


--
-- TOC entry 1426 (class 1247 OID 16387011)
-- Name: correoelectronico; Type: DOMAIN; Schema: public; Owner: jqdcxclm
--

CREATE DOMAIN public.correoelectronico AS character varying(50)
	CONSTRAINT correoelectronico_check CHECK (((VALUE)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text));


ALTER DOMAIN public.correoelectronico OWNER TO jqdcxclm;

--
-- TOC entry 1418 (class 1247 OID 16387001)
-- Name: fechainicio; Type: DOMAIN; Schema: public; Owner: jqdcxclm
--

CREATE DOMAIN public.fechainicio AS integer
	CONSTRAINT fechainicio_check CHECK (((VALUE >= 19500101) AND (VALUE <= 21000101)));


ALTER DOMAIN public.fechainicio OWNER TO jqdcxclm;

--
-- TOC entry 1422 (class 1247 OID 16387004)
-- Name: fechatermino; Type: DOMAIN; Schema: public; Owner: jqdcxclm
--

CREATE DOMAIN public.fechatermino AS integer
	CONSTRAINT fechatermino_check CHECK (((VALUE >= 19500201) AND (VALUE <= 21000101)));


ALTER DOMAIN public.fechatermino OWNER TO jqdcxclm;

SET default_tablespace = '';

--
-- TOC entry 222 (class 1259 OID 16382009)
-- Name: departamentos; Type: TABLE; Schema: public; Owner: jqdcxclm
--

CREATE TABLE public.departamentos (
    id_departamento integer NOT NULL,
    nombre character varying(30) NOT NULL,
    descripcion character varying(30) NOT NULL
);


ALTER TABLE public.departamentos OWNER TO jqdcxclm;

--
-- TOC entry 226 (class 1259 OID 16382029)
-- Name: dependientes; Type: TABLE; Schema: public; Owner: jqdcxclm
--

CREATE TABLE public.dependientes (
    id_dependientes integer NOT NULL,
    id_empleado integer NOT NULL,
    nombre character varying(20) NOT NULL,
    parentesco character varying(10) NOT NULL,
    fecha_de_nacimiento integer,
    CONSTRAINT chk_nombre_parentesco CHECK ((((nombre IS NULL) AND (parentesco IS NULL)) OR ((nombre IS NOT NULL) AND (parentesco IS NOT NULL))))
);


ALTER TABLE public.dependientes OWNER TO jqdcxclm;

--
-- TOC entry 225 (class 1259 OID 16382024)
-- Name: direcciones; Type: TABLE; Schema: public; Owner: jqdcxclm
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


ALTER TABLE public.direcciones OWNER TO jqdcxclm;

--
-- TOC entry 228 (class 1259 OID 16382039)
-- Name: empleados; Type: TABLE; Schema: public; Owner: jqdcxclm
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


ALTER TABLE public.empleados OWNER TO jqdcxclm;

--
-- TOC entry 227 (class 1259 OID 16382034)
-- Name: historial_de_empleo; Type: TABLE; Schema: public; Owner: jqdcxclm
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


ALTER TABLE public.historial_de_empleo OWNER TO jqdcxclm;

--
-- TOC entry 224 (class 1259 OID 16382019)
-- Name: salarios; Type: TABLE; Schema: public; Owner: jqdcxclm
--

CREATE TABLE public.salarios (
    id_salarios integer NOT NULL,
    id_empleado integer NOT NULL,
    salario integer,
    fecha_de_inicio public.fechainicio NOT NULL,
    fecha_de_termino public.fechatermino,
    CONSTRAINT chk_salario_positive CHECK ((salario >= 0))
);


ALTER TABLE public.salarios OWNER TO jqdcxclm;

--
-- TOC entry 223 (class 1259 OID 16382014)
-- Name: supervisor; Type: TABLE; Schema: public; Owner: jqdcxclm
--

CREATE TABLE public.supervisor (
    id_supervisor integer NOT NULL,
    nombre character varying(20) NOT NULL,
    descripcion character varying(60) NOT NULL,
    id_empleado integer NOT NULL
);


ALTER TABLE public.supervisor OWNER TO jqdcxclm;

--
-- TOC entry 230 (class 1259 OID 16387206)
-- Name: vista_direccion_dependientes; Type: VIEW; Schema: public; Owner: jqdcxclm
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


ALTER TABLE public.vista_direccion_dependientes OWNER TO jqdcxclm;

--
-- TOC entry 229 (class 1259 OID 16387201)
-- Name: vista_empleados; Type: VIEW; Schema: public; Owner: jqdcxclm
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


ALTER TABLE public.vista_empleados OWNER TO jqdcxclm;

--
-- TOC entry 231 (class 1259 OID 16387287)
-- Name: vista_historial_supervisor; Type: VIEW; Schema: public; Owner: jqdcxclm
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


ALTER TABLE public.vista_historial_supervisor OWNER TO jqdcxclm;

--
-- TOC entry 4076 (class 0 OID 16382009)
-- Dependencies: 222
-- Data for Name: departamentos; Type: TABLE DATA; Schema: public; Owner: jqdcxclm
--

COPY public.departamentos (id_departamento, nombre, descripcion) FROM stdin;
1	Logistica	Envios
3	Logistica	Envios
4	Logistica	Envios
5	Logistica	Envios
6	Logistica	Envios
7	Logistica	Envios
8	Logistica	Envios
9	Logistica	Envios
10	Financiero	Metodos de pagos
11	Financiero	Metodos de pagos
12	Financiero	Metodos de pagos
13	Financiero	Metodos de pagos
14	Financiero	Metodos de pagos
15	Financiero	Metodos de pagos
16	Financiero	Metodos de pagos
17	Financiero	Metodos de pagos
18	Financiero	Metodos de pagos
19	Financiero	Metodos de pagos
20	Recursos humanos	Relaciones trabajador
21	Recursos humanos	Relaciones trabajador
22	Recursos humanos	Relaciones trabajador
23	Recursos humanos	Relaciones trabajador
24	Recursos humanos	Relaciones trabajador
25	Recursos humanos	Relaciones trabajador
26	Recursos humanos	Relaciones trabajador
27	Recursos humanos	Relaciones trabajador
28	Recursos humanos	Relaciones trabajador
29	Recursos humanos	Relaciones trabajador
30	Recursos humanos	Relaciones trabajador
31	Recursos humanos	Relaciones trabajador
32	Recursos humanos	Relaciones trabajador
33	Marketing	Promocionales
34	Marketing	Promocionales
35	Marketing	Promocionales
36	Marketing	Promocionales
37	Marketing	Promocionales
38	Marketing	Promocionales
39	Marketing	Promocionales
40	Marketing	Promocionales
41	Marketing	Promocionales
42	Marketing	Promocionales
43	Marketing	Promocionales
44	Marketing	Promocionales
45	Marketing	Promocionales
46	Marketing	Promocionales
47	Marketing	Promocionales
48	Marketing	Promocionales
49	Control de gestion	Calidad producto
50	Control de gestion	Calidad producto
51	Control de gestion	Calidad producto
52	Control de gestion	Calidad producto
53	Control de gestion	Calidad producto
54	Control de gestion	Calidad producto
55	Control de gestion	Calidad producto
56	Control de gestion	Calidad producto
57	Control de gestion	Calidad producto
58	Comercial	Gestionar ventas
59	Comercial	Gestionar ventas
60	Comercial	Gestionar ventas
61	Comercial	Gestionar ventas
62	Comercial	Gestionar ventas
63	Comercial	Gestionar ventas
64	Comercial	Gestionar ventas
65	Comercial	Gestionar ventas
66	Comercial	Gestionar ventas
67	Comercial	Gestionar ventas
68	Comercial	Gestionar ventas
69	Comercial	Gestionar ventas
70	Comercial	Gestionar ventas
71	Operaciones	Fabricaciones
72	Operaciones	Fabricaciones
73	Operaciones	Fabricaciones
74	Operaciones	Fabricaciones
75	Operaciones	Fabricaciones
76	Operaciones	Fabricaciones
77	Operaciones	Fabricaciones
78	Operaciones	Fabricaciones
79	Operaciones	Fabricaciones
80	Operaciones	Fabricaciones
81	Compras	Compra de recursos
82	Compras	Compra de recursos
83	Compras	Compra de recursos
84	Compras	Compra de recursos
85	Compras	Compra de recursos
86	Compras	Compra de recursos
87	Compras	Compra de recursos
88	Compras	Compra de recursos
89	Compras	Compra de recursos
90	Compras	Compra de recursos
91	Compras	Compra de recursos
92	Compras	Compra de recursos
93	Direccion general	Toma de decisiones
94	Direccion general	Toma de decisiones
95	Direccion general	Toma de decisiones
96	Direccion general	Toma de decisiones
97	Direccion general	Toma de decisiones
98	Direccion general	Toma de decisiones
99	Direccion general	Toma de decisiones
100	Direccion general	Toma de decisiones
\.


--
-- TOC entry 4080 (class 0 OID 16382029)
-- Dependencies: 226
-- Data for Name: dependientes; Type: TABLE DATA; Schema: public; Owner: jqdcxclm
--

COPY public.dependientes (id_dependientes, id_empleado, nombre, parentesco, fecha_de_nacimiento) FROM stdin;
1	1	Karla	Primo	19890302
2	2	Petra	Madre	19591102
3	3	Alonso	Hermano	19990306
4	4	Javier	Tio	19800303
5	5	Ximena	Hermana	20030503
6	6	Luis	Primo	19890402
7	7	Beatriz	Tia	19700302
8	8	Joshua	Primo	20090302
9	9	Ester	Esposa	20090302
10	10	Keith	Novia	20090402
11	11	Vanessa	Prima	19891202
12	12	Berenice	Madre	19980302
13	13	Alejandra	Tia	20010302
14	14	Jessica	Hermana	19890702
15	15	Alexandra	Madre	20020302
16	16	Ximena	Hermana	20030302
17	17	Hannia	Tia	20040302
18	18	Argelia	Esposa	19881002
19	19	Monserrat	Hermana	19990108
20	20	Ayatziri	Sobrina	19970302
21	21	Fernanda	Cuñada	1989092
22	22	Yolanda	Madre	19861028
23	23	Esmeralda	Tia	19890602
24	24	Michelle	Prima	19890502
25	25	Tania	Esposa	19900302
26	26	Angelica	Tia	19890329
27	27	Nelly	Esposa	19890328
28	28	Marcelina	Madre	19890327
29	29	Tatiana	Novia	19890326
30	30	Liz	Sobrina	19890325
31	31	Lizbeth	Hija	19890324
32	32	Zuri	Hija	19890323
33	33	Nayelly	Hija	19890322
34	34	Cansas	Hermana	19890321
36	36	Alondra	Hija	19890323
37	37	Katia	Prima	19890324
38	38	Samantha	Hija	19890325
39	39	Ana	Tia	19890326
40	40	Sol	Prima	19890327
41	41	Karla	Madre	19890328
42	42	Nancy	Abuela	19890329
43	43	Pedro	Abuelo	20010911
44	44	Alan	Abuel0	20030912
45	45	Alfredo	Abuelo	20040913
46	46	Abraham	Abuelo	20050914
47	47	Miguel	Hermano	20060915
48	48	Daniel	Tio	20070916
49	49	Lizardi	Abuelo	20020817
50	50	Ricardo	Hijo	20020618
51	51	Florencio	Tio	20020519
52	52	Ivan	Primo	20020411
53	53	Jaime	Hijo	20020311
54	54	Esteban	Hijo	20020211
55	55	Alexis	Primo	20020111
56	56	Osvaldo	Abuelo	20020931
57	57	Hugo	Padre	20020930
58	58	Jaciel	Padre	20020929
59	59	Diego	Padre	20020928
60	60	Santiago	Tio	20020927
61	61	Jonathan	Abuelo	20020926
62	62	Juan	Abuelo	20020925
63	62	Lucio	Hermano	20020924
64	64	Joel	Hermano	20020923
65	65	Javier	Tio	20020922
66	66	Pepe	Tio	20020921
67	67	Toño	Tio	20020920
68	68	Kirito	Abuel0	20010911
69	69	Zusunaga	Abuelo	20000911
70	70	Joh lu	Primo	20000111
71	71	Naruto	Abuelo	20030111
72	72	Gohan	Tio	20020821
73	73	Cristo	Suegro	20000811
74	74	Soldier	Tio	20000911
75	75	Napore	Hermano	20010111
76	76	Light	Cuñado	20021111
77	77	Andres	primo	20021210
78	78	alejandro	Hijo	20020110
79	79	Santiago	Hijo	20020218
80	80	Merildo	Hijo	20020111
81	81	Hernesto	Abuelo	19900101
82	82	Pedro	Hijo	19900102
83	83	Morales	Hijo	19900103
84	84	Carlos	Hermano	19900104
85	85	Thiago	Hermano	19900105
86	86	Cristiano	Hjio	19900106
87	87	Pedro	Hermano	19900107
88	88	Leonel	Abuelo	19900108
89	89	Sergio	Tio	19900109
90	90	Char	Sobrino	19900110
91	91	Cruz	Tio	19900210
92	92	Garcia	Padre	19900310
93	93	Pele	Padre	19900410
94	94	Xavi	hijo	19900510
95	95	Andres	Hijo	19900610
96	96	Chema	Hijo	19900710
97	97	Santiago	Tio	19900810
98	98	Ronaldo	Padre	19900810
99	99	Messi	Cuñado	19901010
100	100	Carlos	Hermano	19901110
\.


--
-- TOC entry 4079 (class 0 OID 16382024)
-- Dependencies: 225
-- Data for Name: direcciones; Type: TABLE DATA; Schema: public; Owner: jqdcxclm
--

COPY public.direcciones (id_direcciones, id_empleado, calle, ciudad, estado, codigo_postal) FROM stdin;
1	1	AV. JUAREZ NO. 963, ROMA NORTE	CDMX	DF	58018
2	2	Calle del Sol No. 123	Guadalajara	Jalisco	44100
3	3	Avenida de la Luna No. 456	Monterrey	Nuevo León	64000
4	4	Calle Principal No. 789	Puebla	Puebla	72000
5	5	Avenida Central No. 321	Querétaro	Querétaro	76000
6	6	Calle del Bosque No. 987	Toluca	Estado de México	50090
7	7	Avenida Reforma No. 654	Mérida	Yucatán	97000
8	8	Calle del Río No. 321	Cancún	Quintana Roo	77500
9	9	Avenida de los Pinos No. 567	Acapulco	Guerrero	39670
11	11	Avenida del Sol No. 456	Hermosillo	Sonora	83000
12	12	Calle Juárez No. 654	Morelia	Michoacán	58090
13	13	Avenida de la Luna No. 321	Tijuana	Baja California	22000
14	14	Calle Principal No. 789	Cuernavaca	Morelos	62000
15	15	Avenida Central No. 456	San Luis Potosí	San Luis Potosí	78000
16	16	Calle del Bosque No. 654	Aguascalientes	Aguascalientes	20000
17	17	Avenida Reforma No. 321	Durango	Durango	34000
18	18	Calle del Río No. 789	Xalapa	Veracruz	91000
19	19	Avenida de los Pinos No. 456	Culiacán	Sinaloa	80000
20	20	Calle Principal No. 987	Chetumal	Quintana Roo	77000
21	21	Avenida del Sol No. 321	Campeche	Campeche	24000
22	22	Calle Juárez No. 789	Colima	Colima	28000
23	23	Avenida de la Playa No. 654	Puerto Vallarta	Jalisco	48300
24	24	Calle del Bosque No. 321	Ciudad Obregón	Sonora	85000
25	25	Avenida Reforma No. 789	Tuxtla Gutiérrez	Chiapas	29000
26	26	Calle del Río No. 987	Oaxaca	Oaxaca	68000
27	27	Avenida de los Pinos No. 321	Villahermosa	Tabasco	86000
28	28	Calle Principal No. 789	Tampico	Tamaulipas	89000
29	29	Avenida Central No. 456	Ciudad Victoria	Tamaulipas	87000
30	30	Calle del Sol No. 654	La Paz	Baja California Sur	23000
31	31	Avenida de la Luna No. 321	Chihuahua	Chihuahua	31000
32	32	Calle Principal No. 789	Mexicali	Baja California	21000
33	33	Avenida Central No. 456	Aguascalientes	Aguascalientes	20000
34	34	Calle del Bosque No. 654	Mérida	Yucatán	97000
35	35	Avenida Reforma No. 321	Cancún	Quintana Roo	77500
36	36	Calle del Río No. 789	Puebla	Puebla	72000
37	37	Avenida de los Pinos No. 456	Guadalajara	Jalisco	44100
38	38	Calle Principal No. 789	Monterrey	Nuevo León	64000
39	39	Avenida Central No. 321	Querétaro	Querétaro	76000
40	40	Calle del Sol No. 654	Toluca	Estado de México	50090
41	41	Avenida de la Luna No. 321	Mérida	Yucatán	97000
42	42	Calle Principal No. 789	Cancún	Quintana Roo	77500
43	43	Avenida Central No. 456	Puebla	Puebla	72000
44	44	Calle del Bosque No. 654	Guadalajara	Jalisco	44100
45	45	Avenida Reforma No. 321	Monterrey	Nuevo León	64000
46	46	Calle del Río No. 789	Querétaro	Querétaro	76000
47	47	Avenida de los Pinos No. 456	Toluca	Estado de México	50090
48	48	Calle Principal No. 789	Mérida	Yucatán	97000
49	49	Avenida Central No. 321	Cancún	Quintana Roo	77500
50	50	Calle del Sol No. 654	Puebla	Puebla	72000
51	51	Avenida de la Luna No. 321	Guadalajara	Jalisco	44100
52	52	Calle Principal No. 789	Monterrey	Nuevo León	64000
53	53	Avenida Central No. 456	Querétaro	Querétaro	76000
54	54	Calle del Bosque No. 654	Toluca	Estado de México	50090
55	55	Avenida Reforma No. 321	Mérida	Yucatán	97000
56	56	Calle del Río No. 789	Cancún	Quintana Roo	77500
57	57	Avenida de los Pinos No. 456	Puebla	Puebla	72000
58	58	Calle Principal No. 789	Guadalajara	Jalisco	44100
59	59	Avenida Central No. 321	Monterrey	Nuevo León	64000
60	60	Calle del Sol No. 654	Querétaro	Querétaro	76000
61	61	Avenida de la Luna No. 321	Toluca	Estado de México	50090
62	62	Calle Principal No. 789	Mérida	Yucatán	97000
63	63	Avenida Central No. 456	Cancún	Quintana Roo	77500
64	64	Calle del Bosque No. 654	Puebla	Puebla	72000
65	65	Avenida Reforma No. 321	Guadalajara	Jalisco	44100
66	66	Calle del Río No. 789	Monterrey	Nuevo León	64000
67	67	Avenida de los Pinos No. 456	Querétaro	Querétaro	76000
68	68	Calle Principal No. 789	Toluca	Estado de México	50090
69	69	Avenida Central No. 321	Mérida	Yucatán	97000
70	70	Calle del Sol No. 654	Cancún	Quintana Roo	77500
71	71	Avenida de la Luna No. 321	Puebla	Puebla	72000
72	72	Calle Principal No. 789	Guadalajara	Jalisco	44100
73	73	Avenida Central No. 456	Monterrey	Nuevo León	64000
74	74	Calle del Bosque No. 654	Querétaro	Querétaro	76000
75	75	Avenida Reforma No. 321	Toluca	Estado de México	50090
76	76	Calle del Río No. 789	Mérida	Yucatán	97000
77	77	Avenida de los Pinos No. 456	Cancún	Quintana Roo	77500
78	78	Calle Principal No. 789	Puebla	Puebla	72000
79	79	Avenida Central No. 321	Guadalajara	Jalisco	44100
80	80	Calle del Sol No. 654	Monterrey	Nuevo León	64000
81	81	Avenida de la Luna No. 321	Querétaro	Querétaro	76000
82	82	Calle Principal No. 789	Toluca	Estado de México	50090
83	83	Avenida Central No. 456	Mérida	Yucatán	97000
84	84	Calle del Bosque No. 654	Cancún	Quintana Roo	77500
85	85	Avenida Reforma No. 321	Puebla	Puebla	72000
86	86	Calle del Río No. 789	Guadalajara	Jalisco	44100
87	87	Avenida de los Pinos No. 456	Monterrey	Nuevo León	64000
88	88	Calle Principal No. 789	Querétaro	Querétaro	76000
89	89	Avenida Central No. 321	Mérida	Yucatán	97000
90	90	Calle del Sol No. 654	Cancún	Quintana Roo	77500
91	91	Avenida de la Luna No. 321	Puebla	Puebla	72000
92	92	Calle Principal No. 789	Guadalajara	Jalisco	44100
93	93	Avenida Central No. 456	Monterrey	Nuevo León	64000
94	94	Calle del Bosque No. 654	Querétaro	Querétaro	76000
95	95	Avenida Reforma No. 321	Toluca	Estado de México	50090
96	96	Calle del Río No. 789	Mérida	Yucatán	97000
97	97	Avenida de los Pinos No. 456	Cancún	Quintana Roo	77500
98	98	Calle Principal No. 789	Puebla	Puebla	72000
99	99	Avenida Central No. 321	Guadalajara	Jalisco	44100
100	100	Calle del Sol No. 654	Monterrey	Nuevo León	64000
\.


--
-- TOC entry 4082 (class 0 OID 16382039)
-- Dependencies: 228
-- Data for Name: empleados; Type: TABLE DATA; Schema: public; Owner: jqdcxclm
--

COPY public.empleados (id_empleados, nombre, apellido, fecha_de_nacimiento, direccion, correo_electronio, id_departamento, id_salarios, id_direcciones, id_dependientes, id_historial, id_supervisor) FROM stdin;
3	Juan	Hernández	19881230	Avenida Juárez No. 456	juan.hdez@yahoo.com	3	3	3	3	3	3
4	María	López	19900725	Calle Reforma No. 789	maria.lopez@gmail.com	4	4	4	4	4	4
5	Carlos	Martínez	19930218	Avenida Hidalgo No. 234	carlos.mtz@hotmail.com	5	5	5	5	5	5
6	Laura	Rodríguez	19920910	Calle Morelos No. 567	laura.rodriguez@yahoo.com	6	6	6	6	6	6
7	Pedro	González	19931205	Calle Principal No. 789	pedro.gonzalez@gmail.com	7	7	7	7	7	7
8	Ana	Sánchez	19970620	Avenida Libertad No. 890	ana.sanchez@hotmail.com	8	8	8	8	8	8
9	Miguel	Torres	19910508	Calle 8 No. 234	miguel.torres@yahoo.com	9	9	9	9	9	9
11	Javier	Vargas	19981203	Calle Juárez No. 890	javier.vargas@hotmail.com	11	11	11	11	11	11
12	Valentina	Morales	19930128	Avenida Morelia No. 234	valentina.morales@yahoo.com	12	12	12	12	12	12
13	Fernando	Lara	19901215	Calle 9 No. 345	fernando.lara@gmail.com	13	13	13	13	13	13
14	Adriana	Pérez	19980928	Avenida México No. 678	adriana.perez@yahoo.com	14	14	14	14	14	14
15	Roberto	Díaz	19870602	Calle Reforma No. 901	roberto.diaz@hotmail.com	15	15	15	15	15	15
16	Gabriela	Guzmán	19951119	Avenida Principal No. 234	gabriela.guzman@gmail.com	16	16	16	16	16	16
17	Francisco	Ortega	19920723	Calle Juárez No. 567	francisco.ortega@yahoo.com	17	17	17	17	17	17
18	Daniela	Santos	19891212	Avenida del Sol No. 890	daniela.santos@hotmail.com	18	18	18	18	18	18
19	Luis	Vega	19960105	Calle Morelia No. 123	luis.vega@gmail.com	19	19	19	19	19	19
21	Oscar	Fuentes	19851008	Calle 10 No. 789	oscar.fuentes@hotmail.com	21	21	21	21	21	21
22	Mariana	Rojas	19940922	Avenida Reforma No. 234	mariana.rojas@gmail.com	22	22	22	22	22	22
23	Hugo	Chávez	19970214	Calle Principal No. 567	hugo.chavez@yahoo.com	23	23	23	23	23	23
24	Paulina	Navarro	19900927	Avenida Hidalgo No. 890	paulina.navarro@hotmail.com	24	24	24	24	24	24
25	Takina	Lycoris	20220519	Tokio principal No.2	Takina.lycoris@hotmail.com	25	25	25	25	25	25
26	Sofía	Hernández	19930203	Calle 11 No. 123	sofia.hernandez@gmail.com	26	26	26	26	26	26
27	Jorge	Guerrero	19970118	Avenida Juárez No. 456	jorge.guerrero@yahoo.com	27	27	27	27	27	27
28	Carmen	Paredes	19890805	Calle Reforma No. 789	carmen.paredes@hotmail.com	28	28	28	28	28	28
29	Raúl	Luna	19911220	Avenida Hidalgo No. 234	raul.luna@gmail.com	29	29	29	29	29	29
30	Fernanda	Vargas	19951212	Calle Morelos No. 567	fernanda.vargas@yahoo.com	30	30	30	30	30	30
31	Andrés	Mendoza	19920930	Avenida Principal No. 890	andres.mendoza@hotmail.com	31	31	31	31	31	31
32	Valeria	Ríos	19980627	Calle Libertad No. 123	valeria.rios@gmail.com	32	32	32	32	32	32
33	Héctor	Silva	19940314	Avenida México No. 456	hector.silva@yahoo.com	33	33	33	33	33	33
34	Lorena	Ortega	19900317	Calle Juárez No. 789	lorena.ortega@hotmail.com	34	34	34	34	34	34
36	Lucía	Vega	19871123	Calle Principal No. 567	lucia.vega@yahoo.com	36	36	36	36	36	36
37	Diego	Santos	19931202	Avenida del Sol No. 890	diego.santos@hotmail.com	37	37	37	37	37	37
38	Valentina	Morales	19940817	Avenida Morelia No. 123	valentina.morales@gmail.com	38	38	38	38	38	38
39	Javier	Fernández	19920729	Calle 12 No. 456	javier.fernandez@yahoo.com	39	39	39	39	39	39
40	Camila	López	19900112	Avenida Libertad No. 789	camila.lopez@hotmail.com	30	40	40	40	40	40
41	Gabriel	Herrera	19930525	Calle 13 No. 234	gabriel.herrera@gmail.com	41	41	41	41	41	41
42	Mariana	Guzmán	19981211	Avenida Hidalgo No. 567	mariana.guzman@yahoo.com	42	42	42	42	42	42
43	Sebastián	Rojas	19951204	Calle Morelos No. 890	sebastian.rojas@hotmail.com	43	43	43	43	43	43
44	Isabella	Chávez	19920127	Avenida Principal No. 123	isabella.chavez@gmail.com	44	44	44	44	44	44
45	Ricardo	Navarro	19970510	Calle Juárez No. 456	ricardo.navarro@yahoo.com	45	45	45	45	45	45
46	Renata	Fuentes	19941103	Avenida Reforma No. 789	renata.fuentes@hotmail.com	46	46	46	46	46	46
47	Samuel	Santos	19900826	Calle Principal No. 234	samuel.santos@gmail.com	47	47	47	47	47	47
48	Valeria	Hernández	19931221	Avenida Juárez No. 567	valeria.hernandez@yahoo.com	48	48	48	48	48	48
49	Martín	Luna	19960714	Calle Reforma No. 890	martin.luna@hotmail.com	49	49	49	49	49	49
50	Carolina	Mendoza	19920627	Avenida Hidalgo No. 123	carolina.mendoza@gmail.com	50	50	50	50	50	50
51	Mateo	Vargas	19950219	Calle Morelia No. 456	mateo.vargas@yahoo.com	51	51	51	51	51	51
52	Valentina	Silva	19911002	Avenida México No. 789	valentina.silva@hotmail.com	52	52	52	52	52	52
53	Juan	Ortega	19971225	Calle Juárez No. 234	juan.ortega@gmail.com	53	53	53	53	53	53
54	Isabella	González	19940808	Avenida Reforma No. 567	isabella.gonzalez@yahoo.com	54	54	54	54	54	54
55	Emilio	Vega	19910903	Calle Principal No. 890	emilio.vega@hotmail.com	55	55	55	55	55	55
56	Julia	Santos	19961216	Avenida del Sol No. 123	julia.santos@gmail.com	56	56	56	56	56	56
57	Sebastián	Hernández	19930429	Calle 14 No. 456	sebastian.hernandez@yahoo.com	57	57	57	57	57	57
58	Gabriela	Fernández	19900812	Avenida Libertad No. 789	gabriela.fernandez@hotmail.com	58	58	58	58	58	58
59	Andrés	Paredes	19950205	Calle 15 No. 234	andres.paredes@gmail.com	59	59	59	59	59	59
60	Valeria	López	19970428	Avenida Juárez No. 567	valeria.lopez@yahoo.com	60	60	60	60	60	60
61	Francisco	Herrera	19910911	Calle Reforma No. 890	francisco.herrera@hotmail.com	61	61	61	61	61	61
62	Sofía	Gutiérrez	19940521	Avenida Principal No. 123	sofia.gutierrez@gmail.com	62	62	62	62	62	62
63	Benjamín	López	19980615	Calle Juárez No. 456	benjamin.lopez@yahoo.com	63	63	63	63	63	63
64	Lucía	Ramírez	19950328	Avenida Reforma No. 789	lucia.ramirez@hotmail.com	64	64	64	64	64	64
65	Matías	Torres	19921207	Calle Libertad No. 234	matias.torres@gmail.com	65	65	65	65	65	65
66	Valentina	Hernández	19970911	Avenida Hidalgo No. 567	valentina.hernandez@yahoo.com	66	66	66	66	66	66
67	Sebastián	Gómez	19930824	Calle Morelos No. 890	sebastian.gomez@hotmail.com	67	67	67	67	67	67
68	Isabella	Morales	19950117	Avenida Principal No. 123	isabella.morales@gmail.com	68	68	68	68	68	68
69	Emilio	Sánchez	19990630	Calle Juárez No. 456	emilio.sanchez@yahoo.com	69	69	69	69	69	69
70	Valeria	Flores	19960723	Avenida Reforma No. 789	valeria.flores@hotmail.com	70	70	70	70	70	70
71	Joaquín	Vargas	19921106	Calle Libertad No. 234	joaquin.vargas@gmail.com	71	71	71	71	71	71
72	Gabriela	Ríos	19980919	Avenida Hidalgo No. 567	gabriela.rios@yahoo.com	72	72	72	72	72	72
73	Samuel	Herrera	19950502	Calle Morelos No. 890	samuel.herrera@hotmail.com	73	73	73	73	73	73
76	Valentina	Pérez	19920110	Avenida Reforma No. 789	valentina.perez@hotmail.com	76	76	76	76	76	76
77	Santiago	Ramírez	19971023	Calle Libertad No. 234	santiago.ramirez@gmail.com	77	77	77	77	77	77
78	Victoria	Hernández	19951206	Avenida Hidalgo No. 567	victoria.hernandez@yahoo.com	78	78	78	78	78	78
79	Alejandro	Gómez	19910819	Calle Morelos No. 890	alejandro.gomez@hotmail.com	79	79	79	79	79	79
80	Emma	Morales	19930302	Avenida Principal No. 123	emma.morales@gmail.com	80	80	80	80	80	80
81	Sebastián	Sánchez	19970415	Calle Juárez No. 456	sebastian.sanchez@yahoo.com	81	81	81	81	81	81
82	Mariana	Flores	19920728	Avenida Reforma No. 789	mariana.flores@hotmail.com	82	82	82	82	82	82
83	Diego	Vargas	19980810	Calle Libertad No. 234	diego.vargas@gmail.com	83	83	83	83	83	83
84	Valeria	Ríos	19940923	Avenida Hidalgo No. 567	valeria.rios@yahoo.com	84	84	84	84	84	84
85	Carlos	Herrera	19961206	Calle Morelos No. 890	carlos.herrera@hotmail.com	85	85	85	85	85	85
86	Natalia	Gutiérrez	19941003	Avenida Principal No. 123	natalia.gutierrez@gmail.com	86	86	86	86	86	86
87	Martín	López	19980315	Calle Juárez No. 456	martin.lopez@yahoo.com	87	87	87	87	87	87
88	Valentina	Ramírez	19950228	Avenida Reforma No. 789	valentina.ramirez@hotmail.com	88	88	88	88	88	88
89	Luis	Torres	19921007	Calle Libertad No. 234	luis.torres@gmail.com	89	89	89	89	89	89
90	Fernanda	Hernández	19970311	Avenida Hidalgo No. 567	fernanda.hernandez@yahoo.com	90	90	90	90	90	90
91	Santiago	Gómez	19930824	Calle Morelos No. 890	santiago.gomez@hotmail.com	91	91	91	91	91	91
92	Isabella	Morales	19950117	Avenida Principal No. 123	isabella.morales@gmail.com	92	92	92	92	92	92
93	Sebastián	Sánchez	19990630	Calle Juárez No. 456	sebastian.sanchez@yahoo.com	93	93	93	93	93	93
94	Valeria	Flores	19960723	Avenida Reforma No. 789	valeria.flores@hotmail.com	94	94	94	94	94	94
95	Joaquín	Vargas	19921106	Calle Libertad No. 234	joaquin.vargas@gmail.com	95	95	95	95	95	95
96	Gabriela	Ríos	19980919	Avenida Hidalgo No. 567	gabriela.rios@yahoo.com	96	96	96	96	96	96
97	Samuel	Herrera	19950502	Calle Morelos No. 890	samuel.herrera@hotmail.com	97	97	97	97	97	97
98	Valentina	Silva	19981203	Avenida Reforma No. 789	valentina.silva@hotmail.com	98	98	98	98	98	98
99	Andrés	Gómez	19931215	Avenida Principal No. 123	andres.gomez@gmail.com	99	99	99	99	99	99
100	Carolina	López	19970928	Calle Juárez No. 456	carolina.lopez@yahoo.com	100	100	100	100	100	100
1	abrhaa	jimenez	20010909	Calle cadete No. 09	abraham.jmnz@gmail.com	1	1	1	1	1	1
\.


--
-- TOC entry 4081 (class 0 OID 16382034)
-- Dependencies: 227
-- Data for Name: historial_de_empleo; Type: TABLE DATA; Schema: public; Owner: jqdcxclm
--

COPY public.historial_de_empleo (id_historial, id_empleado, empresa, cargo, fecha_de_inicio, fecha_de_termino) FROM stdin;
1	1	Networks.sa.cv	Vendedor	20101201	\N
2	2	Tech Solutions	Desarrollador	20150115	20170228
3	3	Global Corp	Analista de Datos	20090810	20121130
4	4	Innovative Systems	Gerente de Proyectos	20180301	\N
5	5	Tech Innovators	Especialista en Redes	20140110	20191031
6	6	Global Solutions	Consultor ERP	20130620	20140930
7	7	Digital Services	Diseñador Web	20121115	20150228
8	8	Data Insights	Analista de Negocios	20170103	20181231
9	9	Smart Technologies	Ingeniero de Software	20150215	20180731
10	10	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
11	11	Networks.sa.cv	Vendedor	20101201	\N
12	12	Tech Solutions	Desarrollador	20150115	20170228
13	13	Global Corp	Analista de Datos	20090810	20121130
14	14	Innovative Systems	Gerente de Proyectos	20180301	\N
15	15	Tech Innovators	Especialista en Redes	20140110	20191031
16	16	Global Solutions	Consultor ERP	20130620	20140930
17	17	Digital Services	Diseñador Web	20121115	20150228
18	18	Data Insights	Analista de Negocios	20170103	20181231
19	19	Smart Technologies	Ingeniero de Software	20150215	20180731
20	20	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
21	21	Networks.sa.cv	Vendedor	20101201	\N
22	22	Tech Solutions	Desarrollador	20150115	20170228
23	23	Global Corp	Analista de Datos	20090810	20121130
24	24	Innovative Systems	Gerente de Proyectos	20180301	\N
25	25	Tech Innovators	Especialista en Redes	20140110	20191031
26	26	Global Solutions	Consultor ERP	20130620	20140930
27	27	Digital Services	Diseñador Web	20121115	20150228
28	28	Data Insights	Analista de Negocios	20170103	20181231
29	29	Smart Technologies	Ingeniero de Software	20150215	20180731
30	30	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
31	31	Networks.sa.cv	Vendedor	20101201	\N
32	32	Tech Solutions	Desarrollador	20150115	20170228
33	33	Global Corp	Analista de Datos	20090810	20121130
34	34	Innovative Systems	Gerente de Proyectos	20180301	\N
35	35	Tech Innovators	Especialista en Redes	20140110	20191031
36	36	Global Solutions	Consultor ERP	20130620	20140930
37	37	Digital Services	Diseñador Web	20121115	20150228
38	38	Data Insights	Analista de Negocios	20170103	20181231
39	39	Smart Technologies	Ingeniero de Software	20150215	20180731
40	40	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
41	41	Networks.sa.cv	Vendedor	20101201	\N
42	42	Tech Solutions	Desarrollador	20150115	20170228
43	43	Global Corp	Analista de Datos	20090810	20121130
44	44	Innovative Systems	Gerente de Proyectos	20180301	\N
45	45	Tech Innovators	Especialista en Redes	20140110	20191031
46	46	Global Solutions	Consultor ERP	20130620	20140930
47	47	Digital Services	Diseñador Web	20121115	20150228
48	48	Data Insights	Analista de Negocios	20170103	20181231
49	49	Smart Technologies	Ingeniero de Software	20150215	20180731
50	50	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
51	51	Networks.sa.cv	Vendedor	20101201	\N
52	52	Tech Solutions	Desarrollador	20150115	20170228
53	53	Global Corp	Analista de Datos	20090810	20121130
54	54	Innovative Systems	Gerente de Proyectos	20180301	\N
55	55	Tech Innovators	Especialista en Redes	20140110	20191031
56	56	Global Solutions	Consultor ERP	20130620	20140930
57	57	Digital Services	Diseñador Web	20121115	20150228
58	58	Data Insights	Analista de Negocios	20170103	20181231
59	59	Smart Technologies	Ingeniero de Software	20150215	20180731
60	60	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
61	61	Networks.sa.cv	Vendedor	20101201	\N
62	62	Tech Solutions	Desarrollador	20150115	20170228
63	63	Global Corp	Analista de Datos	20090810	20121130
64	64	Innovative Systems	Gerente de Proyectos	20180301	\N
65	65	Tech Innovators	Especialista en Redes	20140110	20191031
66	66	Global Solutions	Consultor ERP	20130620	20140930
67	67	Digital Services	Diseñador Web	20121115	20150228
68	68	Data Insights	Analista de Negocios	20170103	20181231
69	69	Smart Technologies	Ingeniero de Software	20150215	20180731
70	70	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
71	71	Networks.sa.cv	Vendedor	20101201	\N
72	72	Tech Solutions	Desarrollador	20150115	20170228
73	73	Global Corp	Analista de Datos	20090810	20121130
74	74	Innovative Systems	Gerente de Proyectos	20180301	\N
75	75	Tech Innovators	Especialista en Redes	20140110	20191031
76	76	Global Solutions	Consultor ERP	20130620	20140930
77	77	Digital Services	Diseñador Web	20121115	20150228
78	78	Data Insights	Analista de Negocios	20170103	20181231
79	79	Smart Technologies	Ingeniero de Software	20150215	20180731
80	80	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
81	81	Networks.sa.cv	Vendedor	20101201	\N
82	82	Tech Solutions	Desarrollador	20150115	20170228
83	83	Global Corp	Analista de Datos	20090810	20121130
84	84	Innovative Systems	Gerente de Proyectos	20180301	\N
85	85	Tech Innovators	Especialista en Redes	20140110	20191031
86	86	Global Solutions	Consultor ERP	20130620	20140930
87	87	Digital Services	Diseñador Web	20121115	20150228
88	88	Data Insights	Analista de Negocios	20170103	20181231
89	89	Smart Technologies	Ingeniero de Software	20150215	20180731
90	90	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
91	91	Networks.sa.cv	Vendedor	20101201	\N
92	92	Tech Solutions	Desarrollador	20150115	20170228
93	93	Global Corp	Analista de Datos	20090810	20121130
94	94	Innovative Systems	Gerente de Proyectos	20180301	\N
95	95	Tech Innovators	Especialista en Redes	20140110	20191031
96	96	Global Solutions	Consultor ERP	20130620	20140930
97	97	Digital Services	Diseñador Web	20121115	20150228
98	98	Data Insights	Analista de Negocios	20170103	20181231
99	99	Smart Technologies	Ingeniero de Software	20150215	20180731
100	100	Innovation Labs	Investigador de Inteligencia Artificial	20150101	\N
\.


--
-- TOC entry 4078 (class 0 OID 16382019)
-- Dependencies: 224
-- Data for Name: salarios; Type: TABLE DATA; Schema: public; Owner: jqdcxclm
--

COPY public.salarios (id_salarios, id_empleado, salario, fecha_de_inicio, fecha_de_termino) FROM stdin;
1	1	15000	20040620	\N
2	2	18000	20100115	20131231
3	3	20000	20080110	20121130
4	4	25000	20150101	\N
5	5	22000	20120120	20170630
6	6	19000	20100615	20111231
7	7	21000	20140101	\N
8	8	24000	20130510	20171231
9	9	23000	20110105	20140331
10	10	26000	20170101	\N
11	11	15000	20040620	\N
12	12	18000	20100115	20131231
13	13	20000	20080110	20121130
14	14	25000	20150101	\N
15	15	22000	20120120	20170630
16	16	19000	20100615	20111231
17	17	21000	20140101	\N
18	18	24000	20130510	20171231
19	19	23000	20110105	20140331
21	21	15000	20040620	\N
22	22	18000	20100115	20131231
23	23	20000	20080110	20121130
24	24	25000	20150101	\N
25	25	22000	20120120	20170630
26	26	19000	20100615	20111231
27	27	21000	20140101	\N
28	28	24000	20130510	20171231
29	29	23000	20110105	20140331
30	30	26000	20170101	\N
31	31	15000	20040620	\N
32	32	18000	20100115	20131231
33	33	20000	20080110	20121130
34	34	25000	20150101	\N
35	35	22000	20120120	20170630
36	36	19000	20100615	20111231
37	37	23000	20140101	\N
38	38	25000	20130510	20171231
39	39	22000	20110105	20140331
40	40	26000	20170101	\N
41	41	18000	20040620	\N
42	42	21000	20100115	20131231
43	43	20000	20080110	20121130
44	44	24000	20150101	\N
45	45	19000	20120120	20170630
46	46	23000	20100615	20111231
47	47	26000	20140101	\N
48	48	25000	20130510	20171231
49	49	22000	20110105	20140331
50	50	18000	20170101	\N
51	51	19000	20040620	\N
52	52	21000	20100115	20131231
53	53	20000	20080110	20121130
54	54	24000	20150101	\N
55	55	23000	20120120	20170630
56	56	26000	20100615	20111231
57	57	25000	20140101	\N
58	58	22000	20130510	20171231
59	59	18000	20110105	20140331
60	60	19000	20170101	\N
61	61	21000	20040620	\N
62	62	20000	20100115	20131231
63	63	24000	20080110	20121130
64	64	23000	20150101	\N
65	65	26000	20120120	20170630
66	66	25000	20100615	20111231
67	67	22000	20140101	\N
68	68	18000	20130510	20171231
69	69	19000	20110105	20140331
70	70	21000	20170101	\N
71	71	20000	20040620	\N
72	72	20500	20040622	\N
73	73	23000	20080110	20121130
74	74	26000	20150101	\N
75	75	25000	20120120	20170630
76	76	22000	20100615	20111231
77	77	18000	20140101	\N
78	78	19000	20130510	20171231
79	79	21000	20110105	20140331
80	80	20000	20170101	\N
81	81	24000	20040620	\N
82	82	23000	20100115	20131231
83	83	26000	20080110	20121130
84	84	25000	20150101	\N
85	85	22000	20120120	20170630
86	86	18000	20100615	20111231
87	87	19000	20140101	\N
88	88	21000	20130510	20171231
89	89	20000	20110105	20140331
90	90	24000	20170101	\N
91	91	23000	20040620	\N
92	92	26000	20100115	20131231
93	93	25000	20080110	20121130
94	94	22000	20150101	\N
95	95	18000	20120120	20170630
96	96	19000	20100615	20111231
97	97	21000	20140101	\N
98	98	20000	20130510	20171231
99	99	24000	20110105	20140331
100	100	23000	20170101	\N
103	103	5000	20220515	\N
104	104	5000	20220515	20350102
\.


--
-- TOC entry 4077 (class 0 OID 16382014)
-- Dependencies: 223
-- Data for Name: supervisor; Type: TABLE DATA; Schema: public; Owner: jqdcxclm
--

COPY public.supervisor (id_supervisor, nombre, descripcion, id_empleado) FROM stdin;
1	Kirito	Encargado del area de ventas	1
2	Asuna	Encargada del departamento de marketing	2
3	Eren	Supervisor de producción	3
4	Mikasa	Encargada de logística	4
5	Levi	Supervisor de calidad	5
6	Emma	Encargada de recursos humanos	6
7	Norman	Supervisor de investigación y desarrollo	7
8	Ray	Encargado del departamento financiero	8
9	Natasha	Supervisora de atención al cliente	9
10	Bruce	Encargado de operaciones	10
11	Tony	Supervisor de ingeniería	11
12	Peter	Encargado del departamento de ventas	12
13	Steve	Supervisor de compras	13
14	Diana	Encargada de relaciones públicas	14
15	Clark	Supervisor de distribución	15
16	Barry	Encargado de control de inventario	16
17	Selina	Supervisora de marketing digital	17
18	Arthur	Encargado de gestión de proyectos	18
19	Oliver	Supervisor de operaciones	19
20	Diana	Encargada del departamento de recursos humanos	20
21	Wade	Supervisor de logística	21
22	Victor	Encargado de control de calidad	22
23	Clark	Supervisor de finanzas	23
24	Peter	Encargado de atención al cliente	24
25	Bruce	Supervisor de producción	25
26	Tony	Encargado de investigación y desarrollo	26
27	Natasha	Supervisora de marketing	27
28	Steve	Encargado de recursos humanos	28
29	Diana	Supervisora de ventas	29
30	Barry	Encargado de compras	30
31	Arthur	Supervisor de relaciones públicas	31
32	Oliver	Encargado de distribución	32
33	Selina	Supervisora de control de inventario	33
34	Wade	Encargado de marketing digital	34
35	Victor	Supervisor de gestión de proyectos	35
36	Clark	Encargado de operaciones	36
37	Peter	Supervisor de recursos humanos	37
38	Bruce	Encargado de logística	38
39	Tony	Supervisor de control de calidad	39
40	Natasha	Encargada de finanzas	41
41	Steve	Supervisor de atención al cliente	42
42	Diana	Encargada de operaciones	43
43	Barry	Supervisor de ingeniería	44
44	Arthur	Encargado del departamento de ventas	45
45	Oliver	Supervisor de compras	46
46	Selina	Encargada de relaciones públicas	47
47	Victor	Supervisor de distribución	48
48	Clark	Encargado de control de inventario	49
49	Peter	Supervisora de marketing digital	50
50	Bruce	Encargado de gestión de proyectos	51
51	Tony	Supervisor de operaciones	52
52	Natasha	Encargada del departamento de recursos humanos	53
53	Steve	Supervisor de logística	54
54	Diana	Encargada de control de calidad	55
55	Barry	Supervisor de finanzas	56
56	Arthur	Encargado de atención al cliente	57
57	Oliver	Supervisor de producción	58
58	Selina	Encargada de investigación y desarrollo	59
59	Victor	Supervisor de marketing	60
60	Clark	Encargado de recursos humanos	61
61	Peter	Supervisor de ventas	62
62	Bruce	Encargado de compras	63
63	Tony	Supervisora de relaciones públicas	64
64	Natasha	Encargada de distribución	65
65	Steve	Supervisor de control de inventario	66
66	Diana	Encargada de marketing digital	67
67	Barry	Supervisor de gestión de proyectos	68
68	Arthur	Encargado de operaciones	69
69	Oliver	Supervisor de recursos humanos	70
70	Selina	Encargada de logística	71
71	Victor	Supervisor de control de calidad	72
72	Alex	Encargado del departamento de marketing	73
73	Sophia	Supervisora de producción	74
74	Liam	Encargado de logística	75
75	Olivia	Supervisora de calidad	76
76	Noah	Encargado de recursos humanos	77
77	Ava	Supervisora de investigación y desarrollo	78
78	Isabella	Encargada del departamento financiero	79
79	Mia	Supervisora de atención al cliente	80
80	Emma	Encargada de operaciones	81
81	Charlotte	Supervisora de ingeniería	82
82	Lucas	Encargado del departamento de ventas	83
83	Amelia	Supervisora de compras	84
84	Harper	Encargada de relaciones públicas	85
85	Ethan	Supervisor de distribución	86
86	Liam	Encargado de control de inventario	87
87	Isabella	Supervisora de marketing digital	88
88	James	Encargado de gestión de proyectos	89
89	Sophia	Supervisora de operaciones	90
90	Mia	Encargada del departamento de recursos humanos	91
91	Amelia	Supervisora de logística	92
92	Evelyn	Encargada de control de calidad	93
93	Lucas	Supervisor de finanzas	94
94	Avery	Encargado de atención al cliente	95
95	Daniel	Supervisor de producción	96
96	Madison	Encargada de investigación y desarrollo	97
97	Logan	Supervisor de marketing	98
98	Jack	Encargado de recursos humanos	99
99	Scarlett	Supervisora de ventas	100
100	Chisato	Supervisora de ventas	100
\.


--
-- TOC entry 3932 (class 2606 OID 16382013)
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id_departamento);


--
-- TOC entry 3940 (class 2606 OID 16382033)
-- Name: dependientes dependientes_pkey; Type: CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.dependientes
    ADD CONSTRAINT dependientes_pkey PRIMARY KEY (id_dependientes);


--
-- TOC entry 3938 (class 2606 OID 16382028)
-- Name: direcciones direcciones_pkey; Type: CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.direcciones
    ADD CONSTRAINT direcciones_pkey PRIMARY KEY (id_direcciones);


--
-- TOC entry 3944 (class 2606 OID 16382043)
-- Name: empleados empleados_pkey; Type: CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_pkey PRIMARY KEY (id_empleados);


--
-- TOC entry 3942 (class 2606 OID 16382038)
-- Name: historial_de_empleo historial_de_empleo_pkey; Type: CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.historial_de_empleo
    ADD CONSTRAINT historial_de_empleo_pkey PRIMARY KEY (id_historial);


--
-- TOC entry 3936 (class 2606 OID 16382023)
-- Name: salarios salarios_pkey; Type: CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.salarios
    ADD CONSTRAINT salarios_pkey PRIMARY KEY (id_salarios);


--
-- TOC entry 3934 (class 2606 OID 16382018)
-- Name: supervisor supervisor_pkey; Type: CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.supervisor
    ADD CONSTRAINT supervisor_pkey PRIMARY KEY (id_supervisor);


--
-- TOC entry 3945 (class 2606 OID 16382044)
-- Name: empleados empleados_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.departamentos(id_departamento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3948 (class 2606 OID 16382059)
-- Name: empleados empleados_id_dependientes_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_dependientes_fkey FOREIGN KEY (id_dependientes) REFERENCES public.dependientes(id_dependientes) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3947 (class 2606 OID 16382054)
-- Name: empleados empleados_id_direcciones_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_direcciones_fkey FOREIGN KEY (id_direcciones) REFERENCES public.direcciones(id_direcciones) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3949 (class 2606 OID 16382064)
-- Name: empleados empleados_id_historial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_historial_fkey FOREIGN KEY (id_historial) REFERENCES public.historial_de_empleo(id_historial) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3946 (class 2606 OID 16382049)
-- Name: empleados empleados_id_salarios_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_salarios_fkey FOREIGN KEY (id_salarios) REFERENCES public.salarios(id_salarios) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3950 (class 2606 OID 16382069)
-- Name: empleados empleados_id_supervisor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jqdcxclm
--

ALTER TABLE ONLY public.empleados
    ADD CONSTRAINT empleados_id_supervisor_fkey FOREIGN KEY (id_supervisor) REFERENCES public.supervisor(id_supervisor) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2023-06-12 12:53:55 CST

--
-- PostgreSQL database dump complete
--

