--
-- Join Order Benchmark schema for DuckDB.
-- Translated 1:1 from the PostgreSQL schema.sql
-- (integer -> INTEGER, text / character varying(n) -> VARCHAR).
--

CREATE TABLE aka_name (
    id integer NOT NULL PRIMARY KEY,
    person_id integer NOT NULL,
    name varchar NOT NULL,
    imdb_index varchar,
    name_pcode_cf varchar,
    name_pcode_nf varchar,
    surname_pcode varchar,
    md5sum varchar
);

CREATE TABLE aka_title (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    title varchar NOT NULL,
    imdb_index varchar,
    kind_id integer NOT NULL,
    production_year integer,
    phonetic_code varchar,
    episode_of_id integer,
    season_nr integer,
    episode_nr integer,
    note varchar,
    md5sum varchar
);

CREATE TABLE cast_info (
    id integer NOT NULL PRIMARY KEY,
    person_id integer NOT NULL,
    movie_id integer NOT NULL,
    person_role_id integer,
    note varchar,
    nr_order integer,
    role_id integer NOT NULL
);

CREATE TABLE char_name (
    id integer NOT NULL PRIMARY KEY,
    name varchar NOT NULL,
    imdb_index varchar,
    imdb_id integer,
    name_pcode_nf varchar,
    surname_pcode varchar,
    md5sum varchar
);

CREATE TABLE comp_cast_type (
    id integer NOT NULL PRIMARY KEY,
    kind varchar NOT NULL
);

CREATE TABLE company_name (
    id integer NOT NULL PRIMARY KEY,
    name varchar NOT NULL,
    country_code varchar,
    imdb_id integer,
    name_pcode_nf varchar,
    name_pcode_sf varchar,
    md5sum varchar
);

CREATE TABLE company_type (
    id integer NOT NULL PRIMARY KEY,
    kind varchar NOT NULL
);

CREATE TABLE complete_cast (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer,
    subject_id integer NOT NULL,
    status_id integer NOT NULL
);

CREATE TABLE info_type (
    id integer NOT NULL PRIMARY KEY,
    info varchar NOT NULL
);

CREATE TABLE keyword (
    id integer NOT NULL PRIMARY KEY,
    keyword varchar NOT NULL,
    phonetic_code varchar
);

CREATE TABLE kind_type (
    id integer NOT NULL PRIMARY KEY,
    kind varchar NOT NULL
);

CREATE TABLE link_type (
    id integer NOT NULL PRIMARY KEY,
    link varchar NOT NULL
);

CREATE TABLE movie_companies (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    company_id integer NOT NULL,
    company_type_id integer NOT NULL,
    note varchar
);

CREATE TABLE movie_info (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    info_type_id integer NOT NULL,
    info varchar NOT NULL,
    note varchar
);

CREATE TABLE movie_info_idx (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    info_type_id integer NOT NULL,
    info varchar NOT NULL,
    note varchar
);

CREATE TABLE movie_keyword (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    keyword_id integer NOT NULL
);

CREATE TABLE movie_link (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    linked_movie_id integer NOT NULL,
    link_type_id integer NOT NULL
);

CREATE TABLE name (
    id integer NOT NULL PRIMARY KEY,
    name varchar NOT NULL,
    imdb_index varchar,
    imdb_id integer,
    gender varchar,
    name_pcode_cf varchar,
    name_pcode_nf varchar,
    surname_pcode varchar,
    md5sum varchar
);

CREATE TABLE person_info (
    id integer NOT NULL PRIMARY KEY,
    person_id integer NOT NULL,
    info_type_id integer NOT NULL,
    info varchar NOT NULL,
    note varchar
);

CREATE TABLE role_type (
    id integer NOT NULL PRIMARY KEY,
    role varchar NOT NULL
);

CREATE TABLE title (
    id integer NOT NULL PRIMARY KEY,
    title varchar NOT NULL,
    imdb_index varchar,
    kind_id integer NOT NULL,
    production_year integer,
    imdb_id integer,
    phonetic_code varchar,
    episode_of_id integer,
    season_nr integer,
    episode_nr integer,
    series_years varchar,
    md5sum varchar
);
