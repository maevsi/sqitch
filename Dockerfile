# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv

##############################
FROM sqitch/sqitch:v1.5.0.0 AS prepare

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
FROM quay.io/debezium/postgres:17 AS test-build

ENV POSTGRES_DB=maevsi
ENV POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password

WORKDIR /srv/app

RUN add-apt-repository -r 'deb http://ftp.debian.org/debian testing main contrib' \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    sqitch=1.1.0000-1 \
  && mkdir -p /run/secrets \
  && echo "postgres"      > /run/secrets/postgres_password \
  && echo "postgraphile"  > /run/secrets/postgres_role_maevsi-postgraphile_username \
  && echo "tusd"          > /run/secrets/postgres_role_maevsi-tusd_username \
  && echo "placeholder" | tee \
    /run/secrets/postgres_role_maevsi-postgraphile_password \
    /run/secrets/postgres_role_maevsi-tusd_password \
    /dev/null

COPY ./src ./
COPY ./test/index-missing.sql ./test/

RUN export SQITCH_TARGET="$(cat SQITCH_TARGET.env)" \
  && docker-entrypoint.sh postgres & \
  while ! pg_isready -h localhost -U postgres -p 5432; do sleep 1; done \
  && sqitch deploy -t db:pg://postgres:postgres@/maevsi \
  && psql -h localhost -U postgres -d maevsi -f ./test/index-missing.sql -v ON_ERROR_STOP=on \
  && pg_dump -s -h localhost -U postgres -p 5432 maevsi | sed -e '/^-- Dumped/d' > schema.sql \
  && sqitch revert -t db:pg://postgres:postgres@/maevsi


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
