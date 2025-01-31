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
FROM quay.io/debezium/postgres:17@sha256:2489d7616cb7002f90805d2130deb1817e9c6c66f59a2406408ccb44410b2e80 AS test-build

ENV POSTGRES_DB=maevsi
ENV POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password

WORKDIR /srv/app

RUN add-apt-repository -r 'deb http://ftp.debian.org/debian testing main contrib' \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    sqitch=1.1.0000-1 \
  && mkdir -p /run/secrets \
  && echo "postgres" > /run/secrets/postgres_password \
  && echo "grafana" > /run/secrets/postgres_role_grafana_username \
  && echo "placeholder" | tee \
    /run/secrets/postgres_role_grafana_password \
    /run/secrets/postgres_role_maevsi-postgraphile_password \
    /run/secrets/postgres_role_maevsi-tusd_password \
    /dev/null

COPY ./src ./

RUN export SQITCH_TARGET="$(cat SQITCH_TARGET.env)" \
  && docker-entrypoint.sh postgres & \
  while ! pg_isready -h localhost -U postgres -p 5432; do sleep 1; done \
  && sqitch deploy -t db:pg://postgres:postgres@/maevsi \
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
