# join-order-benchmark

This repository is a fork of the [project](https://github.com/gregrahn/join-order-benchmark).
Here, we unite queries and data in one place.
The main goal of this repository is to simplify the deployment process.

Large tables are divided into chunks, each less than 100 MB.

The repository contains some scripts for quick deployment & run of the benchmark:
* *schema.sql* - creates the data schema.
* *copy.sql* - copies data from CSV files into the tables. Uses the `datadir` variable to make absolute paths to CSV files. Use `psql -v` to define it.
* *parts.sql* - script that has split the tables. Just for future usage.
* *job* - a template script for a quick launch of the benchmark.

Also, you can take a quick look into the `scripts` folder for examples of benchmarking scripts. They are not ideal, as my recent experiments [have shown](https://danolivo.substack.com/p/looking-for-hidden-hurdles-when-postgres?r=34q1yy), but can help in putting away some unnecessary slips.

The example below shows an export procedure for all tables:

```
psql -f ~/jo-bench/schema.sql
psql -vdatadir="'$HOME/jo-bench'" -f ~/jo-bench/copy.sql
```

NB! Deploying tested on database with C-locale.

## Partitioning case
To perform the same tests over partitioned into two partitions by HASH versions of the tables, use file schema-hashedparts.sql:

```
psql -f ~/jo-bench/schema-hashedparts.sql
psql -vdatadir="'$HOME/jo-bench'" -f ~/jo-bench/copy.sql
```

It creates additional schema 'parts' in the database and sets search_path to this schema, so you will see tables from this schema.
Fill these tables with data the same way as in the non-partitioned case.

In case you want to vary the number of partitions and apply it only for top-6 most sizeable tables use another script:
```
psql -vp=<NN> -f ~/jo-bench/schema-multiparts.sql
```
Here NN - number of partitions you want to have on each big table. These tables will be created in the schema 'multiparts', the `search_path` will be altered to reference directly this schema.

# Notes on Postgres instance settings
These settings shold be set into something like that:
```
from_collapse_limit = 20
join_collapse_limit = 20
min_parallel_table_scan_size = 0
min_parallel_index_scan_size = 0
default_statistics_target = 1000
```
Keep in mind that for certain join numbers, the standard planner may switch to GEQO. You might need to adjust the `geqo_threshold` parameter to ensure that the same planner is used during benchmarking.

If you want to discover effects of parallel workers, intensify their usage:
```
echo "max_parallel_workers = 32" >> $PGDATA/postgresql.conf
echo "parallel_setup_cost = 0.1" >> $PGDATA/postgresql.conf
echo "parallel_tuple_cost = 0.0001" >> $PGDATA/postgresql.conf
```
