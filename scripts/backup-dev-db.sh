#!/usr/bin/env bash
set -euo pipefail
umask 077

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

database="${ODOO_DEV_DATABASE:-commerce_dev}"
if [[ ! "$database" =~ ^[a-z][a-z0-9_]{0,62}$ ]]; then
  echo "ODOO_DEV_DATABASE must start with a lowercase letter and contain only lowercase letters, digits, or underscores." >&2
  exit 1
fi

exists="$(docker compose exec -T db psql -U "$POSTGRES_USER" -d postgres -tAc \
  "SELECT 1 FROM pg_database WHERE datname = '$database'")"
if [[ "$exists" != "1" ]]; then
  echo "Database '$database' does not exist; no backup was created." >&2
  exit 1
fi

backup_dir="$project_root/backups"
mkdir -p "$backup_dir"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
archive="$backup_dir/${database}_${timestamp}.zip"
temporary="$(mktemp "$backup_dir/.${database}_${timestamp}_XXXXXX")"
trap 'rm -f "$temporary"' EXIT

docker compose exec -T odoo odoo db \
  --config=/etc/odoo/odoo.conf \
  dump "$database" > "$temporary"

chmod 600 "$temporary"
mv "$temporary" "$archive"
trap - EXIT

echo "Created Odoo database and filestore backup: $archive"
