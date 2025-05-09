# `maevsi/sqitch` [Advanced]

Here you find further project documentation that goes beyond the initial onboarding.

<!-- ## Standalone setup

In addition to the default development setup using `maevsi/stack`, you can have a single PostgreSQL database running locally as connection target for sqitch. -->

<!-- TODO: describe -->

## Database Diagram

The database structure diagram embedded in the [README.md](../../README.md) was generated using [SchemaCrawler](https://www.schemacrawler.com/).

You can **create/update** this file as follows:

1. start [`maevsi/stack`](https://github.com/maevsi/stack) as explained in [maevsi/vibetype/README.md#fullstack](https://github.com/maevsi/vibetype/blob/main/README.md#fullstack)

1. run `docker run -v /run/postgresql/:/run/postgresql/ --network=host --name schemacrawler --rm -i -t --user=0:0 --entrypoint=/bin/bash schemacrawler/schemacrawler`

1. connect as user `schcrwlr` to the now running `schemacrawler` container, e.g. using Portainer

1. as `schcrwlr` run `schemacrawler --server=postgresql --database=vibetype --user=postgres --password=postgres --command=schema --info-level=maximum --output-format=png --output-file=graph.png --schemas=vibetype.*`

1. reconnect as `root` to the same container and install curl using `apk update && apk add curl`

1. then upload the graph image by running `curl -i -F file="@graph.png" "https://tmpfiles.org/api/v1/upload"`

1. click the link in the output and download the image that pops up!
