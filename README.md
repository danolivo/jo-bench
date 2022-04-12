# join-order-benchmark

This repository is a fork of the [project](https://github.com/gregrahn/join-order-benchmark).
Here we unite queries and data in one place.
Main goal of this repository is simplifying of the deploy process.

Large tables divided into chunks each less than 100 MB.

Repository contains some scripts for quick deploy of the benchmark:
* schema.sql - creates the data schema.
* copy.sql - copies data from csv files into the tables. Uses `datadir` variable to make absolute paths to csv files. Use `psql -v` to define it.
* parts.sql - script which splitted the tables. Just for future reusage.

Example below shows export procedure of all tables:

```
psql -f ~/join-order-benchmark/schema.sql
psql -vdatadir="'/home/user/join-order-benchmark'" -f ~/join-order-benchmark/copy.sql
```

