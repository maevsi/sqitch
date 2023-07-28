##############################
FROM sqitch/sqitch@sha256:b9e5ad57f652aa4c75eff96655bf322a7d67ce6181773c20836830fcbabee311 AS development

WORKDIR /srv/app

COPY ./docker-entrypoint.sh /usr/local/bin/

VOLUME /srv/app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sqitch", "deploy", "&&", "sleep", "infinity"]


###########################
FROM postgres:15.3@sha256:9fe676049131f22de7490cc786306625f4c50309281aecab7ddea760965dc1fe AS build

ENV POSTGRES_DB=maevsi
ENV POSTGRES_PASSWORD=postgres

WORKDIR /srv/app

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      libdbd-pg-perl postgresql-client sqitch

COPY ./src ./

RUN export SQITCH_TARGET="$(cat SQITCH_TARGET.env)" \
  && docker-entrypoint.sh postgres & \
  while ! pg_isready -h localhost -U postgres -p 5432; do sleep 1; done \
  && sqitch deploy -t db:pg://postgres:postgres@/maevsi \
  && pg_dump -s -h localhost -U postgres -p 5432 maevsi | sed -e '/^-- Dumped/d' > schema.sql

##############################
FROM alpine:3.18.2@sha256:82d1e9d7ed48a7523bdebc18cf6290bdb97b82302a8a9c27d4fe885949ea94d1 AS validate

WORKDIR /srv/app

COPY ./schema ./
COPY --from=build /srv/app ./

RUN diff schema.sql schema.definition.sql


##############################
FROM sqitch/sqitch@sha256:b9e5ad57f652aa4c75eff96655bf322a7d67ce6181773c20836830fcbabee311 AS production

WORKDIR /srv/app

COPY ./docker-entrypoint.sh /usr/local/bin/
COPY --from=validate /srv/app ./

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sqitch", "deploy", "&&", "sleep", "infinity"]
