# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183
# check=skip=SecretsUsedInArgOrEnv

##############################
# The sqitch image ships no package manager, so tini comes from Debian.
FROM debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0 AS tini

RUN apt-get update \
    && apt-get install --no-install-recommends --yes tini


##############################
FROM sqitch/sqitch:v1.6.1.4@sha256:e0934eab9f7dd00c7467361e09970a553c10d971155e10ef2c3410242eb95dbc AS prepare

# tini forwards stop signals to the whole process group, as `sh -c` in the entrypoint does not pass them on.
COPY --from=tini /usr/bin/tini-static /usr/bin/tini

WORKDIR /srv/app


##############################
FROM prepare AS development

VOLUME /srv/app

ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/srv/app/docker-entrypoint.sh"]
CMD ["sqitch", "--chdir", "src", "deploy"]


###########################
FROM prepare AS build

COPY ./src ./


###########################
# sqitch is not available for alpine linux as of 2025-11-20 (https://github.com/sqitchers/sqitch/issues/351#issuecomment-614153859)
# Use imresamu/postgis:* for ARM (Mac M) support.
FROM postgis/postgis:19-3.7@sha256:fb3b0686833282d392a6af200c6c5234ed2d671ef372fa245106ec39b5c95945 AS postgres-base

ENV POSTGRES_DB=ci_database
ENV POSTGRES_PASSWORD_FILE=/run/secrets/postgres-password
ENV POSTGRES_USER=ci

# renovate: datasource=deb distro=debian depName=jq suite=trixie
ENV JQ_VERSION="1.7.1-6+deb13u4"
# renovate: datasource=deb distro=debian depName=sqitch suite=trixie
ENV SQITCH_VERSION="1.5.2-1"

WORKDIR /srv/app

RUN sed -i 's|http://apt.postgresql.org|https://apt.postgresql.org|' /etc/apt/sources.list.d/pgdg.list  # plain HTTP to apt.postgresql.org gets blocked with 403 behind TLS-inspecting proxies

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    jq="${JQ_VERSION}" \
    sqitch="${SQITCH_VERSION}" \
  && mkdir -p /run/secrets \
  && echo "gizmosql"      > /run/secrets/postgres-role-service-gizmosql-username \
  && echo "grafana"       > /run/secrets/postgres-role-service-grafana-username \
  && echo "postgres"      > /run/secrets/postgres-password \
  && echo "postgraphile"  > /run/secrets/postgres-role-service-postgraphile-username \
  && echo "reccoom"       > /run/secrets/postgres-role-service-reccoom-username \
  && echo "vibetype"      > /run/secrets/postgres-role-service-vibetype-username \
  && echo "zammad"        > /run/secrets/postgres-role-service-zammad-username \
  && echo "placeholder" | tee \
    /run/secrets/postgres-role-service-gizmosql-password \
    /run/secrets/postgres-role-service-grafana-password \
    /run/secrets/postgres-role-service-postgraphile-password \
    /run/secrets/postgres-role-service-reccoom-password \
    /run/secrets/postgres-role-service-vibetype-password \
    /run/secrets/postgres-role-service-zammad-password \
    /dev/null

COPY ./src ./src
COPY ./test ./test


##############################
FROM postgres-base AS test-build

RUN docker-entrypoint.sh postgres & \
  while ! pg_isready --host localhost --username ci --port 5432; do sleep 1; done \
  && sqitch --chdir src deploy --target db:pg://ci:postgres@/ci_database \
  && pg_dump --schema-only --host localhost --username ci --port 5432 --exclude-schema vibetype* --restrict-key=restrictkey ci_database | sed -e '/^-- Dumped/d' > schema_other.sql \
  && pg_dump --schema-only --host localhost --username ci --port 5432 --schema vibetype* --restrict-key=restrictkey ci_database | sed -e '/^-- Dumped/d' > schema_vibetype.sql \
  && psql --host localhost --username ci --dbname ci_database --quiet --file ./test/logic/main.sql \
    --variable TEST_DIRECTORY=./test/logic --variable ON_ERROR_STOP=on \
  && sqitch --chdir src revert --target db:pg://ci:postgres@/ci_database


##############################
FROM postgres-base AS benchmark

RUN docker-entrypoint.sh postgres & \
  while ! pg_isready --host localhost --username ci --port 5432; do sleep 1; done \
  && sqitch --chdir src deploy --target db:pg://ci:postgres@/ci_database \
  && ./test/benchmark/run.sh benchmark_results.json "pg://ci:postgres@localhost/ci_database"

##############################
FROM test-build AS test

COPY ./test/fixture/schema_other.definition.sql ./test/fixture/schema_vibetype.definition.sql ./

RUN diff schema_other.definition.sql schema_other.sql \
  && diff schema_vibetype.definition.sql schema_vibetype.sql


##############################
FROM prepare AS collect

COPY --from=test /srv/app/schema_vibetype.sql /dev/null
COPY --from=build /srv/app ./


##############################
FROM collect AS production

# used in docker entrypoint
ENV ENV=production

COPY ./docker-entrypoint.sh /srv/app/docker-entrypoint.sh
COPY --from=collect /srv/app ./

ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/srv/app/docker-entrypoint.sh"]
CMD ["sqitch", "deploy"]
