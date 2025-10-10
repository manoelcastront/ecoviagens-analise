-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler version: 1.1.3
-- PostgreSQL version: 16.0
-- Project Site: pgmodeler.io
-- Model Author: ---

-- Database creation must be performed outside a multi lined SQL file. 
-- These commands were put in this file only as a convenience.
-- 
-- object: ecoviagens | type: DATABASE --
-- DROP DATABASE IF EXISTS ecoviagens;
CREATE DATABASE ecoviagens;
-- ddl-end --


-- object: ecoviagens | type: SCHEMA --
-- DROP SCHEMA IF EXISTS ecoviagens CASCADE;
CREATE SCHEMA ecoviagens;
-- ddl-end --
ALTER SCHEMA ecoviagens OWNER TO postgres;
-- ddl-end --

SET search_path TO pg_catalog,public,ecoviagens;
-- ddl-end --

-- object: ecoviagens.cliente | type: TABLE --
-- DROP TABLE IF EXISTS ecoviagens.cliente CASCADE;
CREATE TABLE ecoviagens.cliente (
	id_cliente integer NOT NULL,
	nome varchar(100) NOT NULL,
	email varchar(150) NOT NULL,
	data_nascimento date NOT NULL,
	genero varchar(10) NOT NULL,
	localidade varchar(100) NOT NULL,
	CONSTRAINT id_cliente PRIMARY KEY (id_cliente),
	CONSTRAINT email_uq UNIQUE (email),
	CONSTRAINT genero CHECK (genero IN ('Masculino', 'Feminino'))
);
-- ddl-end --
ALTER TABLE ecoviagens.cliente OWNER TO postgres;
-- ddl-end --

-- object: ecoviagens.operador | type: TABLE --
-- DROP TABLE IF EXISTS ecoviagens.operador CASCADE;
CREATE TABLE ecoviagens.operador (
	id_operador integer NOT NULL,
	nome varchar(100) NOT NULL,
	cnpj varchar(18) NOT NULL,
	contato varchar(20) NOT NULL,
	email varchar(150) NOT NULL,
	localidade varchar(100) NOT NULL,
	CONSTRAINT id_operador PRIMARY KEY (id_operador),
	CONSTRAINT cnpj_uq UNIQUE (cnpj),
	CONSTRAINT email UNIQUE (email),
	CONSTRAINT contato UNIQUE (contato),
	CONSTRAINT cnpj_ck CHECK (cnpj ~ '^[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}-[0-9]{2}$')
);
-- ddl-end --
ALTER TABLE ecoviagens.operador OWNER TO postgres;
-- ddl-end --

-- object: ecoviagens.oferta | type: TABLE --
-- DROP TABLE IF EXISTS ecoviagens.oferta CASCADE;
CREATE TABLE ecoviagens.oferta (
	id_oferta integer NOT NULL,
	tipo_oferta varchar NOT NULL,
	titulo varchar(100) NOT NULL,
	descricao text NOT NULL,
	preco decimal(10,2) NOT NULL,
	id_operador integer,
	CONSTRAINT id_oferta PRIMARY KEY (id_oferta),
	CONSTRAINT tipo_oferta CHECK (tipo_oferta IN ('Atividade', 'Hospedagem'))
);
-- ddl-end --
ALTER TABLE ecoviagens.oferta OWNER TO postgres;
-- ddl-end --

-- object: ecoviagens.atividade | type: TABLE --
-- DROP TABLE IF EXISTS ecoviagens.atividade CASCADE;
CREATE TABLE ecoviagens.atividade (
	id_oferta integer NOT NULL,
	nivel_dificuldade varchar NOT NULL,
	duracao interval HOUR  NOT NULL,
	grupo_maximo integer NOT NULL,
	CONSTRAINT id_oferta_pk_atv PRIMARY KEY (id_oferta),
	CONSTRAINT nivel_dificuldade CHECK (nivel_dificuldade IN ('Fácil', 'Médio', 'Difícil'))
);
-- ddl-end --
ALTER TABLE ecoviagens.atividade OWNER TO postgres;
-- ddl-end --

-- object: ecoviagens.hospedagem | type: TABLE --
-- DROP TABLE IF EXISTS ecoviagens.hospedagem CASCADE;
CREATE TABLE ecoviagens.hospedagem (
	id_oferta integer NOT NULL,
	tipo_acomodacao varchar(50) NOT NULL,
	capacidade integer NOT NULL,
	possui_cafe_manha boolean NOT NULL,
	CONSTRAINT id_oferta_pk_hpd PRIMARY KEY (id_oferta)
);
-- ddl-end --
ALTER TABLE ecoviagens.hospedagem OWNER TO postgres;
-- ddl-end --

-- object: ecoviagens.reserva | type: TABLE --
-- DROP TABLE IF EXISTS ecoviagens.reserva CASCADE;
CREATE TABLE ecoviagens.reserva (
	id_reserva integer NOT NULL,
	id_cliente integer,
	id_oferta integer,
	data_reserva date NOT NULL,
	data_experiencia date NOT NULL,
	qtd_pessoas integer NOT NULL,
	status varchar NOT NULL,
	CONSTRAINT id_reserva PRIMARY KEY (id_reserva),
	CONSTRAINT status CHECK (status IN ('Confirmada', 'Cancelada', 'Concluída'))
);
-- ddl-end --
ALTER TABLE ecoviagens.reserva OWNER TO postgres;
-- ddl-end --

-- object: ecoviagens.avaliacao | type: TABLE --
-- DROP TABLE IF EXISTS ecoviagens.avaliacao CASCADE;
CREATE TABLE ecoviagens.avaliacao (
	id_avaliacao integer NOT NULL,
	id_cliente integer,
	id_oferta integer,
	nota integer NOT NULL,
	comentario text,
	data_avaliacao date NOT NULL,
	CONSTRAINT id_avaliacao PRIMARY KEY (id_avaliacao)
);
-- ddl-end --
ALTER TABLE ecoviagens.avaliacao OWNER TO postgres;
-- ddl-end --

-- object: ecoviagens.pratica_sustentavel | type: TABLE --
-- DROP TABLE IF EXISTS ecoviagens.pratica_sustentavel CASCADE;
CREATE TABLE ecoviagens.pratica_sustentavel (
	id_pratica integer NOT NULL,
	descricao varchar(100) NOT NULL,
	CONSTRAINT id_pratica PRIMARY KEY (id_pratica)
);
-- ddl-end --
ALTER TABLE ecoviagens.pratica_sustentavel OWNER TO postgres;
-- ddl-end --

-- object: ecoviagens.oferta_pratica | type: TABLE --
-- DROP TABLE IF EXISTS ecoviagens.oferta_pratica CASCADE;
CREATE TABLE ecoviagens.oferta_pratica (
	id_oferta integer NOT NULL,
	id_pratica integer NOT NULL,
	CONSTRAINT id_oferta_pratica PRIMARY KEY (id_oferta,id_pratica)
);
-- ddl-end --
ALTER TABLE ecoviagens.oferta_pratica OWNER TO postgres;
-- ddl-end --

-- object: id_operador | type: CONSTRAINT --
-- ALTER TABLE ecoviagens.oferta DROP CONSTRAINT IF EXISTS id_operador CASCADE;
ALTER TABLE ecoviagens.oferta ADD CONSTRAINT id_operador FOREIGN KEY (id_operador)
REFERENCES ecoviagens.operador (id_operador) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: id_oferta_fk_atv | type: CONSTRAINT --
-- ALTER TABLE ecoviagens.atividade DROP CONSTRAINT IF EXISTS id_oferta_fk_atv CASCADE;
ALTER TABLE ecoviagens.atividade ADD CONSTRAINT id_oferta_fk_atv FOREIGN KEY (id_oferta)
REFERENCES ecoviagens.oferta (id_oferta) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: id_oferta_fk_hpd | type: CONSTRAINT --
-- ALTER TABLE ecoviagens.hospedagem DROP CONSTRAINT IF EXISTS id_oferta_fk_hpd CASCADE;
ALTER TABLE ecoviagens.hospedagem ADD CONSTRAINT id_oferta_fk_hpd FOREIGN KEY (id_oferta)
REFERENCES ecoviagens.oferta (id_oferta) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: id_cliente | type: CONSTRAINT --
-- ALTER TABLE ecoviagens.reserva DROP CONSTRAINT IF EXISTS id_cliente CASCADE;
ALTER TABLE ecoviagens.reserva ADD CONSTRAINT id_cliente FOREIGN KEY (id_cliente)
REFERENCES ecoviagens.cliente (id_cliente) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: id_oferta | type: CONSTRAINT --
-- ALTER TABLE ecoviagens.reserva DROP CONSTRAINT IF EXISTS id_oferta CASCADE;
ALTER TABLE ecoviagens.reserva ADD CONSTRAINT id_oferta FOREIGN KEY (id_oferta)
REFERENCES ecoviagens.oferta (id_oferta) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: id_cliente | type: CONSTRAINT --
-- ALTER TABLE ecoviagens.avaliacao DROP CONSTRAINT IF EXISTS id_cliente CASCADE;
ALTER TABLE ecoviagens.avaliacao ADD CONSTRAINT id_cliente FOREIGN KEY (id_cliente)
REFERENCES ecoviagens.cliente (id_cliente) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: id_oferta | type: CONSTRAINT --
-- ALTER TABLE ecoviagens.avaliacao DROP CONSTRAINT IF EXISTS id_oferta CASCADE;
ALTER TABLE ecoviagens.avaliacao ADD CONSTRAINT id_oferta FOREIGN KEY (id_oferta)
REFERENCES ecoviagens.oferta (id_oferta) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: id_oferta | type: CONSTRAINT --
-- ALTER TABLE ecoviagens.oferta_pratica DROP CONSTRAINT IF EXISTS id_oferta CASCADE;
ALTER TABLE ecoviagens.oferta_pratica ADD CONSTRAINT id_oferta FOREIGN KEY (id_oferta)
REFERENCES ecoviagens.oferta (id_oferta) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: id_pratica | type: CONSTRAINT --
-- ALTER TABLE ecoviagens.oferta_pratica DROP CONSTRAINT IF EXISTS id_pratica CASCADE;
ALTER TABLE ecoviagens.oferta_pratica ADD CONSTRAINT id_pratica FOREIGN KEY (id_pratica)
REFERENCES ecoviagens.pratica_sustentavel (id_pratica) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --


