/*
 * Script for dividing large csv files into smaller buckets.
 */

/* Tables: 21 items */

-- Check size of large tables:
SELECT sum(size) FROM (
	SELECT count(*) AS size FROM movie_info
	UNION ALL
	SELECT count(*) AS size FROM title
	UNION ALL
	SELECT count(*) AS size FROM person_info
	UNION ALL
	SELECT count(*) AS size FROM name
	UNION ALL
	SELECT count(*) AS size FROM char_name
	UNION ALL
	SELECT count(*) AS size FROM cast_info
) AS q1;

/* sum: 63879870 */

--
-- PARAMETERS:
--
-- tblname -
-- order_colname -
-- parts - Number of partitions where we want to split the table into
CREATE OR REPLACE FUNCTION partition(tblname text, order_colname text, parts integer) RETURNS bool
language plpgsql AS $$
DECLARE
	i		integer;
	ntuples	bigint;
	bsize	bigint;
	pos		bigint;
BEGIN
	EXECUTE format('SELECT count(*) FROM %s;', tblname) INTO ntuples;
	bsize = ntuples / parts + 1;
	pos = 0;
	raise NOTICE 'Start COPY into % parts, order by %, ntuples: %, block size: %.',
				tblname, order_colname, ntuples, bsize;

	FOR i IN 1..parts
	LOOP
    	raise NOTICE 'part % ntuples: %, pos: %', i, ntuples, pos;
		-- Create table as a part of the relation data

		EXECUTE format(
      	'COPY (
			SELECT * FROM %I ORDER BY (%I) OFFSET %s FETCH NEXT %s ROWS ONLY
		) TO ''/home/user/imdb/%s_%s.csv''
		WITH (FORMAT csv, NULL '''', DELIMITER '','', QUOTE ''"'', ESCAPE ''\'', ENCODING 'WIN1251')
		;
		', tblname, order_colname, pos, bsize, tblname, i);
		pos = pos + bsize;
   END LOOP;
   RETURN true;
END $$;

SELECT partition('movie_info', 'movie_id, id', 15);
SELECT partition('title', 'id', 2);
SELECT partition('person_info', 'id', 4);
SELECT partition('name', 'id', 4);
SELECT partition('char_name', 'id', 3);
SELECT partition('cast_info', 'id', 20);

