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
Here NN - number of partitions you want to have on each big table. These tables will be created in the schema 'multiparts', search_path altered to reference directly this schema.
