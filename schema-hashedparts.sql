BEGIN;

CREATE SCHEMA parts;
SET search_path TO 'parts';

CREATE TABLE aka_name (
  id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL,
  name text NOT NULL,
  imdb_index character varying(12),
  name_pcode_cf character varying(5),
  name_pcode_nf character varying(5),
  surname_pcode character varying(5),
  md5sum character varying(32)
) PARTITION BY HASH (id);
CREATE TABLE aka_name_p1 PARTITION OF aka_name FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE aka_name_p2 PARTITION OF aka_name FOR VALUES WITH (modulus 2, remainder 1);

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
) PARTITION BY HASH (id);
CREATE TABLE aka_title_p1 PARTITION OF aka_title FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE aka_title_p2 PARTITION OF aka_title FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE cast_info (
  id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL,
  movie_id integer NOT NULL,
  person_role_id integer,
  note text,
  nr_order integer,
  role_id integer NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE cast_info_p1 PARTITION OF cast_info FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE cast_info_p2 PARTITION OF cast_info FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE char_name (
  id integer NOT NULL PRIMARY KEY,
  name text NOT NULL,
  imdb_index character varying(12),
  imdb_id integer,
  name_pcode_nf character varying(5),
  surname_pcode character varying(5),
  md5sum character varying(32)
) PARTITION BY HASH (id);
CREATE TABLE char_name_p1 PARTITION OF char_name FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE char_name_p2 PARTITION OF char_name FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE comp_cast_type (
  id integer NOT NULL PRIMARY KEY,
  kind character varying(32) NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE comp_cast_type_p1 PARTITION OF comp_cast_type FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE comp_cast_type_p2 PARTITION OF comp_cast_type FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE company_name (
  id integer NOT NULL PRIMARY KEY,
  name text NOT NULL,
  country_code character varying(255),
  imdb_id integer,
  name_pcode_nf character varying(5),
  name_pcode_sf character varying(5),
  md5sum character varying(32)
) PARTITION BY HASH (id);
CREATE TABLE company_name_p1 PARTITION OF company_name FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE company_name_p2 PARTITION OF company_name FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE company_type (
  id integer NOT NULL PRIMARY KEY,
  kind character varying(32) NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE company_type_p1 PARTITION OF company_type FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE company_type_p2 PARTITION OF company_type FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE complete_cast (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer,
  subject_id integer NOT NULL,
  status_id integer NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE complete_cast_p1 PARTITION OF complete_cast FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE complete_cast_p2 PARTITION OF complete_cast FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE info_type (
  id integer NOT NULL PRIMARY KEY,
  info character varying(32) NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE info_type_p1 PARTITION OF info_type FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE info_type_p2 PARTITION OF info_type FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE keyword (
  id integer NOT NULL PRIMARY KEY,
  keyword text NOT NULL,
  phonetic_code character varying(5)
) PARTITION BY HASH (id);
CREATE TABLE keyword_p1 PARTITION OF keyword FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE keyword_p2 PARTITION OF keyword FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE kind_type (
  id integer NOT NULL PRIMARY KEY,
  kind character varying(15) NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE kind_type_p1 PARTITION OF kind_type FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE kind_type_p2 PARTITION OF kind_type FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE link_type (
  id integer NOT NULL PRIMARY KEY,
  link character varying(32) NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE link_type_p1 PARTITION OF link_type FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE link_type_p2 PARTITION OF link_type FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE movie_companies (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer NOT NULL,
  company_id integer NOT NULL,
  company_type_id integer NOT NULL,
  note text
) PARTITION BY HASH (id);
CREATE TABLE movie_companies_p1 PARTITION OF movie_companies FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE movie_companies_p2 PARTITION OF movie_companies FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE movie_info (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer NOT NULL,
  info_type_id integer NOT NULL,
  info text NOT NULL,
  note text
) PARTITION BY HASH (id);
CREATE TABLE movie_info_p1 PARTITION OF movie_info FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE movie_info_p2 PARTITION OF movie_info FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE movie_info_idx (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer NOT NULL,
  info_type_id integer NOT NULL,
  info text NOT NULL,
  note text
) PARTITION BY HASH (id);
CREATE TABLE movie_info_idx_p1 PARTITION OF movie_info_idx FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE movie_info_idx_p2 PARTITION OF movie_info_idx FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE movie_keyword (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer NOT NULL,
  keyword_id integer NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE movie_keyword_p1 PARTITION OF movie_keyword FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE movie_keyword_p2 PARTITION OF movie_keyword FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE movie_link (
  id integer NOT NULL PRIMARY KEY,
  movie_id integer NOT NULL,
  linked_movie_id integer NOT NULL,
  link_type_id integer NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE movie_link_p1 PARTITION OF movie_link FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE movie_link_p2 PARTITION OF movie_link FOR VALUES WITH (modulus 2, remainder 1);

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
CREATE TABLE name_p1 PARTITION OF name FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE name_p2 PARTITION OF name FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE person_info (
  id integer NOT NULL PRIMARY KEY,
  person_id integer NOT NULL,
  info_type_id integer NOT NULL,
  info text NOT NULL,
  note text
) PARTITION BY HASH (id);
CREATE TABLE person_info_p1 PARTITION OF person_info FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE person_info_p2 PARTITION OF person_info FOR VALUES WITH (modulus 2, remainder 1);

CREATE TABLE role_type (
  id integer NOT NULL PRIMARY KEY,
  role character varying(32) NOT NULL
) PARTITION BY HASH (id);
CREATE TABLE role_type_p1 PARTITION OF role_type FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE role_type_p2 PARTITION OF role_type FOR VALUES WITH (modulus 2, remainder 1);

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
CREATE TABLE title_p1 PARTITION OF title FOR VALUES WITH (modulus 2, remainder 0);
CREATE TABLE title_p2 PARTITION OF title FOR VALUES WITH (modulus 2, remainder 1);

COMMIT;

ALTER SYSTEM SET search_path TO 'parts';
SELECT pg_reload_conf();

