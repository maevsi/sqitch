#!/bin/sh
set -e

# `pnpm run lint -- <files>` forwards the `--` separator itself as an
# argument on some pnpm versions; drop it so `$#` reflects the file count.
[ "$1" = "--" ] && shift

THIS=$(dirname "$(readlink -f "$0")")
DEPLOY_DIR="$THIS/../src/deploy"
LINT_DIR=$(mktemp -d)
trap 'rm -rf "$LINT_DIR"' EXIT

mkdir -p "$LINT_DIR/src/deploy"

# Lint every deploy migration by default, or only the files given as
# arguments (e.g. only the migrations changed in a PR, as CI does).
if [ "$#" -eq 0 ]; then
  set -- "$DEPLOY_DIR"/*.sql
fi

# Squawk can't parse psql meta-commands (`\set`, `\gexec`) or variable
# interpolation (`:role_service_*`), which deploy migrations use to grant
# access to secret-sourced role names. Substitute those with placeholders
# that are valid SQL but keep line numbers stable, so squawk's output still
# points at the right line in the original file.
for file in "$@"; do
  name=$(basename "$file")
  sed -E "
    s/^\\\\set .*//
    s/\\\\gexec/;/
    s/:'role_service_[a-z_]+_password'/'placeholder_password'/g
    s/:'role_service_[a-z_]+_username'/'placeholder_role'/g
    s/:role_service_[a-z_]+_username/placeholder_role/g
  " "$file" > "$LINT_DIR/src/deploy/$name"
done

pnpm exec squawk --config "$THIS/../.squawk.toml" "$LINT_DIR"/src/deploy/*.sql
