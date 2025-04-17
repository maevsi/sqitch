# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv

##############################
FROM sqitch/sqitch:v1.5.1.0 AS prepare

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
FROM postgis/postgis:17-3.5 AS test-build

ENV POSTGRES_DB=ci_database
ENV POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password
ENV POSTGRES_USER=ci

WORKDIR /srv/app

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    sqitch=1.1.0000-1 \
  && mkdir -p /run/secrets \
  && echo "postgres"      > /run/secrets/postgres_password \
  && echo "postgraphile"  > /run/secrets/postgres_role_service_postgraphile_username \
  && echo "vibetype"          > /run/secrets/postgres_role_service_vibetype_username \
  && echo "placeholder" | tee \
    /run/secrets/postgres_role_service_vibetype_password \
    /run/secrets/postgres_role_service_postgraphile_password \
    /dev/null

COPY ./src ./
COPY ./test/pg-test/test_main.sql ./test/pg-test/
COPY ./test/pg-test/function/* ./test/pg-test/function/
COPY ./test/pg-test/test/* ./test/pg-test/test/

RUN docker-entrypoint.sh postgres & \
  while ! pg_isready -h localhost -U ci -p 5432; do sleep 1; done \
  && sqitch deploy -t db:pg://ci:postgres@/ci_database \
  && pg_dump -s -h localhost -U ci -p 5432 ci_database | sed -e '/^-- Dumped/d' > schema.sql \
  && psql -h localhost -U ci -d ci_database -w -q -f ./test/pg-test/test_main.sql \
     -v db_owner=ci -v test_dir=./test/pg-test -v ON_ERROR_STOP=on \
  && sqitch revert -t db:pg://ci:postgres@/ci_database

##############################
FROM test-build AS test

COPY ./test/schema/schema.definition.sql ./

RUN diff schema.definition.sql schema.sql


##############################
FROM prepare AS collect

COPY --from=test /srv/app/schema.sql /dev/null
COPY --from=build /srv/app ./


##############################
FROM collect AS production

# used in docker entrypoint
ENV ENV=production

COPY ./docker-entrypoint.sh /usr/local/bin/
COPY --from=collect /srv/app ./

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sqitch", "deploy", "&&", "sleep", "infinity"]
