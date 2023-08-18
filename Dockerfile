##############################
FROM sqitch/sqitch@sha256:4ff357cada9dbdb5ef9a2a6a0f93d92fed5a06a53aec606d3e243533213e40dc AS development

WORKDIR /srv/app

COPY ./docker-entrypoint.sh /usr/local/bin/

VOLUME /srv/app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sqitch", "deploy", "&&", "sleep", "infinity"]


###########################
FROM postgres:15.4@sha256:a5e89e5f2679863bedef929c4a7ec5d1a2cb3c045f13b47680d86f8701144ed7 AS build

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
FROM alpine:3.18.3@sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a AS validate

WORKDIR /srv/app

COPY ./schema ./
COPY --from=build /srv/app ./

RUN diff schema.sql schema.definition.sql


##############################
FROM sqitch/sqitch@sha256:4ff357cada9dbdb5ef9a2a6a0f93d92fed5a06a53aec606d3e243533213e40dc AS production

WORKDIR /srv/app

COPY ./docker-entrypoint.sh /usr/local/bin/
COPY --from=validate /srv/app ./

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sqitch", "deploy", "&&", "sleep", "infinity"]
