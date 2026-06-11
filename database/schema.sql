--
-- PostgreSQL database dump
--

\restrict Xk5XhYuhxIsVQ7txJJggcfhaTsL20dSVY9fhYeeTAWArHYTFWjlyzgYRgq31mvd

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

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

ALTER TABLE IF EXISTS ONLY public.personal DROP CONSTRAINT IF EXISTS fk_personal_rol;
ALTER TABLE IF EXISTS ONLY public.cat_municipios DROP CONSTRAINT IF EXISTS fk_municipio_estado;
ALTER TABLE IF EXISTS ONLY public.menores DROP CONSTRAINT IF EXISTS fk_menor_estatus;
ALTER TABLE IF EXISTS ONLY public.menores DROP CONSTRAINT IF EXISTS fk_menor_celula;
ALTER TABLE IF EXISTS ONLY public.expedientes_multidisciplinarios DROP CONSTRAINT IF EXISTS fk_expediente_personal;
ALTER TABLE IF EXISTS ONLY public.expedientes_multidisciplinarios DROP CONSTRAINT IF EXISTS fk_expediente_menor;
ALTER TABLE IF EXISTS ONLY public.celula_integrantes DROP CONSTRAINT IF EXISTS fk_ci_personal;
ALTER TABLE IF EXISTS ONLY public.celula_integrantes DROP CONSTRAINT IF EXISTS fk_ci_celula;
ALTER TABLE IF EXISTS ONLY public.celulas DROP CONSTRAINT IF EXISTS fk_celula_municipio;
ALTER TABLE IF EXISTS ONLY public.apoyos_asignados DROP CONSTRAINT IF EXISTS fk_apoyo_menor;
ALTER TABLE IF EXISTS ONLY public.celula_integrantes DROP CONSTRAINT IF EXISTS pk_celula_integrantes;
ALTER TABLE IF EXISTS ONLY public.personal DROP CONSTRAINT IF EXISTS personal_rfc_key;
ALTER TABLE IF EXISTS ONLY public.personal DROP CONSTRAINT IF EXISTS personal_pkey;
ALTER TABLE IF EXISTS ONLY public.personal DROP CONSTRAINT IF EXISTS personal_curp_key;
ALTER TABLE IF EXISTS ONLY public.personal DROP CONSTRAINT IF EXISTS personal_correo_key;
ALTER TABLE IF EXISTS ONLY public.menores DROP CONSTRAINT IF EXISTS menores_pkey;
ALTER TABLE IF EXISTS ONLY public.menores DROP CONSTRAINT IF EXISTS menores_curp_key;
ALTER TABLE IF EXISTS ONLY public.expedientes_multidisciplinarios DROP CONSTRAINT IF EXISTS expedientes_multidisciplinarios_pkey;
ALTER TABLE IF EXISTS ONLY public.celulas DROP CONSTRAINT IF EXISTS celulas_pkey;
ALTER TABLE IF EXISTS ONLY public.cat_roles DROP CONSTRAINT IF EXISTS cat_roles_pkey;
ALTER TABLE IF EXISTS ONLY public.cat_municipios DROP CONSTRAINT IF EXISTS cat_municipios_pkey;
ALTER TABLE IF EXISTS ONLY public.cat_estatus_menor DROP CONSTRAINT IF EXISTS cat_estatus_menor_pkey;
ALTER TABLE IF EXISTS ONLY public.cat_estados DROP CONSTRAINT IF EXISTS cat_estados_pkey;
ALTER TABLE IF EXISTS ONLY public.apoyos_asignados DROP CONSTRAINT IF EXISTS apoyos_asignados_pkey;
ALTER TABLE IF EXISTS public.personal ALTER COLUMN id_personal DROP DEFAULT;
ALTER TABLE IF EXISTS public.menores ALTER COLUMN id_menor DROP DEFAULT;
ALTER TABLE IF EXISTS public.expedientes_multidisciplinarios ALTER COLUMN id_expediente DROP DEFAULT;
ALTER TABLE IF EXISTS public.celulas ALTER COLUMN id_celula DROP DEFAULT;
ALTER TABLE IF EXISTS public.cat_roles ALTER COLUMN id_rol DROP DEFAULT;
ALTER TABLE IF EXISTS public.cat_municipios ALTER COLUMN id_municipio DROP DEFAULT;
ALTER TABLE IF EXISTS public.cat_estatus_menor ALTER COLUMN id_estatus DROP DEFAULT;
ALTER TABLE IF EXISTS public.cat_estados ALTER COLUMN id_estado DROP DEFAULT;
ALTER TABLE IF EXISTS public.apoyos_asignados ALTER COLUMN id_apoyo DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.personal_id_personal_seq;
DROP TABLE IF EXISTS public.personal;
DROP SEQUENCE IF EXISTS public.menores_id_menor_seq;
DROP TABLE IF EXISTS public.menores;
DROP SEQUENCE IF EXISTS public.expedientes_multidisciplinarios_id_expediente_seq;
DROP TABLE IF EXISTS public.expedientes_multidisciplinarios;
DROP SEQUENCE IF EXISTS public.celulas_id_celula_seq;
DROP TABLE IF EXISTS public.celulas;
DROP TABLE IF EXISTS public.celula_integrantes;
DROP SEQUENCE IF EXISTS public.cat_roles_id_rol_seq;
DROP TABLE IF EXISTS public.cat_roles;
DROP SEQUENCE IF EXISTS public.cat_municipios_id_municipio_seq;
DROP TABLE IF EXISTS public.cat_municipios;
DROP SEQUENCE IF EXISTS public.cat_estatus_menor_id_estatus_seq;
DROP TABLE IF EXISTS public.cat_estatus_menor;
DROP SEQUENCE IF EXISTS public.cat_estados_id_estado_seq;
DROP TABLE IF EXISTS public.cat_estados;
DROP SEQUENCE IF EXISTS public.apoyos_asignados_id_apoyo_seq;
DROP TABLE IF EXISTS public.apoyos_asignados;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: apoyos_asignados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.apoyos_asignados (
    id_apoyo integer NOT NULL,
    id_menor integer NOT NULL,
    tipo_apoyo character varying(150) NOT NULL,
    monto_o_especie character varying(200) NOT NULL,
    periodicidad character varying(50) NOT NULL,
    CONSTRAINT chk_periodicidad CHECK (((periodicidad)::text = ANY (ARRAY[('Única vez'::character varying)::text, ('Semanal'::character varying)::text, ('Quincenal'::character varying)::text, ('Mensual'::character varying)::text, ('Bimestral'::character varying)::text, ('Trimestral'::character varying)::text, ('Anual'::character varying)::text])))
);


ALTER TABLE public.apoyos_asignados OWNER TO postgres;

--
-- Name: apoyos_asignados_id_apoyo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.apoyos_asignados_id_apoyo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.apoyos_asignados_id_apoyo_seq OWNER TO postgres;

--
-- Name: apoyos_asignados_id_apoyo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.apoyos_asignados_id_apoyo_seq OWNED BY public.apoyos_asignados.id_apoyo;


--
-- Name: cat_estados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_estados (
    id_estado integer NOT NULL,
    nombre character varying(100) NOT NULL
);


ALTER TABLE public.cat_estados OWNER TO postgres;

--
-- Name: cat_estados_id_estado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_estados_id_estado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_estados_id_estado_seq OWNER TO postgres;

--
-- Name: cat_estados_id_estado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_estados_id_estado_seq OWNED BY public.cat_estados.id_estado;


--
-- Name: cat_estatus_menor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_estatus_menor (
    id_estatus integer NOT NULL,
    descripcion character varying(100) NOT NULL
);


ALTER TABLE public.cat_estatus_menor OWNER TO postgres;

--
-- Name: cat_estatus_menor_id_estatus_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_estatus_menor_id_estatus_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_estatus_menor_id_estatus_seq OWNER TO postgres;

--
-- Name: cat_estatus_menor_id_estatus_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_estatus_menor_id_estatus_seq OWNED BY public.cat_estatus_menor.id_estatus;


--
-- Name: cat_municipios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_municipios (
    id_municipio integer NOT NULL,
    id_estado integer NOT NULL,
    nombre character varying(150) NOT NULL
);


ALTER TABLE public.cat_municipios OWNER TO postgres;

--
-- Name: cat_municipios_id_municipio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_municipios_id_municipio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_municipios_id_municipio_seq OWNER TO postgres;

--
-- Name: cat_municipios_id_municipio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_municipios_id_municipio_seq OWNED BY public.cat_municipios.id_municipio;


--
-- Name: cat_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_roles (
    id_rol integer NOT NULL,
    nombre_rol character varying(80) NOT NULL
);


ALTER TABLE public.cat_roles OWNER TO postgres;

--
-- Name: cat_roles_id_rol_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_roles_id_rol_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_roles_id_rol_seq OWNER TO postgres;

--
-- Name: cat_roles_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_roles_id_rol_seq OWNED BY public.cat_roles.id_rol;


--
-- Name: celula_integrantes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.celula_integrantes (
    id_celula integer NOT NULL,
    id_personal integer NOT NULL
);


ALTER TABLE public.celula_integrantes OWNER TO postgres;

--
-- Name: celulas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.celulas (
    id_celula integer NOT NULL,
    nombre_celula character varying(150) NOT NULL,
    id_municipio integer NOT NULL
);


ALTER TABLE public.celulas OWNER TO postgres;

--
-- Name: celulas_id_celula_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.celulas_id_celula_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.celulas_id_celula_seq OWNER TO postgres;

--
-- Name: celulas_id_celula_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.celulas_id_celula_seq OWNED BY public.celulas.id_celula;


--
-- Name: expedientes_multidisciplinarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expedientes_multidisciplinarios (
    id_expediente integer NOT NULL,
    id_menor integer NOT NULL,
    id_personal integer NOT NULL,
    tipo_evaluacion character varying(20) NOT NULL,
    diagnostico text,
    dictamen_provisional boolean DEFAULT false NOT NULL,
    fecha_evaluacion date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT chk_tipo_evaluacion CHECK (((tipo_evaluacion)::text = ANY (ARRAY[('Médica'::character varying)::text, ('Legal'::character varying)::text, ('Psicológica'::character varying)::text, ('Social'::character varying)::text])))
);


ALTER TABLE public.expedientes_multidisciplinarios OWNER TO postgres;

--
-- Name: expedientes_multidisciplinarios_id_expediente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.expedientes_multidisciplinarios_id_expediente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expedientes_multidisciplinarios_id_expediente_seq OWNER TO postgres;

--
-- Name: expedientes_multidisciplinarios_id_expediente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.expedientes_multidisciplinarios_id_expediente_seq OWNED BY public.expedientes_multidisciplinarios.id_expediente;


--
-- Name: menores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menores (
    id_menor integer NOT NULL,
    nombre_completo character varying(200) NOT NULL,
    curp character varying(18) NOT NULL,
    fecha_nacimiento date NOT NULL,
    fecha_registro timestamp without time zone DEFAULT now() NOT NULL,
    id_celula_asignada integer NOT NULL,
    id_estatus integer NOT NULL
);


ALTER TABLE public.menores OWNER TO postgres;

--
-- Name: menores_id_menor_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.menores_id_menor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menores_id_menor_seq OWNER TO postgres;

--
-- Name: menores_id_menor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.menores_id_menor_seq OWNED BY public.menores.id_menor;


--
-- Name: personal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal (
    id_personal integer NOT NULL,
    nombre_completo character varying(200) NOT NULL,
    rfc character varying(13) NOT NULL,
    curp character varying(18) NOT NULL,
    correo character varying(150) NOT NULL,
    contrasena text NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    id_rol integer NOT NULL
);


ALTER TABLE public.personal OWNER TO postgres;

--
-- Name: personal_id_personal_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personal_id_personal_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_id_personal_seq OWNER TO postgres;

--
-- Name: personal_id_personal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personal_id_personal_seq OWNED BY public.personal.id_personal;


--
-- Name: apoyos_asignados id_apoyo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apoyos_asignados ALTER COLUMN id_apoyo SET DEFAULT nextval('public.apoyos_asignados_id_apoyo_seq'::regclass);


--
-- Name: cat_estados id_estado; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_estados ALTER COLUMN id_estado SET DEFAULT nextval('public.cat_estados_id_estado_seq'::regclass);


--
-- Name: cat_estatus_menor id_estatus; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_estatus_menor ALTER COLUMN id_estatus SET DEFAULT nextval('public.cat_estatus_menor_id_estatus_seq'::regclass);


--
-- Name: cat_municipios id_municipio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_municipios ALTER COLUMN id_municipio SET DEFAULT nextval('public.cat_municipios_id_municipio_seq'::regclass);


--
-- Name: cat_roles id_rol; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_roles ALTER COLUMN id_rol SET DEFAULT nextval('public.cat_roles_id_rol_seq'::regclass);


--
-- Name: celulas id_celula; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celulas ALTER COLUMN id_celula SET DEFAULT nextval('public.celulas_id_celula_seq'::regclass);


--
-- Name: expedientes_multidisciplinarios id_expediente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expedientes_multidisciplinarios ALTER COLUMN id_expediente SET DEFAULT nextval('public.expedientes_multidisciplinarios_id_expediente_seq'::regclass);


--
-- Name: menores id_menor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menores ALTER COLUMN id_menor SET DEFAULT nextval('public.menores_id_menor_seq'::regclass);


--
-- Name: personal id_personal; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal ALTER COLUMN id_personal SET DEFAULT nextval('public.personal_id_personal_seq'::regclass);


--
-- Data for Name: apoyos_asignados; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: cat_estados; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: cat_estatus_menor; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: cat_municipios; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: cat_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cat_roles VALUES (1, 'Director');
INSERT INTO public.cat_roles VALUES (2, 'Médico');
INSERT INTO public.cat_roles VALUES (3, 'Desarrollador');


--
-- Data for Name: celula_integrantes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: celulas; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: expedientes_multidisciplinarios; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: menores; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: personal; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.personal VALUES (1, 'Obed Viveros', 'DIRT800101ABC', 'DIRT800101HDFRZR09', 'director@rnpi.gob.mx', '$2b$12$0fU2KE21GQ.4ve6mOfWN4unaAsgWF8sDH7.VyHVwAoCCD0NAi0r/2', true, 1);
INSERT INTO public.personal VALUES (3, 'Roony Roldan Cruz', 'ROONJJDJWJ34J', 'ROONJJDJWJ34JHFJDD', 'roonyr@rnpi.gob.mx', '$2b$12$a5m.rcobVoVS791lvzDCe.ltcN4oEe3mZ0KBdMbbfhzMENEQjZWu2', true, 3);


--
-- Name: apoyos_asignados_id_apoyo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.apoyos_asignados_id_apoyo_seq', 1, false);


--
-- Name: cat_estados_id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_estados_id_estado_seq', 1, false);


--
-- Name: cat_estatus_menor_id_estatus_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_estatus_menor_id_estatus_seq', 1, false);


--
-- Name: cat_municipios_id_municipio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_municipios_id_municipio_seq', 1, false);


--
-- Name: cat_roles_id_rol_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_roles_id_rol_seq', 3, true);


--
-- Name: celulas_id_celula_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.celulas_id_celula_seq', 1, false);


--
-- Name: expedientes_multidisciplinarios_id_expediente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.expedientes_multidisciplinarios_id_expediente_seq', 1, false);


--
-- Name: menores_id_menor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.menores_id_menor_seq', 1, false);


--
-- Name: personal_id_personal_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personal_id_personal_seq', 3, true);


--
-- Name: apoyos_asignados apoyos_asignados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apoyos_asignados
    ADD CONSTRAINT apoyos_asignados_pkey PRIMARY KEY (id_apoyo);


--
-- Name: cat_estados cat_estados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_estados
    ADD CONSTRAINT cat_estados_pkey PRIMARY KEY (id_estado);


--
-- Name: cat_estatus_menor cat_estatus_menor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_estatus_menor
    ADD CONSTRAINT cat_estatus_menor_pkey PRIMARY KEY (id_estatus);


--
-- Name: cat_municipios cat_municipios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_municipios
    ADD CONSTRAINT cat_municipios_pkey PRIMARY KEY (id_municipio);


--
-- Name: cat_roles cat_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_roles
    ADD CONSTRAINT cat_roles_pkey PRIMARY KEY (id_rol);


--
-- Name: celulas celulas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celulas
    ADD CONSTRAINT celulas_pkey PRIMARY KEY (id_celula);


--
-- Name: expedientes_multidisciplinarios expedientes_multidisciplinarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expedientes_multidisciplinarios
    ADD CONSTRAINT expedientes_multidisciplinarios_pkey PRIMARY KEY (id_expediente);


--
-- Name: menores menores_curp_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menores
    ADD CONSTRAINT menores_curp_key UNIQUE (curp);


--
-- Name: menores menores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menores
    ADD CONSTRAINT menores_pkey PRIMARY KEY (id_menor);


--
-- Name: personal personal_correo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT personal_correo_key UNIQUE (correo);


--
-- Name: personal personal_curp_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT personal_curp_key UNIQUE (curp);


--
-- Name: personal personal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT personal_pkey PRIMARY KEY (id_personal);


--
-- Name: personal personal_rfc_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT personal_rfc_key UNIQUE (rfc);


--
-- Name: celula_integrantes pk_celula_integrantes; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celula_integrantes
    ADD CONSTRAINT pk_celula_integrantes PRIMARY KEY (id_celula, id_personal);


--
-- Name: apoyos_asignados fk_apoyo_menor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apoyos_asignados
    ADD CONSTRAINT fk_apoyo_menor FOREIGN KEY (id_menor) REFERENCES public.menores(id_menor) ON DELETE CASCADE;


--
-- Name: celulas fk_celula_municipio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celulas
    ADD CONSTRAINT fk_celula_municipio FOREIGN KEY (id_municipio) REFERENCES public.cat_municipios(id_municipio) ON DELETE RESTRICT;


--
-- Name: celula_integrantes fk_ci_celula; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celula_integrantes
    ADD CONSTRAINT fk_ci_celula FOREIGN KEY (id_celula) REFERENCES public.celulas(id_celula) ON DELETE RESTRICT;


--
-- Name: celula_integrantes fk_ci_personal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.celula_integrantes
    ADD CONSTRAINT fk_ci_personal FOREIGN KEY (id_personal) REFERENCES public.personal(id_personal) ON DELETE RESTRICT;


--
-- Name: expedientes_multidisciplinarios fk_expediente_menor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expedientes_multidisciplinarios
    ADD CONSTRAINT fk_expediente_menor FOREIGN KEY (id_menor) REFERENCES public.menores(id_menor) ON DELETE CASCADE;


--
-- Name: expedientes_multidisciplinarios fk_expediente_personal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expedientes_multidisciplinarios
    ADD CONSTRAINT fk_expediente_personal FOREIGN KEY (id_personal) REFERENCES public.personal(id_personal) ON DELETE RESTRICT;


--
-- Name: menores fk_menor_celula; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menores
    ADD CONSTRAINT fk_menor_celula FOREIGN KEY (id_celula_asignada) REFERENCES public.celulas(id_celula) ON DELETE RESTRICT;


--
-- Name: menores fk_menor_estatus; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menores
    ADD CONSTRAINT fk_menor_estatus FOREIGN KEY (id_estatus) REFERENCES public.cat_estatus_menor(id_estatus) ON DELETE RESTRICT;


--
-- Name: cat_municipios fk_municipio_estado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_municipios
    ADD CONSTRAINT fk_municipio_estado FOREIGN KEY (id_estado) REFERENCES public.cat_estados(id_estado) ON DELETE RESTRICT;


--
-- Name: personal fk_personal_rol; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT fk_personal_rol FOREIGN KEY (id_rol) REFERENCES public.cat_roles(id_rol) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict Xk5XhYuhxIsVQ7txJJggcfhaTsL20dSVY9fhYeeTAWArHYTFWjlyzgYRgq31mvd

