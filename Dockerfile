##############################
FROM sqitch/sqitch@sha256:acd47c19ba4cb1005eaeb17500c6236d462559dc7b2acfdf68d955adb72ed122 AS development

WORKDIR /srv/app

VOLUME /srv/app

ENTRYPOINT ["/srv/app/docker-entrypoint.sh"]
CMD ["sqitch", "--chdir", "src", "deploy", "&&", "sleep", "infinity"]


###########################
FROM postgres:16.0@sha256:92e8dd9b3c5987b82409abfe23b361c949e9ae86c6213f455a7f4d6a3b5b3687 AS build

ENV POSTGRES_DB=maevsi
ENV POSTGRES_PASSWORD=postgres

WORKDIR /srv/app

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      sqitch=1.3.1-1

COPY ./src ./

RUN export SQITCH_TARGET="$(cat SQITCH_TARGET.env)" \
  && docker-entrypoint.sh postgres & \
  while ! pg_isready -h localhost -U postgres -p 5432; do sleep 1; done \
  && sqitch deploy -t db:pg://postgres:postgres@/maevsi \
  && pg_dump -s -h localhost -U postgres -p 5432 maevsi | sed -e '/^-- Dumped/d' > schema.sql

##############################
FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978 AS validate

WORKDIR /srv/app

COPY ./schema ./
COPY --from=build /srv/app ./

RUN diff schema.definition.sql schema.sql


##############################
FROM sqitch/sqitch@sha256:acd47c19ba4cb1005eaeb17500c6236d462559dc7b2acfdf68d955adb72ed122 AS production

ENV ENV=production

WORKDIR /srv/app

COPY ./docker-entrypoint.sh /usr/local/bin/
COPY --from=validate /srv/app ./

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sqitch", "deploy", "&&", "sleep", "infinity"]
