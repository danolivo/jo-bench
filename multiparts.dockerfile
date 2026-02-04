# syntax=docker/dockerfile:1
#
# multiparts.dockerfile - Join Order Benchmark with partitioned tables
# and FDW foreign table partitions.
#
# job database: schema-multiparts.sql (16 partitions on large tables)
# job_fdw database: schema-multiparts-fdw.sql (partitioned foreign tables)
#
# Copyright (c) 2024 - 2026 Andrei Lepikhov
#

FROM ubuntu:24.04 AS builder

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal build dependencies for PostgreSQL 18
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	gcc \
	make \
	libreadline-dev \
	zlib1g-dev \
	flex \
	bison \
	ca-certificates \
	perl \
	pkg-config \
	libicu-dev \
	git \
	&& rm -rf /var/lib/apt/lists/*

# PostgreSQL branch to build
ARG POSTGRES_BRANCH=REL_18_STABLE

WORKDIR /build

# Clone and build PostgreSQL with BuildKit cache
RUN --mount=type=cache,target=/build/postgres,id=postgres-src \
	if [ ! -d /build/postgres/.git ]; then \
	git clone --branch ${POSTGRES_BRANCH} --single-branch --depth 1 \
	https://git.postgresql.org/git/postgresql.git /build/postgres; \
	else \
	cd /build/postgres && git fetch origin ${POSTGRES_BRANCH} && git checkout FETCH_HEAD; \
	fi && \
	cd /build/postgres && \
	git log -1 --format="%H %ci" > /tmp/pg_commit_info

RUN --mount=type=cache,target=/build/postgres,id=postgres-src \
	--mount=type=cache,target=/build/postgres-build,id=postgres-build \
	cd /build/postgres && \
	./configure --prefix=/usr/local/pgsql \
	--without-icu \
	--without-perl \
	--without-python \
	--without-tcl && \
	make -j$(nproc) && \
	make install DESTDIR=/build/install && \
	cd contrib && \
	make -j$(nproc) && \
	make install DESTDIR=/build/install

# Copy source to install directory
RUN --mount=type=cache,target=/build/postgres,id=postgres-src \
	cp -r /build/postgres /build/install/postgres-src && \
	echo "POSTGRES_COMMIT=$(cd /build/postgres && git rev-parse HEAD)" > /build/install/pg_build_info && \
	echo "POSTGRES_BRANCH=${POSTGRES_BRANCH}" >> /build/install/pg_build_info

# Runtime stage
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies and gdb for debugging
RUN apt-get update && apt-get install -y --no-install-recommends \
	libreadline8 \
	zlib1g \
	locales \
	gdb \
	&& rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG=en_US.UTF-8

# Create postgres user first
RUN useradd -m -s /bin/bash postgres

# Copy PostgreSQL binaries
COPY --from=builder /build/install/usr/local/pgsql /usr/local/pgsql
COPY --from=builder /build/install/pg_build_info /usr/local/pgsql/

# Copy source to postgres home directory
COPY --from=builder --chown=postgres:postgres /build/install/postgres-src /home/postgres/postgres

# Create data and cores directories in postgres home
RUN mkdir -p /home/postgres/data /home/postgres/cores /home/postgres/scripts && \
	chown -R postgres:postgres /home/postgres /usr/local/pgsql

# Copy queries folder, scripts, and config
COPY --chown=postgres:postgres queries/ /home/postgres/queries/
COPY --chown=postgres:postgres copy.sql schema-multiparts.sql schema-multiparts-fdw.sql /home/postgres/scripts/
COPY --chown=postgres:postgres basic_pgconf.conf scripts/job_basic.sh \
	scripts/job_fdw.sh scripts/job_fdw_extra.sh scripts/job_multiparts_fdw.sh \
	/home/postgres/scripts/

# Enable coredumps: set core pattern and unlimited core size
RUN echo 'kernel.core_pattern=/home/postgres/cores/core.%e.%p.%t' >> /etc/sysctl.conf && \
	echo '* soft core unlimited' >> /etc/security/limits.conf && \
	echo '* hard core unlimited' >> /etc/security/limits.conf

# Setup (default) environment in bashrc
RUN echo '' >> /home/postgres/.bashrc && \
	echo '# PostgreSQL environment' >> /home/postgres/.bashrc && \
	echo 'export PATH=/usr/local/pgsql/bin:$PATH' >> /home/postgres/.bashrc && \
	echo 'export PATH=/home/postgres/scripts:$PATH' >> /home/postgres/.bashrc && \
	echo 'export PGDATA=/home/postgres/data' >> /home/postgres/.bashrc && \
	echo 'export PGUSER=postgres' >> /home/postgres/.bashrc && \
	echo 'export PGDATABASE=job' >> /home/postgres/.bashrc && \
	echo 'export PGPORT=5432' >> /home/postgres/.bashrc && \
	echo 'ulimit -c unlimited' >> /home/postgres/.bashrc

# Set environment variables for non-interactive use
ENV PATH=/usr/local/pgsql/bin:$PATH
ENV PGDATA=/home/postgres/data
ENV PGUSER=postgres
ENV PGDATABASE=job
ENV PGPORT=5432

USER postgres
WORKDIR /home/postgres

# Initialize database, create schema with 16 partitions, and load JOB data
# csv directory is bind-mounted only during this step, not copied into image
RUN --mount=type=bind,source=csv,target=/home/postgres/csv \
	initdb -D "${PGDATA}" && \
	echo "host all all 0.0.0.0/0 trust" >> "${PGDATA}/pg_hba.conf" && \
	echo "listen_addresses='*'" >> "${PGDATA}/postgresql.conf" && \
	echo "log_destination='stderr'" >> "${PGDATA}/postgresql.conf" && \
	echo "logging_collector=on" >> "${PGDATA}/postgresql.conf" && \
	echo "log_directory='/home/postgres'" >> "${PGDATA}/postgresql.conf" && \
	echo "log_filename='logfile-job.log'" >> "${PGDATA}/postgresql.conf" && \
	cat /home/postgres/scripts/basic_pgconf.conf >> "${PGDATA}/postgresql.conf" && \
	pg_ctl -D "${PGDATA}" -l /tmp/pg_init.log start && \
	createdb job && \
	createdb job_fdw && \
	psql -d job -vp=16 -f /home/postgres/scripts/schema-multiparts.sql && \
	psql -d job -v datadir="'/home/postgres'" -f /home/postgres/scripts/copy.sql && \
	psql -d job_fdw -vp=16 -f /home/postgres/scripts/schema-multiparts-fdw.sql && \
	pg_ctl -D "${PGDATA}" stop

EXPOSE 5432

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
	CMD pg_isready -U postgres -d job || exit 1

CMD ["postgres"]
