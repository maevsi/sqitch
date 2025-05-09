# `maevsi/sqitch` Advanced Project Overview

This document provides advanced project documentation that goes beyond the initial onboarding process.


## Standalone Setup

Besides using the default development environment via [`maevsi/stack`](https://github.com/maevsi/stack), you can also configure a local standalone PostgreSQL database for use with Sqitch.

This standalone setup is lighter but requires you to manually configure local services that are compatible with the `maevsi/stack` production deployment setup.


## Executable

Instead of using the package script (`npx npm run deploy`) to invoke Sqitch, you can call the Sqitch executable directly:

```sh
./src/sqitch deploy <command> [options]
```


## Database Diagram

The database structure diagram embedded in the [main README](../../README.md) is generated using [SchemaCrawler](https://www.schemacrawler.com/).

To **create/update** the diagram, follow these steps:

1. Start [`maevsi/stack`](https://github.com/maevsi/stack) as described in the [maevsi/vibetype README](https://github.com/maevsi/vibetype/blob/main/README.md#fullstack).
2. Run the SchemaCrawler container:

   ```sh
   docker run -v /run/postgresql/:/run/postgresql/ --network=host --name schemacrawler --rm -it --user=0:0 --entrypoint=/bin/bash schemacrawler/schemacrawler
   ```

3. Connect to the container as user `schcrwlr` (you can use Portainer or similar tools).
4. Inside the container, run:

   ```sh
   schemacrawler --server=postgresql --database=vibetype --user=postgres --password=postgres \
     --command=schema --info-level=maximum --output-format=png --output-file=graph.png --schemas=vibetype.*
   ```

5. Reconnect to the container as `root` and install curl:

   ```sh
   apk update && apk add curl
   ```

6. Upload the generated diagram:

   ```sh
   curl -i -F file="@graph.png" "https://tmpfiles.org/api/v1/upload"
   ```

7. Click the link from the output to download the diagram image.
