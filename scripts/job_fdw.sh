#!/bin/bash
# ##############################################################################
#
# Make one pass of the Join Order Benchmark over a PostgreSQL instance.
# Tables are FDW representations of tables, placed in a different database.
#
# Copyright (c) 2024 - 2026 Andrei Lepikhov
#
# ##############################################################################

# We anticipate statement timeouts here
#set -euo pipefail

ulimit -c unlimited

PGDATABASE="job_fdw"
export PGDATABASE=$PGDATABASE

seqno=1
RESULT_FILE="pass-$PGDATABASE.res"
EXPLAIN_FILE="explains-$PGDATABASE.res"

echo "The Join Order Benchmark 1Pass test ..."

# Print header to console and file
printf "%-6s %-20s %s\n" "SeqNo" "Query" "Time (ms)"
printf "%-6s %-20s %s\n" "SeqNo" "Query" "Time (ms)" > "$RESULT_FILE"

# Clear explains file
> "$EXPLAIN_FILE"

for file in ${HOME}/queries/*.sql
do
  query_name=$(basename "$file")

  # Build EXPLAIN ANALYZE query
  echo -n "/* $query_name */ EXPLAIN (ANALYZE) " > test.sql
  cat "$file" >> test.sql

  # Run query and capture output
  result=$(psql -f test.sql 2>&1)

  # Save full explain to explains file
  echo "=== $seqno: $query_name ===" >> "$EXPLAIN_FILE"
  echo "$result" >> "$EXPLAIN_FILE"
  echo "" >> "$EXPLAIN_FILE"

  # Extract execution time from EXPLAIN ANALYZE output
  exec_time=$(echo "$result" | grep -oP 'Execution Time: \K[0-9.]+')

  # If no execution time found, mark as error
  if [ -z "$exec_time" ]; then
    exec_time="ERROR"
  fi

  # Print to console and file
  printf "%-6d %-20s %s\n" "$seqno" "$query_name" "$exec_time"
  printf "%-6d %-20s %s\n" "$seqno" "$query_name" "$exec_time" >> "$RESULT_FILE"

  seqno=$((seqno+1))
done

echo "Results saved to $RESULT_FILE"
echo "Explains saved to $EXPLAIN_FILE"
