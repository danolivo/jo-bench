#!/bin/bash
#
# Build a DuckDB database for the Join Order Benchmark from the CSV files.
#
# Usage:
#   ./duckdb/load.sh [DBFILE] [DATADIR]
#
#   DBFILE   output database file   (default: ./job.duckdb)
#   DATADIR  repo root holding csv/ (default: the repo root, i.e. this
#            script's parent directory)
#
# The duckdb CLI is taken from $DUCKDB, or `duckdb` on PATH:
#   DUCKDB=/path/to/duckdb ./duckdb/load.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DBFILE="${1:-job.duckdb}"
DATADIR="${2:-$(cd "$SCRIPT_DIR/.." && pwd)}"
DUCKDB="${DUCKDB:-duckdb}"

if [ ! -d "$DATADIR/csv" ]; then
    echo "error: $DATADIR/csv not found (pass DATADIR as the 2nd argument)" >&2
    exit 1
fi

echo "Building $DBFILE from $DATADIR/csv ..."
rm -f "$DBFILE"

{
    echo "SET VARIABLE datadir='$DATADIR';"
    cat "$SCRIPT_DIR/schema.sql"
    cat "$SCRIPT_DIR/load.sql"
} | "$DUCKDB" "$DBFILE"

echo "Done. Database written to $DBFILE"
