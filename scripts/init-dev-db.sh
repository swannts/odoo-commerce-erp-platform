#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

if [[ ! -f .env ]]; then
  echo "Missing .env. Copy .env.example to .env and set local passwords first." >&2
  exit 1
fi

# The example .env uses shell-compatible KEY=value lines.
set -a
# shellcheck disable=SC1091
source .env
set +a

database="${ODOO_DEV_DATABASE:-commerce_dev}"
admin_login="${ODOO_ADMIN_LOGIN:-admin}"
admin_password="${ODOO_ADMIN_PASSWORD:-}"
language="${ODOO_LANGUAGE:-en_US}"

if [[ ! "$database" =~ ^[a-z][a-z0-9_]{0,62}$ ]]; then
  echo "ODOO_DEV_DATABASE must start with a lowercase letter and contain only lowercase letters, digits, or underscores." >&2
  exit 1
fi

if [[ -z "$admin_password" || "$admin_password" == "change-this-development-login-password" ]]; then
  echo "Set a unique ODOO_ADMIN_PASSWORD in .env before initializing the database." >&2
  exit 1
fi

docker compose up -d

exists="$(docker compose exec -T db psql -U "$POSTGRES_USER" -d postgres -tAc \
  "SELECT 1 FROM pg_database WHERE datname = '$database'")"
if [[ "$exists" == "1" ]]; then
  initialized="$(docker compose exec -T db psql -U "$POSTGRES_USER" -d "$database" -tAc \
    "SELECT to_regclass('public.ir_module_module') IS NOT NULL")"
  if [[ "$initialized" != "t" ]]; then
    echo "Database '$database' exists but is not an initialized Odoo database; leaving it unchanged." >&2
    exit 1
  fi
  echo "Database '$database' already exists; leaving its data unchanged."
else
  init_args=(
    db
    --config=/etc/odoo/odoo.conf
    init "$database"
    --language "$language"
    --username "$admin_login"
    --password "$admin_password"
  )
  if [[ -n "${ODOO_COUNTRY:-}" ]]; then
    init_args+=(--country "$ODOO_COUNTRY")
  fi

  docker compose exec -T odoo odoo "${init_args[@]}"
fi

module_state="$(docker compose exec -T db psql -U "$POSTGRES_USER" -d "$database" -tAc \
  "SELECT state FROM ir_module_module WHERE name = 'commerce_erp'")"
if [[ "$module_state" == "installed" ]]; then
  ./scripts/upgrade-dev-addons.sh "$database" commerce_erp commerce_storefront
else
  docker compose exec -T odoo odoo module install commerce_erp \
    --config=/etc/odoo/odoo.conf \
    --database "$database"
fi

echo "Development database '$database' is ready. Sign in as '$admin_login' at http://localhost:${ODOO_PORT:-8069}."
