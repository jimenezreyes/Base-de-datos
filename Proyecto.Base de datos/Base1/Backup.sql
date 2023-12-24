--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3
-- Dumped by pg_dump version 15.3

-- Started on 2023-06-11 23:24:44

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
-- TOC entry 864 (class 1247 OID 28137)
-- Name: concepto_pago; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.concepto_pago AS character varying(7)
	CONSTRAINT concepto_pago_check CHECK (((VALUE)::text = ANY ((ARRAY['normal'::character varying, 'adeudo'::character varying])::text[])));


ALTER DOMAIN public.concepto_pago OWNER TO postgres;

--
-- TOC entry 860 (class 1247 OID 28134)
-- Name: estado_copia; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.estado_copia AS character varying(8)
	CONSTRAINT estado_copia_check CHECK (((VALUE)::text = ANY ((ARRAY['bien'::character varying, 'dañada'::character varying, 'perdida'::character varying])::text[])));


ALTER DOMAIN public.estado_copia OWNER TO postgres;

--
-- TOC entry 856 (class 1247 OID 28131)
-- Name: rango_edad; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.rango_edad AS integer
	CONSTRAINT rango_edad_check CHECK (((VALUE >= 18) AND (VALUE <= 130)));


ALTER DOMAIN public.rango_edad OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 28242)
-- Name: verificar_actividad_prestamo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_actividad_prestamo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.verificar_actividad_prestamo() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 28220)
-- Name: verificar_adeudo_activo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_adeudo_activo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.verificar_adeudo_activo() OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 28222)
-- Name: verificar_cantidad_copias(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_cantidad_copias() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.activo = true THEN
    IF (SELECT COUNT(*) FROM Prestamos WHERE id_cliente = NEW.id_cliente AND activo = true) >= 3 THEN
      RAISE EXCEPTION 'No se puede asociar más de 3 copias a un mismo cliente cuando activo es true.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.verificar_cantidad_copias() OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 28218)
-- Name: verificar_estado_copia(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_estado_copia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.verificar_estado_copia() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 28240)
-- Name: verificar_fecha_adeudo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_fecha_adeudo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.verificar_fecha_adeudo() OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 28260)
-- Name: verificar_fecha_pago(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_fecha_pago() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.fecha_pago < (SELECT fecha_devolucion FROM Prestamos WHERE no_prestamo = NEW.no_prestamo) THEN
    RAISE EXCEPTION 'Error: La fecha de pago debe ser mayor o igual a la fecha de devolución del préstamo asociado';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.verificar_fecha_pago() OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 28238)
-- Name: verificar_monto_adeudo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_monto_adeudo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.verificar_monto_adeudo() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 28225)
-- Name: adeudos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adeudos (
    no_adeudo integer NOT NULL,
    no_prestamo integer NOT NULL,
    id_cliente character varying(11) NOT NULL,
    id_pelicula character varying(10) NOT NULL,
    no_copia integer NOT NULL,
    fecha_adeudo date NOT NULL,
    monto numeric(11,5) NOT NULL,
    activo boolean NOT NULL
);


ALTER TABLE public.adeudos OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 28224)
-- Name: adeudos_no_adeudo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adeudos_no_adeudo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adeudos_no_adeudo_seq OWNER TO postgres;

--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 220
-- Name: adeudos_no_adeudo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adeudos_no_adeudo_seq OWNED BY public.adeudos.no_adeudo;


--
-- TOC entry 214 (class 1259 OID 28139)
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    id_cliente character varying(11) NOT NULL,
    nombres character varying(30) NOT NULL,
    apellido_paterno character varying(30) NOT NULL,
    apellido_materno character varying(30) NOT NULL,
    direccion character varying(70) NOT NULL,
    email character varying(50),
    telefono character varying(10),
    edad public.rango_edad NOT NULL,
    CONSTRAINT chk_email_format CHECK (((email IS NULL) OR ((email)::text ~~ '%@%'::text))),
    CONSTRAINT chk_email_telefono CHECK ((((email IS NOT NULL) AND (telefono IS NULL)) OR ((email IS NULL) AND (telefono IS NOT NULL)) OR ((email IS NOT NULL) AND (telefono IS NOT NULL)))),
    CONSTRAINT chk_id_cliente_format CHECK (((id_cliente)::text ~ '^[A-Za-z]{5}\d{6}$'::text)),
    CONSTRAINT chk_telefono_format CHECK (((telefono IS NULL) OR ((telefono)::text ~ '^55\d{8}$'::text)))
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 28174)
-- Name: reseñas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."reseñas" (
    id_pelicula character varying(10) NOT NULL,
    id_cliente character varying(11) NOT NULL,
    calificacion integer NOT NULL,
    comentario text,
    CONSTRAINT "reseñas_calificacion_check" CHECK (((calificacion >= 0) AND (calificacion <= 5)))
);


ALTER TABLE public."reseñas" OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 28264)
-- Name: clientes_insatisfechos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.clientes_insatisfechos AS
 SELECT c.id_cliente,
    c.nombres,
    c.apellido_paterno,
    c.apellido_materno,
    COALESCE(c.email, c.telefono) AS contacto
   FROM (public.clientes c
     JOIN public."reseñas" r ON (((c.id_cliente)::text = (r.id_cliente)::text)))
  WHERE (r.calificacion <= 2)
  GROUP BY c.id_cliente, c.nombres, c.apellido_paterno, c.apellido_materno, c.email, c.telefono
 HAVING (count(*) > 1);


ALTER TABLE public.clientes_insatisfechos OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 28161)
-- Name: copias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.copias (
    no_copia integer NOT NULL,
    id_pelicula character varying(10) NOT NULL,
    estado public.estado_copia NOT NULL,
    CONSTRAINT copias_no_copia_check CHECK (((no_copia >= 1) AND (no_copia <= 5)))
);


ALTER TABLE public.copias OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 28245)
-- Name: pagos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pagos (
    no_pago integer NOT NULL,
    no_prestamo integer NOT NULL,
    id_cliente character varying(11) NOT NULL,
    id_pelicula character varying(10) NOT NULL,
    no_copia integer NOT NULL,
    fecha_pago date NOT NULL,
    monto numeric(11,5) NOT NULL,
    concepto public.concepto_pago NOT NULL
);


ALTER TABLE public.pagos OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 28269)
-- Name: historial_pagos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.historial_pagos AS
 SELECT c.id_cliente,
    (((((c.nombres)::text || ' '::text) || (c.apellido_paterno)::text) || ' '::text) || (c.apellido_materno)::text) AS cliente,
    string_agg(((((p.fecha_pago || ' - '::text) || p.monto) || ' - '::text) || (p.concepto)::text), '; '::text) AS historial_pagos
   FROM (public.clientes c
     JOIN public.pagos p ON (((c.id_cliente)::text = (p.id_cliente)::text)))
  GROUP BY c.id_cliente, c.nombres, c.apellido_paterno, c.apellido_materno;


ALTER TABLE public.historial_pagos OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 28244)
-- Name: pagos_no_pago_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pagos_no_pago_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pagos_no_pago_seq OWNER TO postgres;

--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 222
-- Name: pagos_no_pago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pagos_no_pago_seq OWNED BY public.pagos.no_pago;


--
-- TOC entry 215 (class 1259 OID 28152)
-- Name: peliculas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.peliculas (
    id_pelicula character varying(10) NOT NULL,
    titulo character varying(50) NOT NULL,
    "año_lanzamiento" integer NOT NULL,
    director character varying(90) NOT NULL,
    idioma character varying(30) NOT NULL,
    duracion time without time zone NOT NULL,
    genero character varying(30),
    CONSTRAINT "peliculas_año_lanzamiento_check" CHECK ((("año_lanzamiento" >= 1900) AND (("año_lanzamiento")::numeric <= EXTRACT(year FROM CURRENT_DATE)))),
    CONSTRAINT peliculas_id_pelicula_check CHECK (((id_pelicula)::text ~ '^[A-Za-z]{3}\d{3}[A-Za-z]{2}\d{2}$'::text))
);


ALTER TABLE public.peliculas OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 28274)
-- Name: peliculas_populares; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.peliculas_populares AS
 SELECT p.id_pelicula,
    p.titulo,
    p.director,
    p."año_lanzamiento",
    count(*) AS "cantidad_reseñas",
    avg(r.calificacion) AS puntuacion_promedio
   FROM (public.peliculas p
     LEFT JOIN public."reseñas" r ON (((p.id_pelicula)::text = (r.id_pelicula)::text)))
  GROUP BY p.id_pelicula, p.titulo, p.director, p."año_lanzamiento"
  ORDER BY (count(*)) DESC;


ALTER TABLE public.peliculas_populares OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 28193)
-- Name: prestamos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prestamos (
    no_prestamo integer NOT NULL,
    id_cliente character varying(11) NOT NULL,
    id_pelicula character varying(10) NOT NULL,
    no_copia integer NOT NULL,
    fecha_prestamo date NOT NULL,
    fecha_devolucion date NOT NULL,
    monto numeric(11,5) NOT NULL,
    activo boolean DEFAULT false NOT NULL,
    CONSTRAINT check_fechas CHECK ((fecha_devolucion >= fecha_prestamo)),
    CONSTRAINT prestamos_check CHECK (((activo = (fecha_devolucion >= CURRENT_DATE)) OR ((activo = false) AND (fecha_devolucion = CURRENT_DATE))))
);


ALTER TABLE public.prestamos OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 28192)
-- Name: prestamos_no_prestamo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prestamos_no_prestamo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prestamos_no_prestamo_seq OWNER TO postgres;

--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 218
-- Name: prestamos_no_prestamo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prestamos_no_prestamo_seq OWNED BY public.prestamos.no_prestamo;


--
-- TOC entry 3232 (class 2604 OID 28228)
-- Name: adeudos no_adeudo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adeudos ALTER COLUMN no_adeudo SET DEFAULT nextval('public.adeudos_no_adeudo_seq'::regclass);


--
-- TOC entry 3233 (class 2604 OID 28248)
-- Name: pagos no_pago; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos ALTER COLUMN no_pago SET DEFAULT nextval('public.pagos_no_pago_seq'::regclass);


--
-- TOC entry 3230 (class 2604 OID 28196)
-- Name: prestamos no_prestamo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos ALTER COLUMN no_prestamo SET DEFAULT nextval('public.prestamos_no_prestamo_seq'::regclass);


--
-- TOC entry 3440 (class 0 OID 28225)
-- Dependencies: 221
-- Data for Name: adeudos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adeudos (no_adeudo, no_prestamo, id_cliente, id_pelicula, no_copia, fecha_adeudo, monto, activo) FROM stdin;
1	1	ABCDE123456	ABC123ab01	1	2022-06-09	25.00000	f
2	2	ABCDE123456	XYZ987xy02	1	2022-06-09	25.00000	f
3	3	ABCDE123456	DEF456de03	1	2022-06-09	25.00000	f
4	4	FGHIJ789012	MNO654mn04	1	2022-06-09	25.00000	f
5	5	FGHIJ789012	JKL321jk06	1	2022-06-09	25.00000	f
6	6	FGHIJ789012	PQR987pq07	1	2022-06-09	25.00000	f
7	7	KLMNO234567	MNO654mn04	1	2022-06-09	25.00000	f
8	8	KLMNO234567	STU654st08	1	2022-06-09	25.00000	f
9	9	KLMNO234567	ABC123ab01	1	2022-06-09	25.00000	f
10	10	KLMNO234567	XYZ987xy02	1	2022-06-09	25.00000	f
11	11	KLMNO234567	DEF456de03	1	2022-06-09	25.00000	f
12	12	PQRST890123	DEF456de03	1	2022-07-21	25.00000	f
13	13	PQRST890123	MNO654mn04	1	2022-07-21	25.00000	f
14	14	UVWXY345678	JKL321jk06	1	2022-07-21	25.00000	f
15	15	UVWXY345678	PQR987pq07	1	2022-07-21	25.00000	f
16	16	UVWXY345678	STU654st08	1	2022-07-21	25.00000	f
17	17	ZACDE901234	VWX321vw09	1	2022-07-21	25.00000	f
18	18	ZACDE901234	YZA789yz10	1	2022-07-21	25.00000	f
19	19	FGHIJ567890	VWX321vw09	1	2022-07-21	25.00000	f
20	20	KLMNO012345	YZA789yz10	1	2022-07-21	25.00000	f
21	21	KLMNO012345	BCD123bc11	1	2022-07-21	25.00000	f
22	22	KLMNO012345	EFG456ef12	1	2022-07-29	25.00000	f
23	23	KLMNO012345	KLM321kl14	1	2022-07-29	25.00000	f
24	24	KLMNO012345	NOP654no15	1	2022-07-29	25.00000	f
25	25	PQRST678901	QRS987qr16	1	2022-07-29	25.00000	f
26	26	PQRST678901	TUV321tu17	1	2022-07-29	25.00000	f
27	27	UVWXY123456	YZA123yz19	1	2022-07-29	25.00000	f
28	28	ZBCDE789012	BCD456bc20	1	2022-07-29	25.00000	f
29	29	FGHIJ234567	EFG789ef21	1	2022-07-29	25.00000	f
30	30	KLMNO789012	HIJ321hi22	1	2022-07-29	25.00000	f
31	31	PQRST345678	HIJ321hi22	1	2022-07-29	25.00000	f
32	32	UVWXY890123	HIJ321hi22	1	2022-08-09	25.00000	f
33	33	ZABDE456789	HIJ321hi22	1	2022-08-09	25.00000	f
34	34	ZABDE456789	KLM654kl23	1	2022-08-09	25.00000	f
35	35	ZABDE456789	NOP987no24	1	2022-08-09	25.00000	f
36	36	ZABDE456789	QRS321qr25	1	2022-08-09	25.00000	f
37	37	ZABDE456789	TUV654tu26	1	2022-08-09	25.00000	f
38	38	ZABDE456789	WXY987wx27	1	2022-08-09	25.00000	f
39	39	ZABDE456789	YZA321yz28	1	2022-08-09	25.00000	f
40	40	PQRCI890123	BCD654bc29	1	2022-08-09	25.00000	f
41	41	PQRCI890123	ABC123ab31	1	2022-08-09	25.00000	f
42	42	PQRCI890123	DEF456de32	1	2022-08-18	25.00000	f
43	43	STUST901234	DEF456de32	1	2022-08-18	25.00000	f
44	44	STUST901234	ABC123ab31	1	2022-08-18	25.00000	f
45	45	VWXJF012345	ABC123ab31	1	2022-08-18	25.00000	f
46	46	YZADX123456	GHI789gh33	1	2022-08-18	25.00000	f
47	47	BCDTA234567	GHI789gh33	1	2022-08-18	25.00000	f
48	48	CDEAB345678	JKL321jk34	1	2022-08-18	25.00000	f
49	49	EFGBC456789	JKL321jk34	1	2022-08-18	25.00000	f
50	50	GHIII567890	JKL321jk34	1	2022-08-18	25.00000	f
51	51	GHIII567890	MNO654mn35	1	2022-08-18	25.00000	f
52	52	GHIII567890	PQR987pq36	1	2022-09-09	25.00000	f
53	53	IJKLK678901	PQR987pq36	1	2022-09-09	25.00000	f
54	54	KLMHH789012	VWX654vw38	1	2022-09-09	25.00000	f
55	55	KLMHH789012	STU321st37	1	2022-09-09	25.00000	f
56	56	KLMHH789012	YZA987yz39	1	2022-09-09	25.00000	f
57	57	KLMHH789012	BCD321bc40	1	2022-09-09	25.00000	f
58	58	KLMHH789012	HIJ987hi42	1	2022-09-09	25.00000	f
59	59	MNOYY890123	HIJ987hi42	1	2022-09-09	25.00000	f
60	60	MNOYY890123	KLM321kl43	1	2022-09-09	25.00000	f
61	61	PQRTG901234	KLM321kl43	1	2022-09-09	25.00000	f
62	63	VWXNN234456	QRS987qr45	1	2022-09-23	25.00000	f
63	64	YZAZA234567	QRS987qr45	1	2022-09-23	25.00000	f
64	65	BCDOI345678	QRS987qr45	1	2022-09-23	25.00000	f
65	66	CDECC456789	WXY654wx47	1	2022-09-23	25.00000	f
66	67	EFGER567890	WXY654wx47	1	2022-09-23	25.00000	f
67	68	GHIVV678901	DEF456eu62	1	2022-09-23	25.00000	f
68	69	IJKRS789012	GHI789eu63	1	2022-09-23	25.00000	f
69	70	KLMJD890123	MNO345eu65	1	2022-09-23	25.00000	f
70	71	STULI012345	MNO345eu65	1	2022-09-23	25.00000	f
71	72	PQRSS012345	MNO345eu65	1	2022-09-23	25.00000	f
72	73	STUHI123456	PQR678eu66	1	2022-10-10	25.00000	f
73	74	VWXXC234567	PQR678eu66	1	2022-10-10	25.00000	f
74	75	YZAVV345678	STU901eu67	1	2022-10-10	25.00000	f
75	76	BCDBC456709	YZA567eu69	1	2022-10-10	25.00000	f
76	77	CDEZX567890	EFG123eu71	1	2022-10-10	25.00000	f
77	78	EFGOI678901	BCD890eu70	1	2022-10-10	25.00000	f
78	79	GHIMM789012	NOP012eu74	1	2022-10-10	25.00000	f
79	80	IJKIK890123	QRS345eu75	2	2022-10-10	25.00000	f
80	81	KLMHH901234	TUV678eu76	1	2022-10-10	25.00000	f
81	82	KLMHH901234	ZAB234eu78	1	2022-10-10	25.00000	f
82	83	KLMHH901234	EFG890eu80	1	2022-10-18	25.00000	f
83	84	MNOMN012335	ZAB901eu87	1	2022-10-18	25.00000	f
84	85	MNOMN012335	ALV001us01	1	2022-10-18	25.00000	f
85	86	PQRTI223456	TRM002us01	1	2022-10-18	25.00000	f
86	87	STUVX256456	TRM002us01	1	2022-10-18	25.00000	f
87	88	VWXWW345778	TRM002us01	1	2022-10-18	25.00000	f
88	89	AZAAA456789	TRM002us01	1	2022-10-18	25.00000	f
89	90	BCDBB567890	TRM002us01	1	2022-10-18	25.00000	f
90	91	BCDBB567890	DPD004us01	1	2022-10-18	25.00000	f
91	92	CDEMM678901	RKY005us01	1	2022-10-18	25.00000	f
92	93	EFGEE789012	RKY005us01	1	2022-10-25	25.00000	f
93	94	GHILP890123	RKY005us01	1	2022-10-25	25.00000	f
94	95	IJKCC901234	RKY005us01	1	2022-10-25	25.00000	f
95	96	IJKCC901234	MST007us01	1	2022-10-25	25.00000	f
96	97	IJKCC901234	DVL006fr01	1	2022-10-25	25.00000	f
97	98	KLMJJ012345	DVL006fr01	1	2022-10-25	25.00000	f
98	99	MNOHH123455	MST007us01	1	2022-10-25	25.00000	f
99	100	PQREA235567	MST007us01	1	2022-10-25	25.00000	f
100	101	PQREA235567	HRD009us01	1	2022-10-25	25.00000	f
101	102	PQREA235567	MDS010us01	1	2022-11-09	25.00000	f
102	110	EFGQQ890123	ROJ015fr01	1	2023-06-10	25.00000	f
103	111	UUUUU678901	AZL014fr01	1	2023-06-10	25.00000	f
104	112	GHIQW901234	LDS013us01	1	2023-06-10	25.00000	f
\.


--
-- TOC entry 3433 (class 0 OID 28139)
-- Dependencies: 214
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (id_cliente, nombres, apellido_paterno, apellido_materno, direccion, email, telefono, edad) FROM stdin;
ABCDE123456	Juan	García	Pérez	Calle 123 No. 1, Ciudad de Mexico	juan.rsd@example.com	5551234567	23
FGHIJ789012	María	López	Rodríguez	Avenida 456 No. 232, Ciudad de Mexico	mariiia@example.com	\N	50
KLMNO234567	Carlos	Hernández	Gómez	Calle 789 No. 35, Ciudad de Mexico	\N	5559876543	18
PQRST890123	Ana	Martínez	Sánchez	Avenida 321 No. 18, Ciudad de Mexico	anaisa@example.com	\N	40
UVWXY345678	Luis	González	Torres	Calle 987 No. 657, Ciudad de Mexico	\N	5557890123	65
ZACDE901234	Laura	Pérez	Hernández	Avenida 654 S/N, Ciudad de Mexico	laurita.3@example.com	\N	19
FGHIJ567890	Pedro	Gómez	Ramírez	Calle 321 No. 2, Ciudad de Mexico	pedroelgrande@example.com	5559012345	25
KLMNO012345	Sofía	Torres	González	Avenida 789 No. 24, Ciudad de Mexico	princesitasofia@example.com	\N	21
PQRST678901	Miguel	Ramírez	López	Calle 567 No. 42, Ciudad de Mexico	\N	5550123456	20
UVWXY123456	Isabella	Gutiérrez	Fernández	Avenida 890 No. 1, Ciudad de Mexico	isabel.ras@example.com	\N	21
ZBCDE789012	Javier	Fernández	Gutiérrez	Calle 678 No. 3, Ciudad de Mexico	javierrtzo@example.com	5552345678	29
FGHIJ234567	Carolina	Sánchez	Martínez	Avenida 901 No. 16, Ciudad de Mexico	car.olina@example.com	\N	32
KLMNO789012	Diego	Gómez	González	Calle 789 No. 665, Ciudad de Mexico	\N	5553456789	19
PQRST345678	Valentina	Torres	Ramírez	Avenida 012 No. 122, Ciudad de Mexico	salsa.valentina@example.com	\N	24
UVWXY890123	Alejandro	Ramírez	Gómez	Calle 345 No. 54, Ciudad de Mexico	alejandro_ram@example.com	5556789012	24
ZABDE456789	Camila	González	López	Avenida 678 No. 15, Ciudad de Mexico	\N	5554567890	40
PQRCI890123	Gabriel	López	Fernández	Calle 901 No. 90, Ciudad de Mexico	gabrrriel@example.com	\N	18
STUST901234	Valeria	Fernández	López	Avenida 234 No. 7, Ciudad de Mexico	valeriana_ar@example.com	5558901234	21
VWXJF012345	Daniel	López	Hernández	Calle 567 No. 3, Ciudad de Mexico	\N	5556789012	35
YZADX123456	Fernanda	Hernández	Ramírez	Avenida 890 S/N, Ciudad de Mexico	fernandina@example.com	\N	46
BCDTA234567	Sebastián	Ramírez	Torres	Calle 123 No. 5, Ciudad de Mexico	sebastian@example.com	5553456789	20
CDEAB345678	Valentina	Torres	Gómez	Avenida 456 No. 78, Ciudad de Mexico	\N	5552345678	19
EFGBC456789	Andrés	Gómez	Martínez	Calle 789 No. 7, Ciudad de Mexico	andresaurio@example.com	\N	36
GHIII567890	Sara	Martínez	López	Avenida 012 S/N, Ciudad de Mexico	\N	5555678901	36
IJKLK678901	Juan	López	González	Calle 345 No. 20, Ciudad de Mexico	juan.gon@example.com	\N	41
KLMHH789012	Ana	González	Ramírez	Avenida 678 No. 21, Ciudad de Mexico	ana@example.com	5554567890	50
MNOYY890123	Diego	Ramírez	López	Calle 901, Ciudad de Mexico	\N	5557890123	33
PQRTG901234	Mariana	López	Gómez	Avenida 234 No. 65, Ciudad de Mexico	marianiss@example.com	\N	26
STULI012345	Pedro	Gómez	Hernández	Calle 567 No. 6, Ciudad de Mexico	\N	5550123456	24
VWXNN234456	Carla	Hernández	Gómez	Avenida 890 No. 8, Ciudad de Mexico	carlangas@example.com	5558901234	20
YZAZA234567	Roberto	Fernández	López	Calle 123 No. 74, Ciudad de Mexico	roberto.fer@example.com	\N	50
BCDOI345678	María	López	Hernández	Avenida 456 S/N, Ciudad de Mexico	maria_her4@example.com	5551234567	40
CDECC456789	Luis	González	Ramírez	Calle 789 No. 12, Ciudad de Mexico	\N	5559876543	31
EFGER567890	Ana	Martínez	Sánchez	Avenida 012 No. 11, Ciudad de Mexico	ana.231@example.com	\N	23
GHIVV678901	Carlos	Hernández	Gómez	Calle 345 No. 9, Ciudad de Mexico	\N	5557890123	25
IJKRS789012	Laura	Pérez	Hernández	Avenida 678 No. 60, Ciudad de Mexico	lauren@example.com	\N	30
KLMJD890123	Pedro	Gómez	Ramírez	Calle 901 No. 12, Ciudad de Mexico	pedro.conf@example.com	5559012345	42
MNOGG012341	Sofía	Torres	González	Avenida 234 S/N, Ciudad de Mexico	sofia@example.com	\N	22
PQRSS012345	Miguel	Ramírez	López	Calle 567 No. 3, Ciudad de Mexico	\N	5550123456	40
STUHI123456	Isabella	Gutiérrez	Fernández	Avenida 890 No. 40, Ciudad de Mexico	isabella321@example.com	\N	27
VWXXC234567	Javier	Fernández	Gutiérrez	Calle 123 No. 42, Ciudad de Mexico	javierfernandez@example.com	5552345678	55
YZAVV345678	Carolina	Sánchez	Martínez	Avenida 456 No. 12, Ciudad de Mexico	carolinamex@example.com	\N	21
BCDBC456709	Diego	Gómez	González	Calle 789 No. 42 No. 11, Ciudad de Mexico	\N	5553456789	65
CDEZX567890	Valentina	Torres	Ramírez	Avenida 012 S/N, Ciudad de Mexico	valentiinaa.12@example.com	\N	33
EFGOI678901	Alejandro	Ramírez	Gómez	Calle 345 No. 564, Ciudad de Mexico	alejandro@example.com	5556789012	20
GHIMM789012	Camila	González	López	Avenida 678 No. 67, Ciudad de Mexico	\N	5554567890	43
IJKIK890123	Gabriel	López	Fernández	Calle 901 No. 9, Ciudad de Mexico	gabrieeel@example.com	\N	22
KLMHH901234	Valeria	Fernández	López	Avenida 234 No. 1, Ciudad de Mexico	valeria.lop.es@example.com	5558901234	50
MNOMN012335	Daniel	López	Hernández	Calle 567 No. 11, Ciudad de Mexico	\N	5556789012	44
PQRTI223456	Fernanda	Hernández	Ramírez	Avenida 890 No. 60, Ciudad de Mexico	fernandaaa.32@example.com	\N	19
STUVX256456	Sebastián	Ramírez	Torres	Calle 123 No. 5, Ciudad de Mexico	el.sebastian@example.com	5553456789	19
VWXWW345778	Valentina	Torres	Gómez	Avenida 456 S/N, Ciudad de Mexico	\N	5552345678	22
AZAAA456789	Andrés	Gómez	Martínez	Calle 789 No. 66, Ciudad de Mexico	andre.s@example.com	\N	23
BCDBB567890	Sara	Martínez	López	Avenida 012 No. 12, Ciudad de Mexico	\N	5555678901	28
CDEMM678901	Juan	López	González	Calle 345 No. 15, Ciudad de Mexico	juaninjuan@example.com	\N	31
EFGEE789012	Ana	González	Ramírez	Avenida 678 No. 11, Ciudad de Mexico	anaisaaaan@example.com	5554567890	36
GHILP890123	Diego	Ramírez	López	Calle 901 No. 5, Ciudad de Mexico	\N	5557890123	50
IJKCC901234	Mariana	López	Gómez	Avenida 234 No. 76, Ciudad de Mexico	marian_asp@example.com	\N	35
KLMJJ012345	Pedro	Gómez	Hernández	Calle 567 No. 32, Ciudad de Mexico	\N	5550123456	22
MNOHH123455	Sofía	Torres	González	Avenida 890 No. 44, Ciudad de Mexico	sofia.torres@example.com	\N	32
PQREA235567	Luisa	Gómez	Ramírez	Calle 123 No. 124, Ciudad de Mexico	luisa.gr@example.com	5552345678	19
STUNN335678	Felipe	Ramírez	Gómez	Avenida 456 No. 4, Ciudad de Mexico	\N	5559876543	50
VWXPP456799	Laura	López	Martínez	Calle 789 No. 2, Ciudad de Mexico	lauriska@example.com	\N	34
YZAUU567890	Gabriel	Martínez	González	Avenida 012 S/N, Ciudad de Mexico	\N	5557890123	20
UUUUU678901	Valentina	González	Ramírez	Calle 345 No. 11, Ciudad de Mexico	valentinafg@example.com	\N	20
CEEEE789012	Carlos	Ramírez	López	Avenida 678 No. 77, Ciudad de Mexico	carlogo@example.com	5556789012	21
EFGQQ890123	Sara	López	Hernández	Calle 901 No. 5, Ciudad de Mexico	\N	5559012345	45
GHIQW901234	Diego	Hernández	Gómez	Avenida 234 S/N, Ciudad de Mexico	diegoherl@example.com	\N	31
CCCCC612345	Mariana	Gómez	López	Calle 567 No. 56, Ciudad de Mexico	\N	5550123456	32
KLMKA123456	Pedro	López	González	Avenida 890 No. 89, Ciudad de Mexico	pedroink@example.com	\N	31
MNOOO334567	Sofía	González	Ramírez	Calle 123 No. 12, Ciudad de Mexico	sofia_sof@example.com	5553456789	19
PQRDS555555	Daniel	Ramírez	Gómez	Avenida 456 No. 7, Ciudad de Mexico	\N	5552345678	34
RRREE956789	Valeria	Gómez	López	Calle 789 No. 78, Ciudad de Mexico	valeria.gomlo@example.com	\N	24
VWXXX567890	Andrés	López	González	Avenida 012 No. 34, Ciudad de Mexico	\N	5559876543	41
YZAAA678901	Sara	González	Ramírez	Calle 345 No. 70, Ciudad de Mexico	saratoga@example.com	\N	66
BCDAP789012	Juan	Ramírez	López	Avenida 678 No. 7, Ciudad de Mexico	juanga@example.com	5557890123	31
CCCCQ901235	Mariana	López	González	Calle 901 No. 9, Ciudad de Mexico	\N	5559012345	29
EFGAQ901274	Felipe	González	Ramírez	Avenida 234 No. 8, Ciudad de Mexico	felipexer@example.com	\N	31
GIIII111345	Valentina	Ramírez	López	Calle 567 No. 56, Ciudad de Mexico	\N	5550123456	56
BBBAA125456	Gabriel	López	González	Avenida 890 No. 11, Ciudad de Mexico	gabrielles@example.com	\N	18
KLMMJ239567	Laura	González	Ramírez	Calle 123 No. 8, Ciudad de Mexico	laura@example.com	5553456789	24
MNOOO345688	Diego	Ramírez	López	Avenida 456 No. 97, Ciudad de Mexico	\N	5552345678	51
PPPXX777789	Sara	López	González	Calle 789 No. 6, Ciudad de Mexico	saraiscus@example.com	\N	44
FFRRE667890	Felipe	González	Ramírez	Avenida 012 S/N, Ciudad de Mexico	\N	5559876543	19
VWXIO670001	Laura	Ramírez	López	Calle 345 No. 34, Ciudad de Mexico	gato.perro@example.com	\N	78
YZVVV789912	Diego	López	González	Avenida 678 No. 43, Ciudad de Mexico	diegolpe@example.com	5556789012	34
BBBBB890123	Valentina	González	Ramírez	Calle 901 No. 4, Ciudad de Mexico	\N	5559012345	50
OOOOO909934	Andrés	Ramírez	López	Avenida 234 No. 67, Ciudad de Mexico	andresiniesta@example.com	\N	33
EFGGG012345	Sara	López	González	Calle 567 No. 56, Ciudad de Mexico	salogo@example.com	5550123456	41
CCZAS111456	Juan	González	Ramírez	Avenida 890 No. 80, Ciudad de Mexico	\N	5551234567	32
IJKKK235567	Mariana	Ramírez	López	Calle 123 No. 6, Ciudad de Mexico	marianisame@example.com	\N	22
ATMPR345698	Felipe	López	González	Avenida 456 S/N, Ciudad de Mexico	\N	5552345678	31
MWMWM898989	Valeria	Gómez	Ramírez	Calle 789 No. 67, Ciudad de Mexico	basesdedatos@example.com	\N	53
PQWWQ567890	Andrés	Ramírez	Gómez	Avenida 012 No. 65, Ciudad de Mexico	\N	5557890123	67
IOIOI789011	Sara	Gómez	López	Calle 345 No. 14, Ciudad de Mexico	elprofe@example.com	\N	18
SSTTS789012	Diego	López	Martínez	Avenida 678 No. 654, Ciudad de Mexico	\N	5559012345	25
YZYZZ890123	Mariana	Martínez	Gómez	Calle 901 No. 666, Ciudad de Mexico	orcolak@example.com	\N	28
BBBRR901234	Juan	Gómez	Ramírez	Avenida 234 S/N, Ciudad de Mexico	\N	5550123456	37
CHHOO012345	Laura	Ramírez	López	Calle 567 No. 15, Ciudad de Mexico	laurianka@example.com	5551234567	19
EFGEE123444	Felipe	López	Gómez	Avenida 890 No. 78, Ciudad de Mexico	\N	5552345678	18
\.


--
-- TOC entry 3435 (class 0 OID 28161)
-- Dependencies: 216
-- Data for Name: copias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.copias (no_copia, id_pelicula, estado) FROM stdin;
1	ABC123ab01	bien
2	ABC123ab01	bien
3	ABC123ab01	bien
4	ABC123ab01	bien
1	XYZ987xy02	bien
2	XYZ987xy02	bien
1	DEF456de03	bien
1	MNO654mn04	bien
1	JKL321jk06	bien
1	PQR987pq07	bien
1	STU654st08	bien
2	STU654st08	bien
3	STU654st08	bien
1	VWX321vw09	bien
1	YZA789yz10	bien
1	BCD123bc11	bien
2	BCD123bc11	bien
1	EFG456ef12	bien
1	KLM321kl14	bien
1	NOP654no15	bien
1	QRS987qr16	bien
1	TUV321tu17	bien
1	YZA123yz19	bien
1	BCD456bc20	bien
1	EFG789ef21	bien
1	HIJ321hi22	bien
1	KLM654kl23	bien
1	NOP987no24	bien
1	QRS321qr25	bien
1	TUV654tu26	bien
1	WXY987wx27	bien
1	YZA321yz28	bien
1	BCD654bc29	bien
1	ABC123ab31	bien
1	DEF456de32	bien
1	GHI789gh33	bien
1	JKL321jk34	bien
1	MNO654mn35	bien
1	PQR987pq36	bien
1	STU321st37	bien
1	VWX654vw38	bien
1	YZA987yz39	bien
1	BCD321bc40	bien
1	HIJ987hi42	bien
1	KLM321kl43	bien
1	QRS987qr45	bien
1	WXY654wx47	bien
1	DEF456eu62	bien
1	GHI789eu63	bien
1	MNO345eu65	bien
1	PQR678eu66	bien
1	STU901eu67	bien
1	YZA567eu69	bien
1	BCD890eu70	bien
1	EFG123eu71	bien
1	NOP012eu74	bien
2	QRS345eu75	bien
1	TUV678eu76	bien
1	ZAB234eu78	bien
1	EFG890eu80	bien
1	ZAB901eu87	bien
1	ALV001us01	bien
1	TRM002us01	bien
1	DPD004us01	bien
1	RKY005us01	bien
1	DVL006fr01	bien
1	MST007us01	bien
1	PRS008ko01	bien
1	HRD009us01	bien
1	MDS010us01	bien
1	CRS011us01	bien
1	PFB012jp01	bien
1	LDS013us01	bien
1	AZL014fr01	bien
1	ROJ015fr01	bien
1	DMH016fr01	bien
2	PNY017jp01	bien
1	VJC018jp01	bien
1	SCM019us01	bien
1	HLW020us01	bien
1	JBD021us01	bien
1	PRL022fr01	bien
1	DPD023us02	bien
1	PSD024us01	bien
1	EMJ025us01	bien
1	LPC026us01	bien
1	RKY027us01	bien
1	RMB028us01	bien
1	RMB029us01	bien
1	RYF030us01	bien
1	PSC031us01	bien
1	APC032us01	bien
1	PTR033us01	bien
1	NNV034us01	bien
1	HST035us01	bien
1	AMR036us01	bien
2	TDB037fr01	bien
1	FNG038at01	bien
1	ALN039us01	bien
1	BNH040us01	bien
1	GDC041de01	bien
1	SLG042us01	bien
1	NMD043us01	bien
1	EVD044us01	bien
1	JMN045us01	bien
1	PCH046us01	bien
1	DAD047uk01	bien
1	CNR048us01	bien
1	AWD049us01	bien
1	MKB050us01	bien
1	ALD051us01	bien
1	HMH052us01	bien
1	RDR053us01	bien
1	DLR054us01	bien
1	SSR055it01	bien
1	MNT056us01	bien
2	AMR036us01	bien
3	TDB037fr01	bien
2	FNG038at01	bien
2	ALN039us01	bien
2	BNH040us01	bien
2	GDC041de01	bien
2	SLG042us01	bien
2	NMD043us01	bien
2	EVD044us01	bien
2	JMN045us01	bien
2	PCH046us01	bien
2	DAD047uk01	bien
2	CNR048us01	bien
2	AWD049us01	bien
2	MKB050us01	bien
2	ALD051us01	bien
2	HMH052us01	bien
2	RDR053us01	bien
2	DLR054us01	bien
2	SSR055it01	bien
4	PSC031us01	dañada
4	APC032us01	dañada
4	PTR033us01	dañada
4	NNV034us01	dañada
4	HST035us01	dañada
4	AMR036us01	dañada
4	TDB037fr01	dañada
4	FNG038at01	dañada
4	ALN039us01	dañada
4	BNH040us01	dañada
4	GDC041de01	dañada
4	SLG042us01	dañada
4	NMD043us01	dañada
4	EVD044us01	dañada
4	JMN045us01	dañada
4	PCH046us01	dañada
4	DAD047uk01	dañada
4	CNR048us01	dañada
4	AWD049us01	dañada
4	MKB050us01	dañada
\.


--
-- TOC entry 3442 (class 0 OID 28245)
-- Dependencies: 223
-- Data for Name: pagos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pagos (no_pago, no_prestamo, id_cliente, id_pelicula, no_copia, fecha_pago, monto, concepto) FROM stdin;
1	1	ABCDE123456	ABC123ab01	1	2022-06-09	25.00000	adeudo
2	2	ABCDE123456	XYZ987xy02	1	2022-06-09	25.00000	adeudo
3	3	ABCDE123456	DEF456de03	1	2022-06-09	25.00000	adeudo
4	4	FGHIJ789012	MNO654mn04	1	2022-06-09	25.00000	adeudo
5	5	FGHIJ789012	JKL321jk06	1	2022-06-09	25.00000	adeudo
6	6	FGHIJ789012	PQR987pq07	1	2022-06-09	25.00000	adeudo
7	7	KLMNO234567	MNO654mn04	1	2022-06-09	25.00000	adeudo
8	8	KLMNO234567	STU654st08	1	2022-06-09	25.00000	adeudo
9	9	KLMNO234567	ABC123ab01	1	2022-06-09	25.00000	adeudo
10	10	KLMNO234567	XYZ987xy02	1	2022-06-09	25.00000	adeudo
11	11	KLMNO234567	DEF456de03	1	2022-06-09	25.00000	adeudo
12	12	PQRST890123	DEF456de03	1	2022-07-21	25.00000	adeudo
13	13	PQRST890123	MNO654mn04	1	2022-07-21	25.00000	adeudo
14	14	UVWXY345678	JKL321jk06	1	2022-07-21	25.00000	adeudo
15	15	UVWXY345678	PQR987pq07	1	2022-07-21	25.00000	adeudo
16	16	UVWXY345678	STU654st08	1	2022-07-21	25.00000	adeudo
17	17	ZACDE901234	VWX321vw09	1	2022-07-21	25.00000	adeudo
18	18	ZACDE901234	YZA789yz10	1	2022-07-21	25.00000	adeudo
19	19	FGHIJ567890	VWX321vw09	1	2022-07-21	25.00000	adeudo
20	20	KLMNO012345	YZA789yz10	1	2022-07-21	25.00000	adeudo
21	21	KLMNO012345	BCD123bc11	1	2022-07-21	25.00000	adeudo
22	22	KLMNO012345	EFG456ef12	1	2022-07-29	25.00000	adeudo
23	23	KLMNO012345	KLM321kl14	1	2022-07-29	25.00000	adeudo
24	24	KLMNO012345	NOP654no15	1	2022-07-29	25.00000	adeudo
25	25	PQRST678901	QRS987qr16	1	2022-07-29	25.00000	adeudo
26	26	PQRST678901	TUV321tu17	1	2022-07-29	25.00000	adeudo
27	27	UVWXY123456	YZA123yz19	1	2022-07-29	25.00000	adeudo
28	28	ZBCDE789012	BCD456bc20	1	2022-07-29	25.00000	adeudo
29	29	FGHIJ234567	EFG789ef21	1	2022-07-29	25.00000	adeudo
30	30	KLMNO789012	HIJ321hi22	1	2022-07-29	25.00000	adeudo
31	31	PQRST345678	HIJ321hi22	1	2022-07-29	25.00000	adeudo
32	32	UVWXY890123	HIJ321hi22	1	2022-08-09	25.00000	adeudo
33	33	ZABDE456789	HIJ321hi22	1	2022-08-09	25.00000	adeudo
34	34	ZABDE456789	KLM654kl23	1	2022-08-09	25.00000	adeudo
35	35	ZABDE456789	NOP987no24	1	2022-08-09	25.00000	adeudo
36	36	ZABDE456789	QRS321qr25	1	2022-08-09	25.00000	adeudo
37	37	ZABDE456789	TUV654tu26	1	2022-08-09	25.00000	adeudo
38	38	ZABDE456789	WXY987wx27	1	2022-08-09	25.00000	adeudo
39	39	ZABDE456789	YZA321yz28	1	2022-08-09	25.00000	adeudo
40	40	PQRCI890123	BCD654bc29	1	2022-08-09	25.00000	adeudo
41	41	PQRCI890123	ABC123ab31	1	2022-08-09	25.00000	adeudo
42	42	PQRCI890123	DEF456de32	1	2022-08-18	25.00000	adeudo
43	43	STUST901234	DEF456de32	1	2022-08-18	25.00000	adeudo
44	44	STUST901234	ABC123ab31	1	2022-08-18	25.00000	adeudo
45	45	VWXJF012345	ABC123ab31	1	2022-08-18	25.00000	adeudo
46	46	YZADX123456	GHI789gh33	1	2022-08-18	25.00000	adeudo
47	47	BCDTA234567	GHI789gh33	1	2022-08-18	25.00000	adeudo
48	48	CDEAB345678	JKL321jk34	1	2022-08-18	25.00000	adeudo
49	49	EFGBC456789	JKL321jk34	1	2022-08-18	25.00000	adeudo
50	50	GHIII567890	JKL321jk34	1	2022-08-18	25.00000	adeudo
51	51	GHIII567890	MNO654mn35	1	2022-08-18	25.00000	adeudo
52	52	GHIII567890	PQR987pq36	1	2022-09-09	25.00000	adeudo
53	53	IJKLK678901	PQR987pq36	1	2022-09-09	25.00000	adeudo
54	54	KLMHH789012	VWX654vw38	1	2022-09-09	25.00000	adeudo
55	55	KLMHH789012	STU321st37	1	2022-09-09	25.00000	adeudo
56	56	KLMHH789012	YZA987yz39	1	2022-09-09	25.00000	adeudo
57	57	KLMHH789012	BCD321bc40	1	2022-09-09	25.00000	adeudo
58	58	KLMHH789012	HIJ987hi42	1	2022-09-09	25.00000	adeudo
59	59	MNOYY890123	HIJ987hi42	1	2022-09-09	25.00000	adeudo
60	60	MNOYY890123	KLM321kl43	1	2022-09-09	25.00000	adeudo
61	61	PQRTG901234	KLM321kl43	1	2022-09-09	25.00000	adeudo
62	63	VWXNN234456	QRS987qr45	1	2022-09-23	25.00000	adeudo
63	64	YZAZA234567	QRS987qr45	1	2022-09-23	25.00000	adeudo
64	65	BCDOI345678	QRS987qr45	1	2022-09-23	25.00000	adeudo
65	66	CDECC456789	WXY654wx47	1	2022-09-23	25.00000	adeudo
66	67	EFGER567890	WXY654wx47	1	2022-09-23	25.00000	adeudo
67	68	GHIVV678901	DEF456eu62	1	2022-09-23	25.00000	adeudo
68	69	IJKRS789012	GHI789eu63	1	2022-09-23	25.00000	adeudo
69	70	KLMJD890123	MNO345eu65	1	2022-09-23	25.00000	adeudo
70	71	STULI012345	MNO345eu65	1	2022-09-23	25.00000	adeudo
71	72	PQRSS012345	MNO345eu65	1	2022-09-23	25.00000	adeudo
72	73	STUHI123456	PQR678eu66	1	2022-10-10	25.00000	adeudo
73	74	VWXXC234567	PQR678eu66	1	2022-10-10	25.00000	adeudo
74	75	YZAVV345678	STU901eu67	1	2022-10-10	25.00000	adeudo
75	76	BCDBC456709	YZA567eu69	1	2022-10-10	25.00000	adeudo
76	77	CDEZX567890	EFG123eu71	1	2022-10-10	25.00000	adeudo
77	78	EFGOI678901	BCD890eu70	1	2022-10-10	25.00000	adeudo
78	79	GHIMM789012	NOP012eu74	1	2022-10-10	25.00000	adeudo
79	80	IJKIK890123	QRS345eu75	2	2022-10-10	25.00000	adeudo
80	81	KLMHH901234	TUV678eu76	1	2022-10-10	25.00000	adeudo
81	82	KLMHH901234	ZAB234eu78	1	2022-10-10	25.00000	adeudo
82	83	KLMHH901234	EFG890eu80	1	2022-10-18	25.00000	adeudo
83	84	MNOMN012335	ZAB901eu87	1	2022-10-18	25.00000	adeudo
84	85	MNOMN012335	ALV001us01	1	2022-10-18	25.00000	adeudo
85	86	PQRTI223456	TRM002us01	1	2022-10-18	25.00000	adeudo
86	87	STUVX256456	TRM002us01	1	2022-10-18	25.00000	adeudo
87	88	VWXWW345778	TRM002us01	1	2022-10-18	25.00000	adeudo
88	89	AZAAA456789	TRM002us01	1	2022-10-18	25.00000	adeudo
89	90	BCDBB567890	TRM002us01	1	2022-10-18	25.00000	adeudo
90	91	BCDBB567890	DPD004us01	1	2022-10-18	25.00000	adeudo
91	92	CDEMM678901	RKY005us01	1	2022-10-18	25.00000	adeudo
92	93	EFGEE789012	RKY005us01	1	2022-10-25	25.00000	adeudo
93	94	GHILP890123	RKY005us01	1	2022-10-25	25.00000	adeudo
94	95	IJKCC901234	RKY005us01	1	2022-10-25	25.00000	adeudo
95	96	IJKCC901234	MST007us01	1	2022-10-25	25.00000	adeudo
96	97	IJKCC901234	DVL006fr01	1	2022-10-25	25.00000	adeudo
97	98	KLMJJ012345	DVL006fr01	1	2022-10-25	25.00000	adeudo
98	99	MNOHH123455	MST007us01	1	2022-10-25	25.00000	adeudo
99	100	PQREA235567	MST007us01	1	2022-10-25	25.00000	adeudo
100	101	PQREA235567	HRD009us01	1	2022-10-25	25.00000	adeudo
101	102	PQREA235567	MDS010us01	1	2022-11-09	25.00000	adeudo
\.


--
-- TOC entry 3434 (class 0 OID 28152)
-- Dependencies: 215
-- Data for Name: peliculas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.peliculas (id_pelicula, titulo, "año_lanzamiento", director, idioma, duracion, genero) FROM stdin;
ABC123ab01	Titanic	1997	James Cameron	 Latino	03:14:00	Drama
XYZ987xy02	El Padrino	1972	Francis Ford Coppola	 Latino	02:55:00	Crimen
DEF456de03	Pulp Fiction	1994	Quentin Tarantino	 Latino	02:34:00	Crimen
MNO654mn04	El Rey León	1994	Rob Minkoff	 Latino	01:29:00	Animación
JKL321jk06	La vida es bella	1997	Roberto Benigni	Italiano	01:56:00	Comedia
PQR987pq07	El Señor de los Anillos: El Retorno del Rey	2003	Peter Jackson	 Latino	03:21:00	Fantasía
STU654st08	Forrest Gump	1994	Robert Zemeckis	 Latino	02:22:00	Drama
VWX321vw09	El Exorcista	1973	William Friedkin	 Latino	02:01:00	Terror
YZA789yz10	Cadena perpetua	1994	Frank Darabont	 Latino	02:22:00	Drama
BCD123bc11	Matrix	1999	Lana Wachowski	 Latino	02:16:00	Ciencia ficción
EFG456ef12	El Club de la Lucha	1999	David Fincher	 Latino	02:19:00	Drama
KLM321kl14	El Resplandor	1980	Stanley Kubrick	 Latino	02:26:00	Terror
NOP654no15	La La Land	2016	Damien Chazelle	 Latino	02:08:00	Musical
QRS987qr16	El Rey León	2019	Jon Favreau	 Latino	01:58:00	Aventura
TUV321tu17	El Gran Lebowski	1998	Joel Coen	 Latino	01:57:00	Comedia
YZA123yz19	El Sexto Sentido	1999	M. Night Shyamalan	 Latino	01:47:00	Suspenso
BCD456bc20	El Padrino II	1974	Francis Ford Coppola	 Latino	03:22:00	Crimen
EFG789ef21	El Resplandor	1997	Mick Garris	 Latino	04:27:00	Terror
HIJ321hi22	Blade Runner	1982	Ridley Scott	 Latino	01:57:00	Ciencia ficción
KLM654kl23	Interestelar	2014	Christopher Nolan	 Latino	02:49:00	Ciencia ficción
NOP987no24	El Señor de los Anillos: La Comunidad del Anillo	2001	Peter Jackson	 Latino	02:58:00	Fantasía
QRS321qr25	La Naranja Mecánica	1971	Stanley Kubrick	 Latino	02:16:00	Ciencia ficción
TUV654tu26	La Forma del Agua	2017	Guillermo del Toro	 Latino	02:03:00	Fantasía
WXY987wx27	Toy Story	1995	John Lasseter	 Latino	01:21:00	Animación
YZA321yz28	El Gran Dictador	1940	Charles Chaplin	 Latino	02:05:00	Comedia
BCD654bc29	El Rey León II	1994	Roger Allers	 Latino	01:29:00	Animación
ABC123ab31	El secreto de sus ojos	2009	Juan José Campanella	Castellano	02:09:00	Drama
DEF456de32	Relatos salvajes	2014	Damián Szifrón	Castellano	01:55:00	Comedia negra
GHI789gh33	Amores perros	2000	Alejandro González Iñárritu	Castellano	02:34:00	Drama
JKL321jk34	El laberinto del fauno	2006	Guillermo del Toro	Castellano	01:58:00	Fantasía
MNO654mn35	Diarios de motocicleta	2004	Walter Salles	Castellano	02:06:00	Drama
PQR987pq36	El secreto de la montaña	2005	Ang Lee	Castellano	02:14:00	Drama
STU321st37	El club	2015	Pablo Larraín	Castellano	01:37:00	Drama
VWX654vw38	Cidade de Deus	2002	Fernando Meirelles	Portugués	02:10:00	Drama
YZA987yz39	Y tu mamá también	2001	Alfonso Cuarón	Castellano	01:46:00	Drama
BCD321bc40	El secreto de la última luna	2008	Gracia Querejeta	Castellano	01:45:00	Drama
HIJ987hi42	Nueve reinas	2000	Fabián Bielinsky	Castellano	01:54:00	Crimen
KLM321kl43	Mar adentro	2004	Alejandro Amenábar	Castellano	02:05:00	Drama
QRS987qr45	El hijo de la novia	2001	Juan José Campanella	Castellano	02:04:00	Comedia
WXY654wx47	Hable con ella	2002	Pedro Almodóvar	Castellano	01:52:00	Drama
DEF456eu62	Amélie	2001	Jean-Pierre Jeunet	Castellano	02:02:00	Comedia
GHI789eu63	El Gran Hotel Budapest	2014	Wes Anderson	Castellano	01:39:00	Comedia
MNO345eu65	Cinema Paradiso	1988	Giuseppe Tornatore	Castellano	02:35:00	Drama
PQR678eu66	Volver	2006	Pedro Almodóvar	Castellano	02:01:00	Drama
STU901eu67	El Orfanato	2007	J.A. Bayona	Castellano	01:45:00	Terror
YZA567eu69	La comunidad	2000	Álex de la Iglesia	Castellano	01:51:00	Comedia
BCD890eu70	El secreto de la isla de las focas	1981	Ricardo Blasco	Castellano	01:27:00	Aventura
EFG123eu71	Los otros	2001	Alejandro Amenábar	Castellano	01:45:00	Suspenso
NOP012eu74	El discurso del rey	2010	Tom Hooper	Castellano	01:58:00	Drama
QRS345eu75	El nombre de la rosa	1986	Jean-Jacques Annaud	Castellano	02:10:00	Misterio
TUV678eu76	Todo sobre mi madre	1999	Pedro Almodóvar	Castellano	01:41:00	Drama
ZAB234eu78	Carne trémula	1997	Pedro Almodóvar	Castellano	01:39:00	Drama
EFG890eu80	Vicky Cristina Barcelona	2008	Woody Allen	Latino	01:36:00	Comedia
ZAB901eu87	Biutiful	2010	Alejandro González Iñárritu	Latino	02:28:00	Drama
ALV001us01	Alien vs. Depredador	2004	Paul W. S. Anderson	Latino	01:41:00	Acción
TRM002us01	Terminator	1984	James Cameron	Latino	01:48:00	Acción
TRM003us02	Terminator 2: El día del juicio	1991	James Cameron	Latino	02:17:00	Acción
DPD004us01	Depredador	1987	John McTiernan	Latino	01:47:00	Acción
RKY005us01	Rocky	1976	John G. Avildsen	Latino	02:00:00	Drama
DVL006fr01	La double vie de Véronique	1991	Krzysztof Kieślowski	Francés	01:37:00	Drama
MST007us01	La masacre de Texas	1974	Tobe Hooper	Latino	01:23:00	Terror
PRS008ko01	Parásitos	2019	Bong Joon-ho	Coreano	02:12:00	Drama
HRD009us01	Hereditary	2018	Ari Aster	Latino	02:07:00	Terror
MDS010us01	Midsommar	2019	Ari Aster	Latino	02:27:00	Drama
CRS011us01	Crash	2004	Paul Haggis	Latino	01:52:00	Drama
PFB012jp01	Perfect Blue	1997	Satoshi Kon	Japonés	01:20:00	Animación
LDS013us01	La lista de Schindler	1993	Steven Spielberg	Latino	03:15:00	Drama
AZL014fr01	Trois couleurs: Bleu	1993	Krzysztof Kieślowski	Francés	01:38:00	Drama
ROJ015fr01	Trois couleurs: Rouge	1994	Krzysztof Kieślowski	Francés	01:39:00	Drama
DMH016fr01	La dama de honor	2004	Claude Chabrol	Francés	01:50:00	Drama
PNY017jp01	Ponyo	2008	Hayao Miyazaki	Japonés	01:41:00	Animación
VJC018jp01	El viaje de Chihiro	2001	Hayao Miyazaki	Japonés	02:05:00	Animación
SCM019us01	Scream	1996	Wes Craven	Latino	01:51:00	Terror
HLW020us01	Halloween	1978	John Carpenter	Latino	01:31:00	Terror
JBD021us01	El jorobado de Notre Dame	1996	Gary Trousdale, Kirk Wise	Latino	01:31:00	Animación
PRL022fr01	Pierrot le Fou	1965	Jean-Luc Godard	Francés	01:55:00	Drama
DPD023us02	Depredador 2	1990	Stephen Hopkins	Latino	01:48:00	Acción
PSD024us01	Pesadilla en la calle Elmt	1984	Wes Craven	Latino	01:31:00	Terror
EMJ025us01	El extraño mundo de Jack	1993	Henry Selick	Latino	01:16:00	Animación
LPC026us01	Los Picapiedra	1994	Brian Levant	Latino	01:31:00	Comedia
RKY027us01	Rocky IV	1985	Sylvester Stallone	Latino	01:31:00	Drama
RMB028us01	Rambo	2008	Sylvester Stallone	Latino	01:32:00	Acción
RMB029us01	Rambo II	1985	George P. Cosmatos	Latino	01:36:00	Acción
RYF030us01	Rapido y furioso	2001	Rob Cohen	Latino	01:46:00	Acción
PSC031us01	La pasión de cristo	2004	Mel Gibson	Latino	02:07:00	Drama
APC032us01	Apocalypto	2006	Mel Gibson	Maya	02:18:00	Aventura
PTR033us01	El patriota	2000	Roland Emmerich	Latino	02:45:00	Drama
NNV034us01	Negra Navidad	2006	Glen Morgan	Latino	01:34:00	Terror
HST035us01	Hostel	2005	Eli Roth	Latino	01:34:00	Terror
AMR036us01	Amour	2012	Michael Haneke	Francés	02:07:00	Drama
TDB037fr01	El tiempo del lobo	2003	Michael Haneke	Francés	01:51:00	Drama
FNG038at01	Funny Games	1997	Michael Haneke	Alemán	01:48:00	Drama
ALN039us01	Alien	1979	Ridley Scott	Latino	01:57:00	Ciencia ficción
BNH040us01	Ben-Hur	1959	William Wyler	Latino	03:32:00	Drama
GDC041de01	El gabinete del Dr. Caligari	1920	Robert Wiene	Alemán	01:18:00	Expresionismo alemán
SLG042us01	Soy leyenda	2007	Francis Lawrence	Latino	01:40:00	Ciencia ficción
NMD043us01	La noche de los muertos vivientes	1968	George A. Romero	Latino	01:36:00	Terror
EVD044us01	Evil Dead	1981	Sam Raimi	Latino	01:25:00	Terror
JMN045us01	Jumanji	1995	Joe Johnston	Latino	01:44:00	Aventura
PCH046us01	Pocahontas	1995	Mike Gabriel, Eric Goldberg	Latino	01:21:00	Animación
DAD047uk01	28 días después	2002	Danny Boyle	Latino	01:53:00	Terror
CNR048us01	Con Air	1997	Simon West	Latino	01:55:00	Acción
AWD049us01	Aullido	1981	Joe Dante	Latino	01:31:00	Terror
MKB050us01	Mortal Kombat	1995	Paul W.S. Anderson	Latino	01:41:00	Acción
ALD051us01	Aliens vs. Predator: Requiem	2007	Colin Strause, Greg Strause	Latino	01:34:00	Ciencia ficción
HMH052us01	Hombres de honor	2000	George Tillman Jr.	Latino	02:09:00	Drama
RDR053us01	Rescatando al soldado Ryan	1998	Steven Spielberg	Latino	02:49:00	Drama
DLR054us01	La delgada línea roja	1998	Terrence Malick	Latino	02:50:00	Drama
SSR055it01	Suspiria	1977	Dario Argento	Italiano	01:38:00	Terror
MNT056us01	Memento	2000	Christopher Nolan	Latino	01:53:00	Suspenso
\.


--
-- TOC entry 3438 (class 0 OID 28193)
-- Dependencies: 219
-- Data for Name: prestamos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prestamos (no_prestamo, id_cliente, id_pelicula, no_copia, fecha_prestamo, fecha_devolucion, monto, activo) FROM stdin;
1	ABCDE123456	ABC123ab01	1	2022-06-01	2022-06-08	20.99000	f
2	ABCDE123456	XYZ987xy02	1	2022-06-01	2022-06-08	20.99000	f
3	ABCDE123456	DEF456de03	1	2022-06-01	2022-06-08	20.99000	f
4	FGHIJ789012	MNO654mn04	1	2022-06-01	2022-06-08	20.99000	f
5	FGHIJ789012	JKL321jk06	1	2022-06-01	2022-06-08	20.99000	f
6	FGHIJ789012	PQR987pq07	1	2022-06-01	2022-06-08	20.99000	f
7	KLMNO234567	MNO654mn04	1	2022-06-01	2022-06-08	20.99000	f
8	KLMNO234567	STU654st08	1	2022-06-01	2022-06-08	20.99000	f
9	KLMNO234567	ABC123ab01	1	2022-06-01	2022-06-08	20.99000	f
10	KLMNO234567	XYZ987xy02	1	2022-06-01	2022-06-08	20.99000	f
11	KLMNO234567	DEF456de03	1	2022-06-01	2022-06-08	20.99000	f
12	PQRST890123	DEF456de03	1	2022-07-13	2022-07-20	20.99000	f
13	PQRST890123	MNO654mn04	1	2022-07-13	2022-07-20	20.99000	f
14	UVWXY345678	JKL321jk06	1	2022-07-13	2022-07-20	20.99000	f
15	UVWXY345678	PQR987pq07	1	2022-07-13	2022-07-20	20.99000	f
16	UVWXY345678	STU654st08	1	2022-07-13	2022-07-20	20.99000	f
17	ZACDE901234	VWX321vw09	1	2022-07-13	2022-07-20	20.99000	f
18	ZACDE901234	YZA789yz10	1	2022-07-13	2022-07-20	20.99000	f
19	FGHIJ567890	VWX321vw09	1	2022-07-13	2022-07-20	20.99000	f
20	KLMNO012345	YZA789yz10	1	2022-07-13	2022-07-20	20.99000	f
21	KLMNO012345	BCD123bc11	1	2022-07-13	2022-07-20	20.99000	f
22	KLMNO012345	EFG456ef12	1	2022-07-21	2022-07-28	20.99000	f
23	KLMNO012345	KLM321kl14	1	2022-07-21	2022-07-28	20.99000	f
24	KLMNO012345	NOP654no15	1	2022-07-21	2022-07-28	20.99000	f
25	PQRST678901	QRS987qr16	1	2022-07-21	2022-07-28	20.99000	f
26	PQRST678901	TUV321tu17	1	2022-07-21	2022-07-28	20.99000	f
27	UVWXY123456	YZA123yz19	1	2022-07-21	2022-07-28	20.99000	f
28	ZBCDE789012	BCD456bc20	1	2022-07-21	2022-07-28	20.99000	f
29	FGHIJ234567	EFG789ef21	1	2022-07-21	2022-07-28	20.99000	f
30	KLMNO789012	HIJ321hi22	1	2022-07-21	2022-07-28	20.99000	f
31	PQRST345678	HIJ321hi22	1	2022-07-21	2022-07-28	20.99000	f
32	UVWXY890123	HIJ321hi22	1	2022-08-01	2022-08-08	20.99000	f
33	ZABDE456789	HIJ321hi22	1	2022-08-01	2022-08-08	20.99000	f
34	ZABDE456789	KLM654kl23	1	2022-08-01	2022-08-08	20.99000	f
35	ZABDE456789	NOP987no24	1	2022-08-01	2022-08-08	20.99000	f
36	ZABDE456789	QRS321qr25	1	2022-08-01	2022-08-08	20.99000	f
37	ZABDE456789	TUV654tu26	1	2022-08-01	2022-08-08	20.99000	f
38	ZABDE456789	WXY987wx27	1	2022-08-01	2022-08-08	20.99000	f
39	ZABDE456789	YZA321yz28	1	2022-08-01	2022-08-08	20.99000	f
40	PQRCI890123	BCD654bc29	1	2022-08-01	2022-08-08	20.99000	f
41	PQRCI890123	ABC123ab31	1	2022-08-01	2022-08-08	20.99000	f
42	PQRCI890123	DEF456de32	1	2022-08-10	2022-08-17	20.99000	f
43	STUST901234	DEF456de32	1	2022-08-10	2022-08-17	20.99000	f
44	STUST901234	ABC123ab31	1	2022-08-10	2022-08-17	20.99000	f
45	VWXJF012345	ABC123ab31	1	2022-08-10	2022-08-17	20.99000	f
46	YZADX123456	GHI789gh33	1	2022-08-10	2022-08-17	20.99000	f
47	BCDTA234567	GHI789gh33	1	2022-08-10	2022-08-17	20.99000	f
48	CDEAB345678	JKL321jk34	1	2022-08-10	2022-08-17	20.99000	f
49	EFGBC456789	JKL321jk34	1	2022-08-10	2022-08-17	20.99000	f
50	GHIII567890	JKL321jk34	1	2022-08-10	2022-08-17	20.99000	f
51	GHIII567890	MNO654mn35	1	2022-08-10	2022-08-17	20.99000	f
52	GHIII567890	PQR987pq36	1	2022-09-01	2022-09-08	20.99000	f
53	IJKLK678901	PQR987pq36	1	2022-09-01	2022-09-08	20.99000	f
54	KLMHH789012	VWX654vw38	1	2022-09-01	2022-09-08	20.99000	f
55	KLMHH789012	STU321st37	1	2022-09-01	2022-09-08	20.99000	f
56	KLMHH789012	YZA987yz39	1	2022-09-01	2022-09-08	20.99000	f
57	KLMHH789012	BCD321bc40	1	2022-09-01	2022-09-08	20.99000	f
58	KLMHH789012	HIJ987hi42	1	2022-09-01	2022-09-08	20.99000	f
59	MNOYY890123	HIJ987hi42	1	2022-09-01	2022-09-08	20.99000	f
60	MNOYY890123	KLM321kl43	1	2022-09-01	2022-09-08	20.99000	f
61	PQRTG901234	KLM321kl43	1	2022-09-01	2022-09-08	20.99000	f
62	STULI012345	QRS987qr45	1	2022-09-01	2022-09-08	20.99000	f
63	VWXNN234456	QRS987qr45	1	2022-09-15	2022-09-22	20.99000	f
64	YZAZA234567	QRS987qr45	1	2022-09-15	2022-09-22	20.99000	f
65	BCDOI345678	QRS987qr45	1	2022-09-15	2022-09-22	20.99000	f
66	CDECC456789	WXY654wx47	1	2022-09-15	2022-09-22	20.99000	f
67	EFGER567890	WXY654wx47	1	2022-09-15	2022-09-22	20.99000	f
68	GHIVV678901	DEF456eu62	1	2022-09-15	2022-09-22	20.99000	f
69	IJKRS789012	GHI789eu63	1	2022-09-15	2022-09-22	20.99000	f
70	KLMJD890123	MNO345eu65	1	2022-09-15	2022-09-22	20.99000	f
71	STULI012345	MNO345eu65	1	2022-09-15	2022-09-22	20.99000	f
72	PQRSS012345	MNO345eu65	1	2022-09-15	2022-09-22	20.99000	f
73	STUHI123456	PQR678eu66	1	2022-10-02	2022-10-09	20.99000	f
74	VWXXC234567	PQR678eu66	1	2022-10-02	2022-10-09	20.99000	f
75	YZAVV345678	STU901eu67	1	2022-10-02	2022-10-09	20.99000	f
76	BCDBC456709	YZA567eu69	1	2022-10-02	2022-10-09	20.99000	f
77	CDEZX567890	EFG123eu71	1	2022-10-02	2022-10-09	20.99000	f
78	EFGOI678901	BCD890eu70	1	2022-10-02	2022-10-09	20.99000	f
79	GHIMM789012	NOP012eu74	1	2022-10-02	2022-10-09	20.99000	f
80	IJKIK890123	QRS345eu75	2	2022-10-02	2022-10-09	20.99000	f
81	KLMHH901234	TUV678eu76	1	2022-10-02	2022-10-09	20.99000	f
82	KLMHH901234	ZAB234eu78	1	2022-10-02	2022-10-09	20.99000	f
83	KLMHH901234	EFG890eu80	1	2022-10-10	2022-10-17	20.99000	f
84	MNOMN012335	ZAB901eu87	1	2022-10-10	2022-10-17	20.99000	f
85	MNOMN012335	ALV001us01	1	2022-10-10	2022-10-17	20.99000	f
86	PQRTI223456	TRM002us01	1	2022-10-10	2022-10-17	20.99000	f
87	STUVX256456	TRM002us01	1	2022-10-10	2022-10-17	20.99000	f
88	VWXWW345778	TRM002us01	1	2022-10-10	2022-10-17	20.99000	f
89	AZAAA456789	TRM002us01	1	2022-10-10	2022-10-17	20.99000	f
90	BCDBB567890	TRM002us01	1	2022-10-10	2022-10-17	20.99000	f
91	BCDBB567890	DPD004us01	1	2022-10-10	2022-10-17	20.99000	f
92	CDEMM678901	RKY005us01	1	2022-10-10	2022-10-17	20.99000	f
93	EFGEE789012	RKY005us01	1	2022-10-18	2022-10-24	20.99000	f
94	GHILP890123	RKY005us01	1	2022-10-18	2022-10-24	20.99000	f
95	IJKCC901234	RKY005us01	1	2022-10-18	2022-10-24	20.99000	f
96	IJKCC901234	MST007us01	1	2022-10-18	2022-10-24	20.99000	f
97	IJKCC901234	DVL006fr01	1	2022-10-18	2022-10-24	20.99000	f
98	KLMJJ012345	DVL006fr01	1	2022-10-18	2022-10-24	20.99000	f
99	MNOHH123455	MST007us01	1	2022-10-18	2022-10-24	20.99000	f
100	PQREA235567	MST007us01	1	2022-10-18	2022-10-24	20.99000	f
101	PQREA235567	HRD009us01	1	2022-10-18	2022-10-24	20.99000	f
102	PQREA235567	MDS010us01	1	2022-11-01	2022-11-08	20.99000	f
103	STUNN335678	CRS011us01	1	2022-11-01	2022-11-08	20.99000	f
104	VWXPP456799	PFB012jp01	1	2022-11-01	2022-11-08	20.99000	f
105	YZAUU567890	LDS013us01	1	2022-11-01	2022-11-08	20.99000	f
106	UUUUU678901	AZL014fr01	1	2022-11-01	2022-11-08	20.99000	f
107	CEEEE789012	ROJ015fr01	1	2022-11-01	2022-11-08	20.99000	f
108	EFGQQ890123	ROJ015fr01	1	2022-11-01	2022-11-08	20.99000	f
109	GHIQW901234	ROJ015fr01	1	2022-11-01	2022-11-08	20.99000	f
110	EFGQQ890123	ROJ015fr01	1	2023-06-02	2023-06-09	20.99000	f
111	UUUUU678901	AZL014fr01	1	2023-06-02	2023-06-09	20.99000	f
112	GHIQW901234	LDS013us01	1	2023-06-02	2023-06-09	20.99000	f
\.


--
-- TOC entry 3436 (class 0 OID 28174)
-- Dependencies: 217
-- Data for Name: reseñas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."reseñas" (id_pelicula, id_cliente, calificacion, comentario) FROM stdin;
ABC123ab01	ABCDE123456	4	¡Me encantó esta película! La recomiendo ampliamente.
XYZ987xy02	ABCDE123456	3	La trama fue interesante pero esperaba más acción.
DEF456de03	ABCDE123456	5	Sin duda, una de las mejores películas que he visto.
MNO654mn04	FGHIJ789012	2	No me gustó el final, fue muy predecible.
JKL321jk06	FGHIJ789012	1	Los efectos especiales son impresionantes.
PQR987pq07	FGHIJ789012	1	Me aburrí durante toda la película.
MNO654mn04	KLMNO234567	5	¡Una obra maestra! Me dejó sin palabras.
STU654st08	KLMNO234567	0	Buena película, pero esperaba más desarrollo de personajes.
ABC123ab01	KLMNO234567	1	Me encantó la actuación de los protagonistas.
XYZ987xy02	KLMNO234567	2	El guion es flojo y la historia no me convenció.
DEF456de03	KLMNO234567	4	Recomiendo esta película a todos los amantes del cine.
DEF456de03	PQRST890123	5	No tengo palabras para describir lo buena que es esta película.
MNO654mn04	PQRST890123	3	Me gustó, pero esperaba un desenlace diferente.
JKL321jk06	UVWXY345678	1	La trama es confusa y los diálogos son poco interesantes.
PQR987pq07	UVWXY345678	4	Una película entretenida con un gran reparto de actores.
STU654st08	UVWXY345678	2	No logró captar mi atención, me pareció aburrida.
VWX321vw09	ZACDE901234	5	¡Increíble! No puedo esperar para verla de nuevo.
YZA789yz10	ZACDE901234	3	La película tiene buenos efectos visuales, pero la trama es débil.
VWX321vw09	FGHIJ567890	4	Me mantuvo al borde de mi asiento durante toda la película.
YZA789yz10	KLMNO012345	2	Es una película olvidable, no deja ninguna impresión duradera.
BCD123bc11	KLMNO012345	4	Recomiendo ver esta película en el cine, la experiencia es increíble.
EFG456ef12	KLMNO012345	5	Una historia conmovedora que me hizo reflexionar.
KLM321kl14	KLMNO012345	3	La película tiene momentos interesantes, pero le falta coherencia.
NOP654no15	KLMNO012345	1	No recomiendo esta película, es un completo desperdicio de tiempo.
QRS987qr16	PQRST678901	4	Me encantó el giro inesperado en la trama.
TUV321tu17	PQRST678901	2	La película es confusa y difícil de seguir.
YZA123yz19	UVWXY123456	5	¡Una película que te deja pensando por días!
BCD456bc20	ZBCDE789012	3	Es una película promedio, no me sorprendió.
EFG789ef21	FGHIJ234567	4	Los efectos especiales son asombrosos.
HIJ321hi22	KLMNO789012	2	Me decepcionó, esperaba más de esta película.
HIJ321hi22	PQRST345678	4	Una película emocionante con grandes actuaciones.
HIJ321hi22	UVWXY890123	5	¡Simplemente impresionante! No puedo esperar a verla de nuevo.
HIJ321hi22	ZABDE456789	3	La película tiene momentos divertidos pero carece de profundidad.
KLM654kl23	ZABDE456789	4	Una película con una historia intrigante y un final sorprendente.
NOP987no24	ZABDE456789	2	No me gustó el desarrollo de los personajes principales.
QRS321qr25	ZABDE456789	5	Una película que te mantiene en suspenso de principio a fin.
TUV654tu26	ZABDE456789	3	La película tiene un buen mensaje, pero la ejecución no fue la mejor.
WXY987wx27	ZABDE456789	4	Los efectos visuales son impresionantes, valió la pena verla en el cine.
YZA321yz28	ZABDE456789	2	No logró captar mi atención, me aburrí durante la película.
BCD654bc29	PQRCI890123	4	Una película que te hace reflexionar sobre la vida.
ABC123ab31	PQRCI890123	5	¡Una experiencia cinematográfica única!
DEF456de32	PQRCI890123	3	La película tiene buenos momentos, pero algunos diálogos son débiles.
DEF456de32	STUST901234	4	Una película con un final impactante.
ABC123ab31	STUST901234	2	No entendí la trama, me pareció confusa.
ABC123ab31	VWXJF012345	5	Una obra maestra del cine, una experiencia inolvidable.
GHI789gh33	YZADX123456	3	La película tiene buen ritmo, pero el desarrollo de los personajes es débil.
GHI789gh33	BCDTA234567	4	Me encantó el mensaje de la película, me dejó pensando.
JKL321jk34	CDEAB345678	4	Una película con una excelente dirección y actuaciones.
JKL321jk34	EFGBC456789	5	¡Una película que te hace reír y llorar!
JKL321jk34	GHIII567890	1	La película es entretenida pero predecible.
MNO654mn35	GHIII567890	1	Me cautivó la cinematografía de la película.
PQR987pq36	GHIII567890	2	No me gustó el desenlace de la trama.
PQR987pq36	IJKLK678901	5	Una película que te hace reflexionar sobre la vida.
VWX654vw38	KLMHH789012	3	La película tiene momentos emocionantes, pero otros son predecibles.
STU321st37	KLMHH789012	4	Un gran elenco y una historia conmovedora.
YZA987yz39	KLMHH789012	2	La película no cumplió con mis expectativas.
BCD321bc40	KLMHH789012	4	Una película que te mantiene intrigado de principio a fin.
HIJ987hi42	KLMHH789012	5	¡Una película que recomendaría a todos mis amigos!
HIJ987hi42	MNOYY890123	3	La película tiene un buen inicio, pero luego pierde intensidad.
KLM321kl43	MNOYY890123	4	Me encantó la banda sonora de la película.
KLM321kl43	PQRTG901234	2	No logré conectar emocionalmente con la historia.
QRS987qr45	STULI012345	5	Una película que te deja pensando mucho después de que termina.
QRS987qr45	VWXNN234456	3	La película tiene momentos de suspenso, pero el desenlace fue decepcionante.
QRS987qr45	YZAZA234567	4	Una película con una historia conmovedora y personajes memorables.
QRS987qr45	BCDOI345678	2	No entendí el mensaje que quería transmitir la película.
WXY654wx47	CDECC456789	4	Una película que te hace pensar en el sentido de la vida.
WXY654wx47	EFGER567890	5	¡Una película épica que superó todas mis expectativas!
DEF456eu62	GHIVV678901	3	La película tiene buenos momentos, pero algunos diálogos son flojos.
GHI789eu63	IJKRS789012	1	Un final satisfactorio que amarró todas las subtramas.
MNO345eu65	KLMJD890123	2	La película no logró captar mi atención, me pareció aburrida.
MNO345eu65	IJKRS789012	2	Una película que te hace reflexionar sobre el amor y la amistad.
MNO345eu65	PQRSS012345	3	La película tiene un buen concepto, pero la ejecución fue deficiente.
PQR678eu66	STUHI123456	4	Me emocioné con la actuación de los protagonistas.
PQR678eu66	VWXXC234567	2	No entendí el propósito de algunos personajes en la trama.
STU901eu67	YZAVV345678	4	Una película que me mantuvo intrigado de principio a fin.
YZA567eu69	BCDBC456709	5	¡Una obra maestra del cine! No puedo esperar para verla nuevamente.
EFG123eu71	CDEZX567890	3	La película tiene un ritmo irregular, algunas partes son lentas.
BCD890eu70	EFGOI678901	4	Una película con una fotografía impresionante y una historia conmovedora.
NOP012eu74	GHIMM789012	2	No me gustó la dirección de arte, me pareció poco original.
QRS345eu75	IJKIK890123	5	Una película que te sumerge en un mundo fascinante y lleno de sorpresas.
TUV678eu76	KLMHH901234	1	La película tiene un buen concepto, pero el guion es débil.
ZAB234eu78	KLMHH901234	1	Una película que me hizo reflexionar sobre la vida y la muerte.
EFG890eu80	KLMHH901234	2	No me convencieron las actuaciones de los protagonistas.
ZAB901eu87	MNOMN012335	4	Una película con un mensaje profundo y actuaciones destacadas.
ALV001us01	MNOMN012335	5	¡Una película que te deja sin aliento!
TRM002us01	PQRTI223456	3	La película tiene momentos emotivos, pero la trama es predecible.
TRM002us01	STUVX256456	4	Me encantó la química entre los actores principales.
TRM002us01	VWXWW345778	2	No logré conectar con la historia, me dejó indiferente.
TRM002us01	AZAAA456789	5	Una película que me mantuvo al borde de mi asiento.
TRM002us01	BCDBB567890	3	La película tiene un buen mensaje, pero la ejecución fue confusa.
DPD004us01	BCDBB567890	4	Una película que me hizo reflexionar sobre la importancia de la familia.
RKY005us01	CDEMM678901	2	No me convenció la elección del elenco, no encajaban en sus roles.
RKY005us01	EFGEE789012	4	Una película con una estética visual impresionante.
RKY005us01	GHILP890123	5	¡Una película que te hace cuestionar la realidad!
RKY005us01	IJKCC901234	1	La película tiene momentos divertidos, pero la trama es débil.
MST007us01	IJKCC901234	1	Me encantó la banda sonora de la película.
DVL006fr01	IJKCC901234	2	No entendí el propósito de algunos personajes secundarios.
DVL006fr01	KLMJJ012345	5	Una película que te sumerge en un mundo de fantasía.
MST007us01	MNOHH123455	3	La película tiene un ritmo lento, le falta dinamismo.
MST007us01	PQREA235567	1	Una película con un desenlace inesperado.
HRD009us01	PQREA235567	2	No logré conectar con ninguno de los personajes.
MDS010us01	PQREA235567	0	Una película que te hace reflexionar sobre el paso del tiempo.
CRS011us01	STUNN335678	5	¡Una película que te deja con ganas de más!
PFB012jp01	VWXPP456799	3	La película tiene momentos emotivos, pero la trama es predecible.
LDS013us01	YZAUU567890	4	Me encantó la química entre los actores principales.
AZL014fr01	UUUUU678901	2	No logré conectar con la historia, me dejó indiferente.
ROJ015fr01	CEEEE789012	5	Una película que me mantuvo al borde de mi asiento.
ROJ015fr01	EFGQQ890123	3	La película tiene un buen mensaje, pero la ejecución fue confusa.
ROJ015fr01	GHIQW901234	4	Una película que me hizo reflexionar sobre la importancia de la familia.
SSR055it01	GHIQW901234	4	Gran película, me hizo temblar de miedo.
SSR055it01	EFGQQ890123	4	Me encantó la escena de Olga y los espejos.
SSR055it01	UUUUU678901	5	Simplemente imperdible, de lo mejor que he visto.
\.


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 220
-- Name: adeudos_no_adeudo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adeudos_no_adeudo_seq', 105, true);


--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 222
-- Name: pagos_no_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pagos_no_pago_seq', 103, true);


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 218
-- Name: prestamos_no_prestamo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prestamos_no_prestamo_seq', 112, true);


--
-- TOC entry 3267 (class 2606 OID 28230)
-- Name: adeudos adeudos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adeudos
    ADD CONSTRAINT adeudos_pkey PRIMARY KEY (no_adeudo, no_prestamo, id_cliente, id_pelicula, no_copia);


--
-- TOC entry 3245 (class 2606 OID 28149)
-- Name: clientes clientes_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_email_key UNIQUE (email);


--
-- TOC entry 3247 (class 2606 OID 28147)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 3255 (class 2606 OID 28168)
-- Name: copias copias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.copias
    ADD CONSTRAINT copias_pkey PRIMARY KEY (no_copia, id_pelicula);


--
-- TOC entry 3271 (class 2606 OID 28252)
-- Name: pagos pagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_pkey PRIMARY KEY (no_pago, no_prestamo, id_cliente, id_pelicula, no_copia);


--
-- TOC entry 3251 (class 2606 OID 28158)
-- Name: peliculas peliculas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.peliculas
    ADD CONSTRAINT peliculas_pkey PRIMARY KEY (id_pelicula);


--
-- TOC entry 3259 (class 2606 OID 28201)
-- Name: prestamos prestamos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT prestamos_pkey PRIMARY KEY (no_prestamo, id_cliente, id_pelicula, no_copia);


--
-- TOC entry 3257 (class 2606 OID 28181)
-- Name: reseñas reseñas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reseñas"
    ADD CONSTRAINT "reseñas_pkey" PRIMARY KEY (id_pelicula, id_cliente);


--
-- TOC entry 3249 (class 2606 OID 28151)
-- Name: clientes unq_cliente_datos; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT unq_cliente_datos UNIQUE (nombres, apellido_paterno, apellido_materno, edad, direccion);


--
-- TOC entry 3261 (class 2606 OID 28203)
-- Name: prestamos unq_copia_activo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT unq_copia_activo EXCLUDE USING btree (no_copia WITH =, id_pelicula WITH =) WHERE ((activo = true));


--
-- TOC entry 3269 (class 2606 OID 28232)
-- Name: adeudos unq_fecha_adeudo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adeudos
    ADD CONSTRAINT unq_fecha_adeudo UNIQUE (id_cliente, id_pelicula, fecha_adeudo);


--
-- TOC entry 3273 (class 2606 OID 28254)
-- Name: pagos unq_fecha_pago; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT unq_fecha_pago UNIQUE (id_cliente, id_pelicula, fecha_pago);


--
-- TOC entry 3263 (class 2606 OID 28207)
-- Name: prestamos unq_fecha_prestamo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT unq_fecha_prestamo UNIQUE (id_cliente, id_pelicula, fecha_prestamo, fecha_devolucion);


--
-- TOC entry 3253 (class 2606 OID 28160)
-- Name: peliculas unq_peli; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.peliculas
    ADD CONSTRAINT unq_peli UNIQUE (titulo, "año_lanzamiento", director);


--
-- TOC entry 3265 (class 2606 OID 28205)
-- Name: prestamos unq_peli_simul; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT unq_peli_simul EXCLUDE USING btree (id_cliente WITH =, id_pelicula WITH =) WHERE ((activo = true));


--
-- TOC entry 3284 (class 2620 OID 28243)
-- Name: adeudos trg_verificar_actividad_prestamo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_verificar_actividad_prestamo BEFORE INSERT OR UPDATE ON public.adeudos FOR EACH ROW EXECUTE FUNCTION public.verificar_actividad_prestamo();


--
-- TOC entry 3281 (class 2620 OID 28221)
-- Name: prestamos trg_verificar_adeudo_activo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_verificar_adeudo_activo BEFORE INSERT OR UPDATE ON public.prestamos FOR EACH ROW EXECUTE FUNCTION public.verificar_adeudo_activo();


--
-- TOC entry 3282 (class 2620 OID 28219)
-- Name: prestamos trg_verificar_estado_copia; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_verificar_estado_copia BEFORE INSERT OR UPDATE ON public.prestamos FOR EACH ROW EXECUTE FUNCTION public.verificar_estado_copia();


--
-- TOC entry 3285 (class 2620 OID 28241)
-- Name: adeudos trg_verificar_fecha_adeudo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_verificar_fecha_adeudo BEFORE INSERT OR UPDATE ON public.adeudos FOR EACH ROW EXECUTE FUNCTION public.verificar_fecha_adeudo();


--
-- TOC entry 3287 (class 2620 OID 28261)
-- Name: pagos trg_verificar_fecha_pago; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_verificar_fecha_pago BEFORE INSERT OR UPDATE ON public.pagos FOR EACH ROW EXECUTE FUNCTION public.verificar_fecha_pago();


--
-- TOC entry 3286 (class 2620 OID 28239)
-- Name: adeudos trg_verificar_monto_adeudo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_verificar_monto_adeudo BEFORE INSERT OR UPDATE ON public.adeudos FOR EACH ROW EXECUTE FUNCTION public.verificar_monto_adeudo();


--
-- TOC entry 3283 (class 2620 OID 28223)
-- Name: prestamos trigger_verificar_cantidad_copias; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_verificar_cantidad_copias BEFORE INSERT OR UPDATE ON public.prestamos FOR EACH ROW EXECUTE FUNCTION public.verificar_cantidad_copias();


--
-- TOC entry 3279 (class 2606 OID 28233)
-- Name: adeudos adeudos_no_prestamo_id_cliente_id_pelicula_no_copia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adeudos
    ADD CONSTRAINT adeudos_no_prestamo_id_cliente_id_pelicula_no_copia_fkey FOREIGN KEY (no_prestamo, id_cliente, id_pelicula, no_copia) REFERENCES public.prestamos(no_prestamo, id_cliente, id_pelicula, no_copia) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3274 (class 2606 OID 28169)
-- Name: copias copias_id_pelicula_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.copias
    ADD CONSTRAINT copias_id_pelicula_fkey FOREIGN KEY (id_pelicula) REFERENCES public.peliculas(id_pelicula) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3280 (class 2606 OID 28255)
-- Name: pagos pagos_no_prestamo_id_cliente_id_pelicula_no_copia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_no_prestamo_id_cliente_id_pelicula_no_copia_fkey FOREIGN KEY (no_prestamo, id_cliente, id_pelicula, no_copia) REFERENCES public.prestamos(no_prestamo, id_cliente, id_pelicula, no_copia) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3277 (class 2606 OID 28208)
-- Name: prestamos prestamos_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT prestamos_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3278 (class 2606 OID 28213)
-- Name: prestamos prestamos_id_pelicula_no_copia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prestamos
    ADD CONSTRAINT prestamos_id_pelicula_no_copia_fkey FOREIGN KEY (id_pelicula, no_copia) REFERENCES public.copias(id_pelicula, no_copia) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3275 (class 2606 OID 28187)
-- Name: reseñas reseñas_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reseñas"
    ADD CONSTRAINT "reseñas_id_cliente_fkey" FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3276 (class 2606 OID 28182)
-- Name: reseñas reseñas_id_pelicula_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reseñas"
    ADD CONSTRAINT "reseñas_id_pelicula_fkey" FOREIGN KEY (id_pelicula) REFERENCES public.peliculas(id_pelicula) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2023-06-11 23:24:45

--
-- PostgreSQL database dump complete
--

