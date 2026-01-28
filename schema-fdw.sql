/*
 * NOTES:
 * - No indexes, even primary keys
 * - Reduce FDW cost due to socket loopback interface
 */
 
BEGIN;

CREATE EXTENSION postgres_fdw;

CREATE SERVER loopback FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
  dbname 'job', use_remote_estimate  'on',
  fdw_startup_cost '1.0',
  fdw_tuple_cost '0.001');
CREATE USER MAPPING FOR CURRENT_USER SERVER loopback;

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

CREATE FOREIGN TABLE cast_info (
    id             integer NOT NULL,
    person_id      integer NOT NULL,
    movie_id       integer NOT NULL,
    person_role_id integer,
    note           text,
    nr_order       integer,
    role_id        integer NOT NULL
) SERVER loopback OPTIONS (table_name 'cast_info');

CREATE FOREIGN TABLE char_name (
    id            integer NOT NULL,
    name          text NOT NULL,
    imdb_index    character varying(12),
    imdb_id       integer,
    name_pcode_nf character varying(5),
    surname_pcode character varying(5),
    md5sum        character varying(32)
) SERVER loopback OPTIONS (table_name 'char_name');

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

CREATE FOREIGN TABLE movie_info (
    id           integer NOT NULL,
    movie_id     integer NOT NULL,
    info_type_id integer NOT NULL,
    info         text NOT NULL,
    note         text
) SERVER loopback OPTIONS (table_name 'movie_info');

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

CREATE FOREIGN TABLE name (
    id            integer NOT NULL,
    name          text NOT NULL,
    imdb_index    character varying(12),
    imdb_id       integer,
    gender        character varying(1),
    name_pcode_cf character varying(5),
    name_pcode_nf character varying(5),
    surname_pcode character varying(5),
    md5sum        character varying(32)
) SERVER loopback OPTIONS (table_name 'name');

CREATE FOREIGN TABLE person_info (
    id           integer NOT NULL,
    person_id    integer NOT NULL,
    info_type_id integer NOT NULL,
    info         text NOT NULL,
    note         text
) SERVER loopback OPTIONS (table_name 'person_info');

CREATE FOREIGN TABLE role_type (
    id   integer NOT NULL,
    role character varying(32) NOT NULL
) SERVER loopback OPTIONS (table_name 'role_type');

CREATE FOREIGN TABLE title (
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
) SERVER loopback OPTIONS (table_name 'title');

COMMIT;

ANALYZE aka_name,aka_title,cast_info,char_name,comp_cast_type,
  company_name,company_type,complete_cast,info_type,keyword,kind_type,link_type,
  movie_companies,movie_info,movie_info_idx,movie_keyword,movie_link,name,
  person_info,role_type,title;

-- Check we have statistic
SELECT tablename FROM pg_stats WHERE schemaname = 'public'
GROUP BY tablename;
