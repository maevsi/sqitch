##############################
FROM sqitch/sqitch:v1.4.1.2 AS development

WORKDIR /srv/app

VOLUME /srv/app

ENTRYPOINT ["/srv/app/docker-entrypoint.sh"]
CMD ["sqitch", "--chdir", "src", "deploy", "&&", "sleep", "infinity"]


###########################
FROM postgres:17.0 AS build

ENV POSTGRES_DB=maevsi
ENV POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password

WORKDIR /srv/app

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      sqitch=1.3.1-1 \
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
FROM alpine:3.20.3 AS validate

WORKDIR /srv/app

COPY ./schema ./
COPY --from=build /srv/app ./

RUN diff schema.definition.sql schema.sql


##############################
FROM sqitch/sqitch:v1.4.1.2 AS production

ENV ENV=production

WORKDIR /srv/app

COPY ./docker-entrypoint.sh /usr/local/bin/
COPY --from=validate /srv/app ./

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sqitch", "deploy", "&&", "sleep", "infinity"]
