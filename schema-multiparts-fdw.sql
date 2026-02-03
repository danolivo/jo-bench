--
-- Create partitioned tables with foreign table partitions in 'job_fdw' database
-- connecting to partition tables in 'job' database.
--
-- Uses incoming parameter :p, set by -vp=NN to identify which number of parts
-- to create.
--
-- Prerequisites: Run schema-multiparts.sql in 'job' database first to create
-- the actual partition tables.
--
-- Copyright (c) 2024 - 2026 Andrei Lepikhov
--

BEGIN;

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER loopback FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
  dbname 'job', use_remote_estimate  'on',
  fdw_startup_cost '1.0',
  fdw_tuple_cost '0.001');
CREATE USER MAPPING FOR CURRENT_USER SERVER loopback;

-- Helper function to create foreign table partitions for a partitioned table
CREATE OR REPLACE FUNCTION build__foreign_hashed_parts(tblname name, parts integer)
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
  i integer;
BEGIN
  FOR i IN 0..parts-1
  LOOP
    EXECUTE format(
      'CREATE FOREIGN TABLE %I_part_%s PARTITION OF %I FOR VALUES WITH (modulus %s, remainder %s) SERVER loopback OPTIONS (table_name ''%s_part_%s'');',
      tblname, i, tblname, parts, i, tblname, i);
  END LOOP;
END $$;

-- Non-partitioned tables as simple foreign tables
CREATE FOREIGN TABLE aka_name (
  id            integer NOT NULL,
  person_id     integer NOT NULL,
  name          text NOT NULL,
  imdb_index    character varying(12),
  name_pcode_cf character varying(5),
  name_pcode_nf character varying(5),
  surname_pcode character varying(5),
  md5sum        character varying(32)
) SERVER loopback OPTIONS (table_name 'aka_name');

CREATE FOREIGN TABLE aka_title (
  id              integer NOT NULL,
  movie_id        integer NOT NULL,
  title           text NOT NULL,
  imdb_index      character varying(12),
  kind_id         integer NOT NULL,
  production_year integer,
  phonetic_code   character varying(5),
  episode_of_id   integer,
  season_nr       integer,
  episode_nr      integer,
  note            text,
  md5sum          character varying(32)
) SERVER loopback OPTIONS (table_name 'aka_title');

-- Partitioned table: cast_info
CREATE TABLE cast_info (
  id             integer NOT NULL,
  person_id      integer NOT NULL,
  movie_id       integer NOT NULL,
  person_role_id integer,
  note           text,
  nr_order       integer,
  role_id        integer NOT NULL
) PARTITION BY HASH (id);
SELECT build__foreign_hashed_parts('cast_info'::name, :p);

-- Partitioned table: char_name
CREATE TABLE char_name (
  id            integer NOT NULL,
  name          text NOT NULL,
  imdb_index    character varying(12),
  imdb_id       integer,
  name_pcode_nf character varying(5),
  surname_pcode character varying(5),
  md5sum        character varying(32)
) PARTITION BY HASH (id);
SELECT build__foreign_hashed_parts('char_name'::name, :p);

-- Non-partitioned tables as simple foreign tables
CREATE FOREIGN TABLE comp_cast_type (
  id   integer NOT NULL,
  kind character varying(32) NOT NULL
) SERVER loopback OPTIONS (table_name 'comp_cast_type');

CREATE FOREIGN TABLE company_name (
  id            integer NOT NULL,
  name          text NOT NULL,
  country_code  character varying(255),
  imdb_id       integer,
  name_pcode_nf character varying(5),
  name_pcode_sf character varying(5),
  md5sum        character varying(32)
) SERVER loopback OPTIONS (table_name 'company_name');

CREATE FOREIGN TABLE company_type (
  id   integer NOT NULL,
  kind character varying(32) NOT NULL
) SERVER loopback OPTIONS (table_name 'company_type');

CREATE FOREIGN TABLE complete_cast (
  id         integer NOT NULL,
  movie_id   integer,
  subject_id integer NOT NULL,
  status_id  integer NOT NULL
) SERVER loopback OPTIONS (table_name 'complete_cast');

CREATE FOREIGN TABLE info_type (
  id   integer NOT NULL,
  info character varying(32) NOT NULL
) SERVER loopback OPTIONS (table_name 'info_type');

CREATE FOREIGN TABLE keyword (
  id            integer NOT NULL,
  keyword       text NOT NULL,
  phonetic_code character varying(5)
) SERVER loopback OPTIONS (table_name 'keyword');

CREATE FOREIGN TABLE kind_type (
  id   integer NOT NULL,
  kind character varying(15) NOT NULL
) SERVER loopback OPTIONS (table_name 'kind_type');

CREATE FOREIGN TABLE link_type (
  id   integer NOT NULL,
  link character varying(32) NOT NULL
) SERVER loopback OPTIONS (table_name 'link_type');

CREATE FOREIGN TABLE movie_companies (
  id              integer NOT NULL,
  movie_id        integer NOT NULL,
  company_id      integer NOT NULL,
  company_type_id integer NOT NULL,
  note            text
) SERVER loopback OPTIONS (table_name 'movie_companies');

-- Partitioned table: movie_info
CREATE TABLE movie_info (
  id           integer NOT NULL,
  movie_id     integer NOT NULL,
  info_type_id integer NOT NULL,
  info         text NOT NULL,
  note         text
) PARTITION BY HASH (id);
SELECT build__foreign_hashed_parts('movie_info'::name, :p);

CREATE FOREIGN TABLE movie_info_idx (
  id           integer NOT NULL,
  movie_id     integer NOT NULL,
  info_type_id integer NOT NULL,
  info         text NOT NULL,
  note         text
) SERVER loopback OPTIONS (table_name 'movie_info_idx');

CREATE FOREIGN TABLE movie_keyword (
  id         integer NOT NULL,
  movie_id   integer NOT NULL,
  keyword_id integer NOT NULL
) SERVER loopback OPTIONS (table_name 'movie_keyword');

CREATE FOREIGN TABLE movie_link (
  id              integer NOT NULL,
  movie_id        integer NOT NULL,
  linked_movie_id integer NOT NULL,
  link_type_id    integer NOT NULL
) SERVER loopback OPTIONS (table_name 'movie_link');

-- Partitioned table: name
CREATE TABLE name (
  id            integer NOT NULL,
  name          text NOT NULL,
  imdb_index    character varying(12),
  imdb_id       integer,
  gender        character varying(1),
  name_pcode_cf character varying(5),
  name_pcode_nf character varying(5),
  surname_pcode character varying(5),
  md5sum        character varying(32)
) PARTITION BY HASH (id);
SELECT build__foreign_hashed_parts('name'::name, :p);

-- Partitioned table: person_info
CREATE TABLE person_info (
  id           integer NOT NULL,
  person_id    integer NOT NULL,
  info_type_id integer NOT NULL,
  info         text NOT NULL,
  note         text
) PARTITION BY HASH (id);
SELECT build__foreign_hashed_parts('person_info'::name, :p);

CREATE FOREIGN TABLE role_type (
  id   integer NOT NULL,
  role character varying(32) NOT NULL
) SERVER loopback OPTIONS (table_name 'role_type');

-- Partitioned table: title
CREATE TABLE title (
  id              integer NOT NULL,
  title           text NOT NULL,
  imdb_index      character varying(12),
  kind_id         integer NOT NULL,
  production_year integer,
  imdb_id         integer,
  phonetic_code   character varying(5),
  episode_of_id   integer,
  season_nr       integer,
  episode_nr      integer,
  series_years    character varying(49),
  md5sum          character varying(32)
) PARTITION BY HASH (id);
SELECT build__foreign_hashed_parts('title'::name, :p);

DROP FUNCTION build__foreign_hashed_parts;
COMMIT;

ANALYZE aka_name,aka_title,cast_info,char_name,comp_cast_type,
  company_name,company_type,complete_cast,info_type,keyword,kind_type,link_type,
  movie_companies,movie_info,movie_info_idx,movie_keyword,movie_link,name,
  person_info,role_type,title;

-- Check we have statistic
SELECT tablename FROM pg_stats WHERE schemaname = 'public'
GROUP BY tablename;
