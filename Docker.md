# PostgreSQL 18 Docker Image

A minimal Docker image for building and running PostgreSQL 18 from source with pre-loaded JOB (Join Order Benchmark) data.

## Quick Start

```bash
# Build the image
make build

# Run PostgreSQL
make run

# Connect to database (port 5499 to avoid conflicts with local PostgreSQL)
psql -h localhost -p 5499 -U postgres -d job

# Or exec into container
docker exec -it job bash
```

## Building

### Build for current platform

```bash
make build
```

### Build specific branch

```bash
make build POSTGRES_BRANCH=master
make build POSTGRES_BRANCH=REL_18_STABLE
```

### Build for multiple platforms (amd64 + arm64)

```bash
make build-all
```

## Running

### Start container

```bash
make run
```

This creates a container named `job` with:
- Port 5499 exposed on host (maps to container's 5432)
- JOB benchmark data pre-loaded
- PostgreSQL configured with `basic_pgconf.conf` settings

### Stop container

```bash
make stop
```

### View build info

```bash
make info
```

## Container Layout

| Path | Description |
|------|-------------|
| `/home/postgres/postgres` | PostgreSQL source code |
| `/home/postgres/data` | Database data directory (PGDATA) |
| `/home/postgres/cores` | Core dump files |
| `/home/postgres/queries` | JOB benchmark queries |
| `/home/postgres/scripts` | SQL scripts (schema.sql, copy.sql, basic_pgconf.conf) |
| `/usr/local/pgsql` | PostgreSQL binaries |

## Environment Variables

These are set in both the container environment and `/home/postgres/.bashrc`:

| Variable | Value |
|----------|-------|
| `PGDATA` | `/home/postgres/data` |
| `PGUSER` | `postgres` |
| `PGDATABASE` | `job` |
| `PGPORT` | `5432` |
| `PATH` | Includes `/usr/local/pgsql/bin` |

## PostgreSQL Configuration

The image uses settings from `basic_pgconf.conf`:

| Setting | Value |
|---------|-------|
| `shared_buffers` | 1GB |
| `work_mem` | 64MB |
| `join_collapse_limit` | 20 |
| `from_collapse_limit` | 20 |
| `default_statistics_target` | 2500 |
| `max_parallel_workers_per_gather` | 4 |
| `fsync` | off |

## Healthcheck

The container has a built-in healthcheck:
- Runs every 60 seconds
- Uses `pg_isready` to verify PostgreSQL is accepting connections
- 30 second start period for initialization
- Container marked unhealthy after 3 consecutive failures

Check health status:
```bash
docker inspect --format='{{.State.Health.Status}}' job
```

## Enabling Core Dumps

Core dumps are configured to be saved to `/home/postgres/cores/` with the naming pattern `core.<executable>.<pid>.<timestamp>`.

### On Linux

Set the core pattern on the host system:

```bash
echo '/home/postgres/cores/core.%e.%p.%t' | sudo tee /proc/sys/kernel/core_pattern
```

Run with privileged mode and mount a volume for cores:

```bash
docker run -d \
    --name job \
    --privileged \
    -p 5499:5432 \
    -v job-cores:/home/postgres/cores \
    job:REL_18_STABLE
```

### On macOS (Docker Desktop)

Core dumps can be copied from the container and analyzed on a separate Linux (Debian) system:

```bash
# Run container with a volume for cores
docker run -d \
    --name job \
    -p 5499:5432 \
    -v job-cores:/home/postgres/cores \
    job:REL_18_STABLE

# Copy core files from container to host
docker cp job:/home/postgres/cores/. ./cores/

# Copy the postgres binary for debugging
docker cp job:/usr/local/pgsql/bin/postgres ./postgres

# Transfer cores/ and postgres binary to your Debian system
# Then analyze with gdb on the Debian system:
# gdb ./postgres ./cores/core.postgres.123.1234567890
```

### Analyzing core dumps

The image includes gdb. Analyze core files directly in the container:

```bash
docker exec -it job gdb /usr/local/pgsql/bin/postgres /home/postgres/cores/core.postgres.123.1234567890
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make help` | Show available commands |
| `make build` | Build for current platform |
| `make build-all` | Build for amd64 and arm64 |
| `make push` | Push multiplatform image to registry |
| `make run` | Start PostgreSQL container |
| `make stop` | Stop and remove container |
| `make info` | Show image build information |
| `make login` | Login to Docker registry |
| `make clean` | Remove images and build cache |

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_BRANCH` | `REL_18_STABLE` | Git branch to build |
| `IMAGE_NAME` | `job` | Docker image name |
| `USERNAME` | (none) | Docker Hub username |
| `PLATFORMS` | `linux/amd64,linux/arm64` | Target platforms |

## Local Usage

### Using Make (recommended)

```bash
# Build the image
make build

# Start PostgreSQL (JOB data is pre-loaded)
make run

# Stop the container
make stop
```

### Using Docker directly

#### Build the image

```bash
DOCKER_BUILDKIT=1 docker build -t job:REL_18_STABLE .
```

#### Build with a specific branch

```bash
DOCKER_BUILDKIT=1 docker build \
    --build-arg POSTGRES_BRANCH=master \
    -t job:master .
```

#### Run PostgreSQL server

```bash
docker run -d \
    --name job \
    -p 5499:5432 \
    job:REL_18_STABLE
```

#### Run interactive bash shell (with running container)

```bash
docker exec -it job bash
```

#### Run one-off bash session (without starting postgres)

```bash
docker run -it --rm job:REL_18_STABLE bash
```

#### Run psql directly

```bash
# Against running container
docker exec -it job psql -d job

# Or simply (uses PGDATABASE env var)
docker exec -it job psql
```

#### Run a specific SQL file

```bash
# From host
docker exec -i job psql -d job < myquery.sql

# From inside container
docker exec -it job psql -d job -f ~/queries/1a.sql
```

### Connect from host

```bash
# Using psql (if installed on host)
psql -h localhost -p 5499 -U postgres -d job

# Using docker
docker exec -it job psql
```

## Examples

### Custom branch build

```bash
make build POSTGRES_BRANCH=master
```

### Interactive shell in container

```bash
docker exec -it job bash
```

### Run SQL file

```bash
docker exec -i job psql -d job < myquery.sql
```

### View PostgreSQL logs

```bash
# PostgreSQL log file (inside container)
docker exec job tail -f ~/logfile-job.log
```

### Run JOB benchmark queries

```bash
# Run a single query
docker exec -it job psql -d job -f ~/queries/1a.sql

# Run all queries
docker exec -it job bash -c 'for q in ~/queries/*.sql; do echo "=== $q ==="; psql -d job -f "$q"; done'
```

### Run the JOB basic benchmark test

The `job_basic.sh` script runs all JOB queries with EXPLAIN ANALYZE and records execution times.

```bash
# Run the benchmark inside the container
docker exec -it job bash -c 'cd ~ && ~/scripts/job_basic.sh'

# Copy result files to host for analysis
docker cp job:/home/postgres/pass.res ./pass.res
docker cp job:/home/postgres/explains.res ./explains.res
docker cp job:/home/postgres/logfile-job.log ./logfile-job.log
```

Output files:
| File | Description |
|------|-------------|
| `pass.res` | Execution times: SeqNo, Query name, Time (ms) |
| `explains.res` | Full EXPLAIN ANALYZE output for each query |
| `logfile-job.log` | PostgreSQL server log |

**Important:** When running the container for benchmarking, ensure sufficient shared memory:

```bash
docker run -d \
    --name job \
    --shm-size=2g \
    -p 5499:5432 \
    job:REL_18_STABLE
```

The `--shm-size` should be at least as large as `shared_buffers` (default 1GB in this image).
