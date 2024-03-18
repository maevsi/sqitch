# Sqitch

[<img src="https://sqitch.org/img/sqitch-logo.svg" alt="Sqitch" width="1000"/>](https://sqitch.org/)

[Sqitch](https://sqitch.org/) is maevsi's database migration tool.

The `src` directory in this repository contains a `sqitch` executable that you can use to interact with the migrations residing in the directory's subdirectories.
For example, run `./sqitch deploy` to fill the database with structure like tables, types and policies.

In case you want to be able to simple call `sqitch deploy` without `./` instead, add an `alias sqitch="./sqitch"` to your shell configuration (`~/.bashrc`, `~/.zshrc`, ...).

## Database Diagram

This diagram shows the structure of maevsi's database.

![Graph](./docs/graph.png)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fmaevsi%2Fsqitch.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fmaevsi%2Fsqitch?ref=badge_shield)

You can create this file as follows:

1. configure [maevsi_stack](https://github.com/maevsi/maevsi_stack) by adding a portforward of `5432:5432` to the `postgres` service

1. start `maevsi_stack`

1. run `docker run -v /run/postgresql/:/run/postgresql/ --network=host --name schemacrawler --rm -i -t --user=0:0 --entrypoint=/bin/bash schemacrawler/schemacrawler`

1. connect as user `schcrwlr` to the now running `schemacrawler` container, e.g. using Portainer

1. as `schcrwlr` run `schemacrawler --server=postgresql --database=maevsi --user=postgres --password=postgres --command=schema --info-level=maximum --output-format=png --output-file=graph.png --schemas=maevsi.*`

1. as `root` install curl using `apk update && apk add curl`

1. still as `root` upload the graph image by running `curl -i -F file="@graph.png" "https://tmpfiles.org/api/v1/upload"`

1. click the link in the output and download the image that pops up!


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fmaevsi%2Fsqitch.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fmaevsi%2Fsqitch?ref=badge_large)