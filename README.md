# Sqitch

[<img src="https://sqitch.org/img/sqitch-logo.svg" alt="Sqitch" width="1000"/>](https://sqitch.org/)

[Sqitch](https://sqitch.org/) is Vibetype's database migration tool.

The `src` directory in this repository contains a `sqitch` executable that you can use to interact with the migrations residing in the directory's subdirectories.
For example, run `./sqitch deploy` to fill the database with structure like tables, types and policies.

In case you want to be able to simple call `sqitch deploy` without `./` instead, add an `alias sqitch="./sqitch"` to your shell configuration (`~/.bashrc`, `~/.zshrc`, ...).

A basic test data migration can be added to your working directory by running `git apply --3way test/data.patch` and deployed as explained above.
Changes to the test data can be persisted using `git add -AN && git diff > test/data.patch`.

## Database Diagram

This diagram shows the structure of Vibetype's database.

![Graph](./docs/resources/graph.png)

You can create this file as follows:

1. configure [maevsi/stack](https://github.com/maevsi/stack) by adding a portforward of `5432:5432` to the `postgres` service

1. start `maevsi/stack`

1. run `docker run -v /run/postgresql/:/run/postgresql/ --network=host --name schemacrawler --rm -i -t --user=0:0 --entrypoint=/bin/bash schemacrawler/schemacrawler`

1. connect as user `schcrwlr` to the now running `schemacrawler` container, e.g. using Portainer

1. as `schcrwlr` run `schemacrawler --server=postgresql --database=vibetype --user=postgres --password=postgres --command=schema --info-level=maximum --output-format=png --output-file=graph.png --schemas=vibetype.*`

1. reconnect as `root` to the same container and install curl using `apk update && apk add curl`

1. then upload the graph image by running `curl -i -F file="@graph.png" "https://tmpfiles.org/api/v1/upload"`

1. click the link in the output and download the image that pops up!
