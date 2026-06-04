--
-- Load the Join Order Benchmark CSV data into DuckDB.
-- Large tables are pre-chunked under csv/<table>/ and loaded with a glob.
--

CREATE OR REPLACE MACRO read_job_csv(path) AS TABLE
    SELECT * FROM read_csv(path,
        header = false,
        all_varchar = true,   -- parse everything as text; cast on INSERT
        delim = ',',
        quote = '"',
        escape = '\',
        nullstr = '');        -- empty field -> NULL (matches Postgres NULL '')

-- Single-file tables
INSERT INTO aka_title      SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/aka_title.csv');
INSERT INTO aka_name       SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/aka_name.csv');
INSERT INTO comp_cast_type SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/comp_cast_type.csv');
INSERT INTO company_name   SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/company_name.csv');
INSERT INTO company_type   SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/company_type.csv');
INSERT INTO complete_cast  SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/complete_cast.csv');
INSERT INTO info_type      SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/info_type.csv');
INSERT INTO keyword        SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/keyword.csv');
INSERT INTO kind_type      SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/kind_type.csv');
INSERT INTO link_type      SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/link_type.csv');
INSERT INTO movie_companies SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/movie_companies.csv');
INSERT INTO movie_info_idx SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/movie_info_idx.csv');
INSERT INTO movie_keyword  SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/movie_keyword.csv');
INSERT INTO movie_link     SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/movie_link.csv');
INSERT INTO role_type      SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/role_type.csv');

-- Large tables, pre-chunked under csv/<table>/ (loaded via glob)
INSERT INTO movie_info  SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/movie_info/*.csv');
INSERT INTO title       SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/title/*.csv');
INSERT INTO person_info SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/person_info/*.csv');
INSERT INTO name        SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/name/*.csv');
INSERT INTO char_name   SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/char_name/*.csv');
INSERT INTO cast_info   SELECT * FROM read_job_csv(getvariable('datadir') || '/csv/cast_info/*.csv');

DROP MACRO read_job_csv;

-- Sanity check: row count of every table (and the grand total)
SELECT table_name, cnt FROM (
  SELECT table_name, cnt FROM (
    SELECT 'aka_name' AS table_name, count(*) AS cnt FROM aka_name
    UNION ALL SELECT 'aka_title', count(*) FROM aka_title
    UNION ALL SELECT 'cast_info', count(*) FROM cast_info
    UNION ALL SELECT 'char_name', count(*) FROM char_name
    UNION ALL SELECT 'comp_cast_type', count(*) FROM comp_cast_type
    UNION ALL SELECT 'company_name', count(*) FROM company_name
    UNION ALL SELECT 'company_type', count(*) FROM company_type
    UNION ALL SELECT 'complete_cast', count(*) FROM complete_cast
    UNION ALL SELECT 'info_type', count(*) FROM info_type
    UNION ALL SELECT 'keyword', count(*) FROM keyword
    UNION ALL SELECT 'kind_type', count(*) FROM kind_type
    UNION ALL SELECT 'link_type', count(*) FROM link_type
    UNION ALL SELECT 'movie_companies', count(*) FROM movie_companies
    UNION ALL SELECT 'movie_info', count(*) FROM movie_info
    UNION ALL SELECT 'movie_info_idx', count(*) FROM movie_info_idx
    UNION ALL SELECT 'movie_keyword', count(*) FROM movie_keyword
    UNION ALL SELECT 'movie_link', count(*) FROM movie_link
    UNION ALL SELECT 'name', count(*) FROM name
    UNION ALL SELECT 'person_info', count(*) FROM person_info
    UNION ALL SELECT 'role_type', count(*) FROM role_type
    UNION ALL SELECT 'title', count(*) FROM title
  )
  UNION ALL SELECT 'TOTAL', sum(cnt) FROM (
    SELECT count(*) AS cnt FROM aka_name
    UNION ALL SELECT count(*) FROM aka_title
    UNION ALL SELECT count(*) FROM cast_info
    UNION ALL SELECT count(*) FROM char_name
    UNION ALL SELECT count(*) FROM comp_cast_type
    UNION ALL SELECT count(*) FROM company_name
    UNION ALL SELECT count(*) FROM company_type
    UNION ALL SELECT count(*) FROM complete_cast
    UNION ALL SELECT count(*) FROM info_type
    UNION ALL SELECT count(*) FROM keyword
    UNION ALL SELECT count(*) FROM kind_type
    UNION ALL SELECT count(*) FROM link_type
    UNION ALL SELECT count(*) FROM movie_companies
    UNION ALL SELECT count(*) FROM movie_info
    UNION ALL SELECT count(*) FROM movie_info_idx
    UNION ALL SELECT count(*) FROM movie_keyword
    UNION ALL SELECT count(*) FROM movie_link
    UNION ALL SELECT count(*) FROM name
    UNION ALL SELECT count(*) FROM person_info
    UNION ALL SELECT count(*) FROM role_type
    UNION ALL SELECT count(*) FROM title
  )
)
ORDER BY (table_name = 'TOTAL'), table_name;
