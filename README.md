# Odoo Ecommerce and ERP

An Odoo-based project for an online store connected to core business operations. The initial scope is product/catalog management, customer orders, inventory, purchasing, fulfillment, and accounting. Business-specific workflows and integrations will be added after requirements are defined.

## Current status

This is a development build, not a production deployment. It runs Odoo 20.0 with PostgreSQL 16. The local `commerce_dev` database includes the standard Odoo ecommerce/ERP apps and a responsive, company-name-aware storefront homepage that links to the native shop. Product data, brand content, business workflows, localization, and integrations still need your business requirements.

See [PROJECT_PLAN.md](PROJECT_PLAN.md) for the phased scope, decisions, and acceptance criteria for the full system.
See [ENGINEERING_STANDARDS.md](ENGINEERING_STANDARDS.md) for implementation, integration, localization, security, upgrade, and documentation standards.

## Run locally

1. Install Docker Engine with the Docker Compose plugin.
2. Copy `.env.example` to `.env` and replace the local database and administrator passwords.
3. Change `admin_passwd` in `config/odoo.conf` to a local master password.
4. Start the services:

   ```sh
   docker compose up -d
   ```

5. Create an empty development database and install the starter app bundle:

   ```sh
   ./scripts/init-dev-db.sh
   ```

   This initializes the database without demo data and installs or upgrades **Commerce ERP Starter**, which bundles Website/eCommerce, Sales, Inventory, Purchase, Accounting, and the project storefront homepage. Set `ODOO_COUNTRY` in `.env` before running the script if you want Odoo to initialize the main company with a country. Otherwise, choose the country and accounting localization with the business owner before configuring taxes or posting real transactions.
   For later changes to custom addons, run `./scripts/upgrade-dev-addons.sh` to apply versioned addon upgrades while the local Odoo web/cron process is stopped.
6. Open [http://localhost:8069](http://localhost:8069) and sign in with `ODOO_ADMIN_LOGIN` and `ODOO_ADMIN_PASSWORD` from `.env`. The database-manager master password is `admin_passwd` from `config/odoo.conf`; change it before using the database manager.

Stop the services with `docker compose down`. Persistent database and Odoo files remain in Docker volumes. To erase local development data, remove those volumes explicitly with `docker compose down --volumes`.

Create a local database and filestore backup with `./scripts/backup-dev-db.sh`. Backups are stored in the ignored `backups/` directory with owner-only file permissions. Copy backups to a separately protected storage location; the local script does not provide off-site retention or disaster recovery.

## Repository layout

```text
addons/commerce_erp/ Custom app bundle for the standard commerce and ERP stack
config/odoo.conf     Local Odoo server configuration
docker-compose.yml   Local Odoo and PostgreSQL services
```

## Project decisions still needed

- What products and customer types the store serves (B2C, B2B, or both)
- Countries, currencies, tax rules, and languages
- Warehouses, fulfillment, returns, and shipping providers
- Payment providers and sales channels
- Whether manufacturing, POS, subscriptions, or marketplace connections are in scope
- Hosting, backup, security, and availability requirements for production

## Security and deployment

The included configuration is for local development only. Do not expose it to the public internet or reuse its example credentials in a deployed environment. Production setup needs environment-specific secrets, HTTPS and proxy configuration, backups, monitoring, access controls, and a tested upgrade plan.
