--
-- Build multiple hashed partitions on large tables.
--
-- Uses incoming parameter :p, set by -vp=NN to identify which number of parts
-- to create.
--
-- Copyright (c) 2024 Andrei Lepikhov
--

BEGIN;

CREATE SCHEMA multiparts;
SET search_path TO 'multiparts';

CREATE OR REPLACE FUNCTION build__hashed_parts(tblname name, parts integer)
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
	full_path text;
	i integer;
BEGIN
	FOR i IN 0..parts-1
		LOOP
			EXECUTE format('CREATE TABLE %I_part_%s PARTITION OF %I FOR VALUES WITH (modulus %s, remainder %s);',
						   tblname, i, tblname, parts, i);
			-- '
		END LOOP;
END $$;

CREATE TABLE aka_name (
  id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL,
  name text NOT NULL,
  imdb_index character varying(12),
  name_pcode_cf character varying(5),
  name_pcode_nf character varying(5),
  surname_pcode character varying(5),
  md5sum character varying(32)
);

CREATE TABLE aka_title (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer NOT NULL,
  title text NOT NULL,
  imdb_index character varying(12),
  kind_id integer NOT NULL,
  production_year integer,
  phonetic_code character varying(5),
  episode_of_id integer,
  season_nr integer,
  episode_nr integer,
  note text,
  md5sum character varying(32)
);

CREATE TABLE cast_info (
  id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL,
  movie_id integer NOT NULL,
  person_role_id integer,
  note text,
  nr_order integer,
  role_id integer NOT NULL
) PARTITION BY HASH (id);
SELECT build__hashed_parts('cast_info'::name, :p);

CREATE TABLE char_name (
  id integer NOT NULL PRIMARY KEY,
  name text NOT NULL,
  imdb_index character varying(12),
  imdb_id integer,
  name_pcode_nf character varying(5),
  surname_pcode character varying(5),
  md5sum character varying(32)
) PARTITION BY HASH (id);
SELECT build__hashed_parts('char_name'::name, :p);

CREATE TABLE comp_cast_type (
  id integer NOT NULL PRIMARY KEY,
  kind character varying(32) NOT NULL
);

CREATE TABLE company_name (
  id integer NOT NULL PRIMARY KEY,
  name text NOT NULL,
  country_code character varying(255),
  imdb_id integer,
  name_pcode_nf character varying(5),
  name_pcode_sf character varying(5),
  md5sum character varying(32)
);

CREATE TABLE company_type (
  id integer NOT NULL PRIMARY KEY,
  kind character varying(32) NOT NULL
);

CREATE TABLE complete_cast (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer,
  subject_id integer NOT NULL,
  status_id integer NOT NULL
);

CREATE TABLE info_type (
  id integer NOT NULL PRIMARY KEY,
  info character varying(32) NOT NULL
);

CREATE TABLE keyword (
  id integer NOT NULL PRIMARY KEY,
  keyword text NOT NULL,
  phonetic_code character varying(5)
);

CREATE TABLE kind_type (
  id integer NOT NULL PRIMARY KEY,
  kind character varying(15) NOT NULL
);

CREATE TABLE link_type (
  id integer NOT NULL PRIMARY KEY,
  link character varying(32) NOT NULL
);

CREATE TABLE movie_companies (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer NOT NULL,
  company_id integer NOT NULL,
  company_type_id integer NOT NULL,
  note text
);

CREATE TABLE movie_info (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer NOT NULL,
  info_type_id integer NOT NULL,
  info text NOT NULL,
  note text
) PARTITION BY HASH (id);
SELECT build__hashed_parts('movie_info'::name, :p);

CREATE TABLE movie_info_idx (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer NOT NULL,
  info_type_id integer NOT NULL,
  info text NOT NULL,
  note text
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
  name text NOT NULL,
  imdb_index character varying(12),
  imdb_id integer,
  gender character varying(1),
  name_pcode_cf character varying(5),
  name_pcode_nf character varying(5),
  surname_pcode character varying(5),
  md5sum character varying(32)
) PARTITION BY HASH (id);
SELECT build__hashed_parts('name'::name, :p);

CREATE TABLE person_info (
  id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL,
  info_type_id integer NOT NULL,
  info text NOT NULL,
  note text
) PARTITION BY HASH (id);
SELECT build__hashed_parts('person_info'::name, :p);

CREATE TABLE role_type (
  id integer NOT NULL PRIMARY KEY,
  role character varying(32) NOT NULL
);

CREATE TABLE title (
  id integer NOT NULL PRIMARY KEY,
  title text NOT NULL,
  imdb_index character varying(12),
  kind_id integer NOT NULL,
  production_year integer,
  imdb_id integer,
  phonetic_code character varying(5),
  episode_of_id integer,
  season_nr integer,
  episode_nr integer,
  series_years character varying(49),
  md5sum character varying(32)
) PARTITION BY HASH (id);
SELECT build__hashed_parts('title'::name, :p);

DROP FUNCTION build__hashed_parts;
COMMIT;

ALTER SYSTEM SET search_path TO 'multiparts';
SELECT pg_reload_conf();

