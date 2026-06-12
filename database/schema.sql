--
-- PostgreSQL database dump
--

\restrict ScEhOtV9HVBc0njxh7WmWUS4qLynbDSGD1dmPwGCB9lFLjdaxabgJIuFOWgic6R

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: asentamiento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asentamiento (
    id_asen integer NOT NULL,
    id_mun integer NOT NULL,
    nom_mun character varying(200) NOT NULL,
    id_col integer,
    nom_col character varying(200) NOT NULL,
    cp_asen character varying(5) NOT NULL,
    id_ent integer NOT NULL
);


ALTER TABLE public.asentamiento OWNER TO postgres;

--
-- Name: asentamiento_id_asen_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asentamiento_id_asen_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.asentamiento_id_asen_seq OWNER TO postgres;

--
-- Name: asentamiento_id_asen_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asentamiento_id_asen_seq OWNED BY public.asentamiento.id_asen;


--
-- Name: cat_cie_bloque; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_cie_bloque (
    id_bloque integer NOT NULL,
    id_capitulo integer NOT NULL,
    codigo_inicio character varying(7) NOT NULL,
    codigo_fin character varying(7) NOT NULL,
    descripcion character varying(300) NOT NULL
);


ALTER TABLE public.cat_cie_bloque OWNER TO postgres;

--
-- Name: cat_cie_bloque_id_bloque_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_cie_bloque_id_bloque_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_cie_bloque_id_bloque_seq OWNER TO postgres;

--
-- Name: cat_cie_bloque_id_bloque_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_cie_bloque_id_bloque_seq OWNED BY public.cat_cie_bloque.id_bloque;


--
-- Name: cat_cie_capitulo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_cie_capitulo (
    id_capitulo integer NOT NULL,
    codigo_romano character varying(10) NOT NULL,
    descripcion character varying(300) NOT NULL
);


ALTER TABLE public.cat_cie_capitulo OWNER TO postgres;

--
-- Name: cat_cie_capitulo_id_capitulo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_cie_capitulo_id_capitulo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_cie_capitulo_id_capitulo_seq OWNER TO postgres;

--
-- Name: cat_cie_capitulo_id_capitulo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_cie_capitulo_id_capitulo_seq OWNED BY public.cat_cie_capitulo.id_capitulo;


--
-- Name: cat_cie_categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_cie_categoria (
    id_categoria integer NOT NULL,
    id_bloque integer NOT NULL,
    codigo character(3) NOT NULL,
    descripcion character varying(300) NOT NULL
);


ALTER TABLE public.cat_cie_categoria OWNER TO postgres;

--
-- Name: cat_cie_categoria_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_cie_categoria_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_cie_categoria_id_categoria_seq OWNER TO postgres;

--
-- Name: cat_cie_categoria_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_cie_categoria_id_categoria_seq OWNED BY public.cat_cie_categoria.id_categoria;


--
-- Name: cat_cie_subcategoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_cie_subcategoria (
    id_subcategoria integer NOT NULL,
    id_categoria integer NOT NULL,
    codigo character varying(7) NOT NULL,
    descripcion character varying(300) NOT NULL
);


ALTER TABLE public.cat_cie_subcategoria OWNER TO postgres;

--
-- Name: cat_cie_subcategoria_id_subcategoria_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_cie_subcategoria_id_subcategoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_cie_subcategoria_id_subcategoria_seq OWNER TO postgres;

--
-- Name: cat_cie_subcategoria_id_subcategoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_cie_subcategoria_id_subcategoria_seq OWNED BY public.cat_cie_subcategoria.id_subcategoria;


--
-- Name: cat_discapacidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_discapacidad (
    id_dis integer NOT NULL,
    nombre character varying(100) NOT NULL
);


ALTER TABLE public.cat_discapacidad OWNER TO postgres;

--
-- Name: cat_discapacidad_id_dis_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_discapacidad_id_dis_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_discapacidad_id_dis_seq OWNER TO postgres;

--
-- Name: cat_discapacidad_id_dis_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_discapacidad_id_dis_seq OWNED BY public.cat_discapacidad.id_dis;


--
-- Name: cat_grado_dependencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_grado_dependencia (
    id_gra_dep integer NOT NULL,
    descripcion character varying(100) NOT NULL
);


ALTER TABLE public.cat_grado_dependencia OWNER TO postgres;

--
-- Name: cat_grado_dependencia_id_gra_dep_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_grado_dependencia_id_gra_dep_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_grado_dependencia_id_gra_dep_seq OWNER TO postgres;

--
-- Name: cat_grado_dependencia_id_gra_dep_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_grado_dependencia_id_gra_dep_seq OWNED BY public.cat_grado_dependencia.id_gra_dep;


--
-- Name: cat_lengua; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_lengua (
    id_len integer NOT NULL,
    nombre character varying(100) NOT NULL,
    es_indigena boolean DEFAULT true
);


ALTER TABLE public.cat_lengua OWNER TO postgres;

--
-- Name: cat_lengua_id_len_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_lengua_id_len_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_lengua_id_len_seq OWNER TO postgres;

--
-- Name: cat_lengua_id_len_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_lengua_id_len_seq OWNED BY public.cat_lengua.id_len;


--
-- Name: cat_lengua_inali; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_lengua_inali (
    id_lengua integer NOT NULL,
    nombre character varying(100) NOT NULL,
    es_indigena boolean DEFAULT true
);


ALTER TABLE public.cat_lengua_inali OWNER TO postgres;

--
-- Name: cat_lengua_inali_id_lengua_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_lengua_inali_id_lengua_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_lengua_inali_id_lengua_seq OWNER TO postgres;

--
-- Name: cat_lengua_inali_id_lengua_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_lengua_inali_id_lengua_seq OWNED BY public.cat_lengua_inali.id_lengua;


--
-- Name: cat_modo_adquisicion_lengua; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_modo_adquisicion_lengua (
    id_mod_adc integer NOT NULL,
    descripcion character varying(100) NOT NULL
);


ALTER TABLE public.cat_modo_adquisicion_lengua OWNER TO postgres;

--
-- Name: cat_modo_adquisicion_lengua_id_mod_adc_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_modo_adquisicion_lengua_id_mod_adc_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_modo_adquisicion_lengua_id_mod_adc_seq OWNER TO postgres;

--
-- Name: cat_modo_adquisicion_lengua_id_mod_adc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_modo_adquisicion_lengua_id_mod_adc_seq OWNED BY public.cat_modo_adquisicion_lengua.id_mod_adc;


--
-- Name: cat_nacionalidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_nacionalidad (
    id_nac integer NOT NULL,
    nombre character varying(100) NOT NULL
);


ALTER TABLE public.cat_nacionalidad OWNER TO postgres;

--
-- Name: cat_nacionalidad_id_nac_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_nacionalidad_id_nac_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_nacionalidad_id_nac_seq OWNER TO postgres;

--
-- Name: cat_nacionalidad_id_nac_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_nacionalidad_id_nac_seq OWNED BY public.cat_nacionalidad.id_nac;


--
-- Name: cat_nivel_competencia_oral; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_nivel_competencia_oral (
    id_niv_com integer NOT NULL,
    descripcion character varying(100) NOT NULL
);


ALTER TABLE public.cat_nivel_competencia_oral OWNER TO postgres;

--
-- Name: cat_nivel_competencia_oral_id_niv_com_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_nivel_competencia_oral_id_niv_com_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_nivel_competencia_oral_id_niv_com_seq OWNER TO postgres;

--
-- Name: cat_nivel_competencia_oral_id_niv_com_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_nivel_competencia_oral_id_niv_com_seq OWNED BY public.cat_nivel_competencia_oral.id_niv_com;


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
-- Name: cat_sexo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_sexo (
    id_sexo integer NOT NULL,
    nombre character varying(50) NOT NULL
);


ALTER TABLE public.cat_sexo OWNER TO postgres;

--
-- Name: cat_sexo_id_sexo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_sexo_id_sexo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_sexo_id_sexo_seq OWNER TO postgres;

--
-- Name: cat_sexo_id_sexo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_sexo_id_sexo_seq OWNED BY public.cat_sexo.id_sexo;


--
-- Name: cat_tipo_contacto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_tipo_contacto (
    id_tipo_con integer NOT NULL,
    nombre character varying(100) NOT NULL
);


ALTER TABLE public.cat_tipo_contacto OWNER TO postgres;

--
-- Name: cat_tipo_contacto_id_tipo_con_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_tipo_contacto_id_tipo_con_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_tipo_contacto_id_tipo_con_seq OWNER TO postgres;

--
-- Name: cat_tipo_contacto_id_tipo_con_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_tipo_contacto_id_tipo_con_seq OWNED BY public.cat_tipo_contacto.id_tipo_con;


--
-- Name: contacto_nna; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacto_nna (
    id_contacto integer NOT NULL,
    id_nna integer NOT NULL,
    id_tipo_con integer NOT NULL,
    text_con character varying(200) NOT NULL,
    desc_con character varying(200)
);


ALTER TABLE public.contacto_nna OWNER TO postgres;

--
-- Name: contacto_nna_id_contacto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contacto_nna_id_contacto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacto_nna_id_contacto_seq OWNER TO postgres;

--
-- Name: contacto_nna_id_contacto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contacto_nna_id_contacto_seq OWNED BY public.contacto_nna.id_contacto;


--
-- Name: direccion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.direccion (
    id_dir integer NOT NULL,
    calle_dir character varying(200) NOT NULL,
    no_int_dir character varying(200),
    no_ext_dir character varying(200),
    id_asen integer NOT NULL,
    ref_dir character varying(200)
);


ALTER TABLE public.direccion OWNER TO postgres;

--
-- Name: direccion_id_dir_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.direccion_id_dir_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.direccion_id_dir_seq OWNER TO postgres;

--
-- Name: direccion_id_dir_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.direccion_id_dir_seq OWNED BY public.direccion.id_dir;


--
-- Name: entidad_federativa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entidad_federativa (
    id_ent integer NOT NULL,
    nom_ent character varying(200) NOT NULL
);


ALTER TABLE public.entidad_federativa OWNER TO postgres;

--
-- Name: entidad_federativa_id_ent_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.entidad_federativa_id_ent_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entidad_federativa_id_ent_seq OWNER TO postgres;

--
-- Name: entidad_federativa_id_ent_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.entidad_federativa_id_ent_seq OWNED BY public.entidad_federativa.id_ent;


--
-- Name: lenguaje_nna; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lenguaje_nna (
    id_nna integer NOT NULL,
    id_len integer NOT NULL,
    id_niv_com integer,
    id_mod_adc integer,
    preferente_len_nna boolean DEFAULT false NOT NULL,
    autodenom_len_nna character varying(200)
);


ALTER TABLE public.lenguaje_nna OWNER TO postgres;

--
-- Name: nacionalidad_nna; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nacionalidad_nna (
    id_nna integer NOT NULL,
    id_nac integer NOT NULL
);


ALTER TABLE public.nacionalidad_nna OWNER TO postgres;

--
-- Name: nna; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nna (
    id_nna integer NOT NULL,
    folio_nna character varying(10) NOT NULL,
    nom_nna character varying(200) NOT NULL,
    prim_ap_nna character varying(200) NOT NULL,
    seg_ap_nna character varying(200),
    nacim_nna date NOT NULL,
    curp_nna character varying(18) NOT NULL,
    id_sexo integer NOT NULL,
    dir_actual integer,
    luga_nac_nna integer
);


ALTER TABLE public.nna OWNER TO postgres;

--
-- Name: nna_discapacidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nna_discapacidad (
    id_nna integer NOT NULL,
    id_dis integer NOT NULL,
    id_gra_dep integer,
    diagnost_dis boolean DEFAULT false NOT NULL
);


ALTER TABLE public.nna_discapacidad OWNER TO postgres;

--
-- Name: nna_id_nna_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nna_id_nna_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nna_id_nna_seq OWNER TO postgres;

--
-- Name: nna_id_nna_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nna_id_nna_seq OWNED BY public.nna.id_nna;


--
-- Name: nna_tutor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nna_tutor (
    id_nna integer NOT NULL,
    id_tutor integer NOT NULL
);


ALTER TABLE public.nna_tutor OWNER TO postgres;

--
-- Name: personal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal (
    id_personal integer NOT NULL,
    rfc character varying(13) NOT NULL,
    curp character varying(18) NOT NULL,
    correo character varying(150) NOT NULL,
    contrasena text NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    id_rol integer NOT NULL,
    nom_personal character varying(200) NOT NULL,
    prim_ap_personal character varying(200) NOT NULL,
    seg_ap_personal character varying(200)
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
-- Name: tutor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tutor (
    id_tutor integer NOT NULL,
    nom_tutor character varying(200) NOT NULL,
    prim_ap_tutor character varying(200) NOT NULL,
    seg_ap_tutor character varying(200),
    curp_tutor character varying(18) NOT NULL
);


ALTER TABLE public.tutor OWNER TO postgres;

--
-- Name: tutor_id_tutor_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tutor_id_tutor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tutor_id_tutor_seq OWNER TO postgres;

--
-- Name: tutor_id_tutor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tutor_id_tutor_seq OWNED BY public.tutor.id_tutor;


--
-- Name: asentamiento id_asen; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asentamiento ALTER COLUMN id_asen SET DEFAULT nextval('public.asentamiento_id_asen_seq'::regclass);


--
-- Name: cat_cie_bloque id_bloque; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_bloque ALTER COLUMN id_bloque SET DEFAULT nextval('public.cat_cie_bloque_id_bloque_seq'::regclass);


--
-- Name: cat_cie_capitulo id_capitulo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_capitulo ALTER COLUMN id_capitulo SET DEFAULT nextval('public.cat_cie_capitulo_id_capitulo_seq'::regclass);


--
-- Name: cat_cie_categoria id_categoria; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_categoria ALTER COLUMN id_categoria SET DEFAULT nextval('public.cat_cie_categoria_id_categoria_seq'::regclass);


--
-- Name: cat_cie_subcategoria id_subcategoria; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_subcategoria ALTER COLUMN id_subcategoria SET DEFAULT nextval('public.cat_cie_subcategoria_id_subcategoria_seq'::regclass);


--
-- Name: cat_discapacidad id_dis; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_discapacidad ALTER COLUMN id_dis SET DEFAULT nextval('public.cat_discapacidad_id_dis_seq'::regclass);


--
-- Name: cat_grado_dependencia id_gra_dep; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_grado_dependencia ALTER COLUMN id_gra_dep SET DEFAULT nextval('public.cat_grado_dependencia_id_gra_dep_seq'::regclass);


--
-- Name: cat_lengua id_len; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_lengua ALTER COLUMN id_len SET DEFAULT nextval('public.cat_lengua_id_len_seq'::regclass);


--
-- Name: cat_lengua_inali id_lengua; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_lengua_inali ALTER COLUMN id_lengua SET DEFAULT nextval('public.cat_lengua_inali_id_lengua_seq'::regclass);


--
-- Name: cat_modo_adquisicion_lengua id_mod_adc; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_modo_adquisicion_lengua ALTER COLUMN id_mod_adc SET DEFAULT nextval('public.cat_modo_adquisicion_lengua_id_mod_adc_seq'::regclass);


--
-- Name: cat_nacionalidad id_nac; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_nacionalidad ALTER COLUMN id_nac SET DEFAULT nextval('public.cat_nacionalidad_id_nac_seq'::regclass);


--
-- Name: cat_nivel_competencia_oral id_niv_com; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_nivel_competencia_oral ALTER COLUMN id_niv_com SET DEFAULT nextval('public.cat_nivel_competencia_oral_id_niv_com_seq'::regclass);


--
-- Name: cat_roles id_rol; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_roles ALTER COLUMN id_rol SET DEFAULT nextval('public.cat_roles_id_rol_seq'::regclass);


--
-- Name: cat_sexo id_sexo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_sexo ALTER COLUMN id_sexo SET DEFAULT nextval('public.cat_sexo_id_sexo_seq'::regclass);


--
-- Name: cat_tipo_contacto id_tipo_con; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_tipo_contacto ALTER COLUMN id_tipo_con SET DEFAULT nextval('public.cat_tipo_contacto_id_tipo_con_seq'::regclass);


--
-- Name: contacto_nna id_contacto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacto_nna ALTER COLUMN id_contacto SET DEFAULT nextval('public.contacto_nna_id_contacto_seq'::regclass);


--
-- Name: direccion id_dir; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direccion ALTER COLUMN id_dir SET DEFAULT nextval('public.direccion_id_dir_seq'::regclass);


--
-- Name: entidad_federativa id_ent; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entidad_federativa ALTER COLUMN id_ent SET DEFAULT nextval('public.entidad_federativa_id_ent_seq'::regclass);


--
-- Name: nna id_nna; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna ALTER COLUMN id_nna SET DEFAULT nextval('public.nna_id_nna_seq'::regclass);


--
-- Name: personal id_personal; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal ALTER COLUMN id_personal SET DEFAULT nextval('public.personal_id_personal_seq'::regclass);


--
-- Name: tutor id_tutor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tutor ALTER COLUMN id_tutor SET DEFAULT nextval('public.tutor_id_tutor_seq'::regclass);


--
-- Name: asentamiento asentamiento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asentamiento
    ADD CONSTRAINT asentamiento_pkey PRIMARY KEY (id_asen);


--
-- Name: cat_cie_bloque cat_cie_bloque_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_bloque
    ADD CONSTRAINT cat_cie_bloque_pkey PRIMARY KEY (id_bloque);


--
-- Name: cat_cie_capitulo cat_cie_capitulo_codigo_romano_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_capitulo
    ADD CONSTRAINT cat_cie_capitulo_codigo_romano_key UNIQUE (codigo_romano);


--
-- Name: cat_cie_capitulo cat_cie_capitulo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_capitulo
    ADD CONSTRAINT cat_cie_capitulo_pkey PRIMARY KEY (id_capitulo);


--
-- Name: cat_cie_categoria cat_cie_categoria_codigo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_categoria
    ADD CONSTRAINT cat_cie_categoria_codigo_key UNIQUE (codigo);


--
-- Name: cat_cie_categoria cat_cie_categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_categoria
    ADD CONSTRAINT cat_cie_categoria_pkey PRIMARY KEY (id_categoria);


--
-- Name: cat_cie_subcategoria cat_cie_subcategoria_codigo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_subcategoria
    ADD CONSTRAINT cat_cie_subcategoria_codigo_key UNIQUE (codigo);


--
-- Name: cat_cie_subcategoria cat_cie_subcategoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_subcategoria
    ADD CONSTRAINT cat_cie_subcategoria_pkey PRIMARY KEY (id_subcategoria);


--
-- Name: cat_discapacidad cat_discapacidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_discapacidad
    ADD CONSTRAINT cat_discapacidad_pkey PRIMARY KEY (id_dis);


--
-- Name: cat_grado_dependencia cat_grado_dependencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_grado_dependencia
    ADD CONSTRAINT cat_grado_dependencia_pkey PRIMARY KEY (id_gra_dep);


--
-- Name: cat_lengua_inali cat_lengua_inali_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_lengua_inali
    ADD CONSTRAINT cat_lengua_inali_pkey PRIMARY KEY (id_lengua);


--
-- Name: cat_lengua cat_lengua_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_lengua
    ADD CONSTRAINT cat_lengua_pkey PRIMARY KEY (id_len);


--
-- Name: cat_modo_adquisicion_lengua cat_modo_adquisicion_lengua_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_modo_adquisicion_lengua
    ADD CONSTRAINT cat_modo_adquisicion_lengua_pkey PRIMARY KEY (id_mod_adc);


--
-- Name: cat_nacionalidad cat_nacionalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_nacionalidad
    ADD CONSTRAINT cat_nacionalidad_pkey PRIMARY KEY (id_nac);


--
-- Name: cat_nivel_competencia_oral cat_nivel_competencia_oral_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_nivel_competencia_oral
    ADD CONSTRAINT cat_nivel_competencia_oral_pkey PRIMARY KEY (id_niv_com);


--
-- Name: cat_roles cat_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_roles
    ADD CONSTRAINT cat_roles_pkey PRIMARY KEY (id_rol);


--
-- Name: cat_sexo cat_sexo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_sexo
    ADD CONSTRAINT cat_sexo_pkey PRIMARY KEY (id_sexo);


--
-- Name: cat_tipo_contacto cat_tipo_contacto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_tipo_contacto
    ADD CONSTRAINT cat_tipo_contacto_pkey PRIMARY KEY (id_tipo_con);


--
-- Name: contacto_nna contacto_nna_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacto_nna
    ADD CONSTRAINT contacto_nna_pkey PRIMARY KEY (id_contacto);


--
-- Name: direccion direccion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direccion
    ADD CONSTRAINT direccion_pkey PRIMARY KEY (id_dir);


--
-- Name: entidad_federativa entidad_federativa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entidad_federativa
    ADD CONSTRAINT entidad_federativa_pkey PRIMARY KEY (id_ent);


--
-- Name: lenguaje_nna lenguaje_nna_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lenguaje_nna
    ADD CONSTRAINT lenguaje_nna_pkey PRIMARY KEY (id_nna, id_len);


--
-- Name: nacionalidad_nna nacionalidad_nna_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nacionalidad_nna
    ADD CONSTRAINT nacionalidad_nna_pkey PRIMARY KEY (id_nna, id_nac);


--
-- Name: nna nna_curp_nna_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna
    ADD CONSTRAINT nna_curp_nna_key UNIQUE (curp_nna);


--
-- Name: nna_discapacidad nna_discapacidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna_discapacidad
    ADD CONSTRAINT nna_discapacidad_pkey PRIMARY KEY (id_nna, id_dis);


--
-- Name: nna nna_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna
    ADD CONSTRAINT nna_pkey PRIMARY KEY (id_nna);


--
-- Name: nna_tutor nna_tutor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna_tutor
    ADD CONSTRAINT nna_tutor_pkey PRIMARY KEY (id_nna, id_tutor);


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
-- Name: tutor tutor_curp_tutor_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tutor
    ADD CONSTRAINT tutor_curp_tutor_key UNIQUE (curp_tutor);


--
-- Name: tutor tutor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tutor
    ADD CONSTRAINT tutor_pkey PRIMARY KEY (id_tutor);


--
-- Name: asentamiento asentamiento_id_ent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asentamiento
    ADD CONSTRAINT asentamiento_id_ent_fkey FOREIGN KEY (id_ent) REFERENCES public.entidad_federativa(id_ent);


--
-- Name: cat_cie_bloque cat_cie_bloque_id_capitulo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_bloque
    ADD CONSTRAINT cat_cie_bloque_id_capitulo_fkey FOREIGN KEY (id_capitulo) REFERENCES public.cat_cie_capitulo(id_capitulo) ON DELETE RESTRICT;


--
-- Name: cat_cie_categoria cat_cie_categoria_id_bloque_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_categoria
    ADD CONSTRAINT cat_cie_categoria_id_bloque_fkey FOREIGN KEY (id_bloque) REFERENCES public.cat_cie_bloque(id_bloque) ON DELETE RESTRICT;


--
-- Name: cat_cie_subcategoria cat_cie_subcategoria_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie_subcategoria
    ADD CONSTRAINT cat_cie_subcategoria_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.cat_cie_categoria(id_categoria) ON DELETE RESTRICT;


--
-- Name: contacto_nna contacto_nna_id_nna_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacto_nna
    ADD CONSTRAINT contacto_nna_id_nna_fkey FOREIGN KEY (id_nna) REFERENCES public.nna(id_nna) ON DELETE CASCADE;


--
-- Name: contacto_nna contacto_nna_id_tipo_con_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacto_nna
    ADD CONSTRAINT contacto_nna_id_tipo_con_fkey FOREIGN KEY (id_tipo_con) REFERENCES public.cat_tipo_contacto(id_tipo_con);


--
-- Name: direccion direccion_id_asen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direccion
    ADD CONSTRAINT direccion_id_asen_fkey FOREIGN KEY (id_asen) REFERENCES public.asentamiento(id_asen);


--
-- Name: personal fk_personal_rol; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT fk_personal_rol FOREIGN KEY (id_rol) REFERENCES public.cat_roles(id_rol) ON DELETE RESTRICT;


--
-- Name: lenguaje_nna lenguaje_nna_id_len_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lenguaje_nna
    ADD CONSTRAINT lenguaje_nna_id_len_fkey FOREIGN KEY (id_len) REFERENCES public.cat_lengua(id_len);


--
-- Name: lenguaje_nna lenguaje_nna_id_mod_adc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lenguaje_nna
    ADD CONSTRAINT lenguaje_nna_id_mod_adc_fkey FOREIGN KEY (id_mod_adc) REFERENCES public.cat_modo_adquisicion_lengua(id_mod_adc);


--
-- Name: lenguaje_nna lenguaje_nna_id_niv_com_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lenguaje_nna
    ADD CONSTRAINT lenguaje_nna_id_niv_com_fkey FOREIGN KEY (id_niv_com) REFERENCES public.cat_nivel_competencia_oral(id_niv_com);


--
-- Name: lenguaje_nna lenguaje_nna_id_nna_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lenguaje_nna
    ADD CONSTRAINT lenguaje_nna_id_nna_fkey FOREIGN KEY (id_nna) REFERENCES public.nna(id_nna) ON DELETE CASCADE;


--
-- Name: nacionalidad_nna nacionalidad_nna_id_nac_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nacionalidad_nna
    ADD CONSTRAINT nacionalidad_nna_id_nac_fkey FOREIGN KEY (id_nac) REFERENCES public.cat_nacionalidad(id_nac) ON DELETE CASCADE;


--
-- Name: nacionalidad_nna nacionalidad_nna_id_nna_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nacionalidad_nna
    ADD CONSTRAINT nacionalidad_nna_id_nna_fkey FOREIGN KEY (id_nna) REFERENCES public.nna(id_nna) ON DELETE CASCADE;


--
-- Name: nna nna_dir_actual_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna
    ADD CONSTRAINT nna_dir_actual_fkey FOREIGN KEY (dir_actual) REFERENCES public.direccion(id_dir);


--
-- Name: nna_discapacidad nna_discapacidad_id_dis_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna_discapacidad
    ADD CONSTRAINT nna_discapacidad_id_dis_fkey FOREIGN KEY (id_dis) REFERENCES public.cat_discapacidad(id_dis);


--
-- Name: nna_discapacidad nna_discapacidad_id_gra_dep_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna_discapacidad
    ADD CONSTRAINT nna_discapacidad_id_gra_dep_fkey FOREIGN KEY (id_gra_dep) REFERENCES public.cat_grado_dependencia(id_gra_dep);


--
-- Name: nna_discapacidad nna_discapacidad_id_nna_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna_discapacidad
    ADD CONSTRAINT nna_discapacidad_id_nna_fkey FOREIGN KEY (id_nna) REFERENCES public.nna(id_nna) ON DELETE CASCADE;


--
-- Name: nna nna_id_sexo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna
    ADD CONSTRAINT nna_id_sexo_fkey FOREIGN KEY (id_sexo) REFERENCES public.cat_sexo(id_sexo);


--
-- Name: nna nna_luga_nac_nna_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna
    ADD CONSTRAINT nna_luga_nac_nna_fkey FOREIGN KEY (luga_nac_nna) REFERENCES public.entidad_federativa(id_ent);


--
-- Name: nna_tutor nna_tutor_id_nna_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna_tutor
    ADD CONSTRAINT nna_tutor_id_nna_fkey FOREIGN KEY (id_nna) REFERENCES public.nna(id_nna) ON DELETE CASCADE;


--
-- Name: nna_tutor nna_tutor_id_tutor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nna_tutor
    ADD CONSTRAINT nna_tutor_id_tutor_fkey FOREIGN KEY (id_tutor) REFERENCES public.tutor(id_tutor) ON DELETE CASCADE;


--
-- Name: TABLE cat_roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cat_roles TO rnpi_user;


--
-- Name: TABLE personal; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.personal TO rnpi_user;


--
-- PostgreSQL database dump complete
--

\unrestrict ScEhOtV9HVBc0njxh7WmWUS4qLynbDSGD1dmPwGCB9lFLjdaxabgJIuFOWgic6R

