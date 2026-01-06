# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv

##############################
FROM sqitch/sqitch:v1.6.1.0 AS prepare

WORKDIR /srv/app


##############################
FROM prepare AS development

VOLUME /srv/app

ENTRYPOINT ["/srv/app/docker-entrypoint.sh"]
CMD ["sqitch", "--chdir", "src", "deploy", "&&", "sleep", "infinity"]


###########################
FROM prepare AS build

COPY ./src ./


###########################
# sqitch is not available for alpine linux as of 2025-11-20 (https://github.com/sqitchers/sqitch/issues/351#issuecomment-614153859)
FROM postgis/postgis:18-3.6 AS test-build

ENV POSTGRES_DB=ci_database
ENV POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password
ENV POSTGRES_USER=ci

WORKDIR /srv/app

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    sqitch=1.5.2-1 \
  && mkdir -p /run/secrets \
  && echo "grafana"       > /run/secrets/postgres_role_service_grafana_username \
  && echo "postgres"      > /run/secrets/postgres_password \
  && echo "postgraphile"  > /run/secrets/postgres_role_service_postgraphile_username \
  && echo "vibetype"      > /run/secrets/postgres_role_service_vibetype_username \
  && echo "zammad"        > /run/secrets/postgres_role_service_zammad_username \
  && echo "placeholder" | tee \
    /run/secrets/postgres_role_service_grafana_password \
    /run/secrets/postgres_role_service_postgraphile_password \
    /run/secrets/postgres_role_service_vibetype_password \
    /run/secrets/postgres_role_service_zammad_password \
    /dev/null

COPY ./src ./src
COPY ./test ./test

RUN docker-entrypoint.sh postgres & \
  while ! pg_isready --host localhost --username ci --port 5432; do sleep 1; done \
  && sqitch --chdir src deploy --target db:pg://ci:postgres@/ci_database \
  && pg_dump --schema-only --host localhost --username ci --port 5432 --exclude-schema vibetype* --restrict-key=restrictkey ci_database | sed -e '/^-- Dumped/d' > schema_other.sql \
  && pg_dump --schema-only --host localhost --username ci --port 5432 --schema vibetype* --restrict-key=restrictkey ci_database | sed -e '/^-- Dumped/d' > schema_vibetype.sql \
  && psql --host localhost --username ci --dbname ci_database --quiet --file ./test/logic/main.sql \
    --variable TEST_DIRECTORY=./test/logic --variable ON_ERROR_STOP=on \
  && sqitch --chdir src revert --target db:pg://ci:postgres@/ci_database

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

COPY ./docker-entrypoint.sh /usr/local/bin/
COPY --from=collect /srv/app ./

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sqitch", "deploy", "&&", "sleep", "infinity"]
