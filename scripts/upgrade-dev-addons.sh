#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

if [[ ! -f .env ]]; then
  echo "Missing .env. Copy .env.example to .env first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

database="${1:-${ODOO_DEV_DATABASE:-commerce_dev}}"
shift || true
modules=("$@")
if [[ "${#modules[@]}" -eq 0 ]]; then
  modules=(commerce_erp commerce_storefront)
fi

if [[ ! "$database" =~ ^[a-z][a-z0-9_]{0,62}$ ]]; then
  echo "Database name must start with a lowercase letter and contain only lowercase letters, digits, or underscores." >&2
  exit 1
fi

docker compose up -d db
docker compose stop odoo
restart_odoo() {
  status=$?
  docker compose up -d odoo
  return "$status"
}
trap restart_odoo EXIT

docker compose run --rm --no-deps --entrypoint odoo odoo \
  module upgrade "${modules[@]}" \
  --config=/etc/odoo/odoo.conf \
  --database "$database" \
  --outdated
