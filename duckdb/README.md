# Join Order Benchmark on DuckDB

These scripts build a single `job.duckdb` database file from the CSV data in
this repo, mirroring the PostgreSQL deployment (`schema.sql` + `copy.sql`).

## Files

* **`schema.sql`** – creates the 21 benchmark tables (DuckDB dialect).
* **`load.sql`** – loads the CSVs in `../csv/` into those tables. Uses a SQL
  variable `datadir` for absolute paths and globs the pre-chunked large tables
  (e.g. `csv/cast_info/*.csv`). Ends with a row-count sanity check.
* **`load.sh`** – convenience wrapper that runs `schema.sql` then `load.sql`
  against a fresh database file.

## Prerequisites

* Install the [DuckDB CLI](https://duckdb.org/docs/installation/) 

## Quick start

From the repo root:

```
./duckdb/load.sh
```

This creates `job.duckdb` in the current directory.

### Options

```
./duckdb/load.sh [DBFILE] [DATADIR]
```

* `DBFILE`  – output database file (default: `job.duckdb`)
* `DATADIR` – repo root that holds `csv/` (default: the repo root)
* `DUCKDB`  – env var to point at a specific duckdb binary
  (default: `duckdb` on `PATH`)

Example with an explicit binary and output path:

```
DUCKDB=/path/to/duckdb ./duckdb/load.sh /tmp/job.duckdb ~/jo-bench
```

## Verifying the load

`load.sql` finishes by printing the row count of every table, plus a grand
`TOTAL` (which should be **74,190,187**):

```
┌─────────────────┬──────────┐
│   table_name    │   cnt    │
├─────────────────┼──────────┤
│ aka_name        │   901343 │
│ aka_title       │   361472 │
│ cast_info       │ 36244344 │
│ char_name       │  3140339 │
│ comp_cast_type  │        4 │
│ company_name    │   234997 │
│ company_type    │        4 │
│ complete_cast   │   135086 │
│ info_type       │      113 │
│ keyword         │   134170 │
│ kind_type       │        7 │
│ link_type       │       18 │
│ movie_companies │  2609129 │
│ movie_info      │ 14835720 │
│ movie_info_idx  │  1380035 │
│ movie_keyword   │  4523930 │
│ movie_link      │    29997 │
│ name            │  4167491 │
│ person_info     │  2963664 │
│ role_type       │       12 │
│ title           │  2528312 │
│ TOTAL           │ 74190187 │
└─────────────────┴──────────┘
```

## Running the benchmark queries

The query files in `../queries/` are plain SQL and run unmodified:

```
duckdb job.duckdb < queries/1a.sql
```

To time a query, prefix it with DuckDB's profiler, e.g.:

```
duckdb job.duckdb \
  -c "PRAGMA enable_profiling='no_output';" \
  -c ".read queries/1a.sql"
```

## Notes

* **CSV dialect.** The CSVs use Postgres-style backslash escaping (`\"` inside
  quoted fields) and empty unquoted fields for NULL. `load.sql` matches this with
  `escape='\'`, `quote='"'`, `delim=','`, `nullstr=''`, `header=false`. Columns
  are read as text (`all_varchar=true`) and cast to the schema types on insert,
  which keeps parsing deterministic.
* **Primary keys.** `schema.sql` keeps the `PRIMARY KEY` constraints from the
  PostgreSQL schema. They build an index during load; if you only care about
  load speed you can remove them.