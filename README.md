# Odoo Ecommerce and ERP

An Odoo-based project for an online store connected to core business operations. The initial scope is product/catalog management, customer orders, inventory, purchasing, fulfillment, and accounting. Business-specific workflows and integrations will be added after requirements are defined.

## Current status

This is a development starter, not a production deployment. It runs Odoo 19 with PostgreSQL 16 and provides a mount point for custom addons. The Odoo Website/eCommerce and ERP applications are installed and configured from the Odoo database; they are not custom-built in this repository yet.

## Run locally

1. Install Docker Engine with the Docker Compose plugin.
2. Copy `.env.example` to `.env` and replace the local database password.
3. Change `admin_passwd` in `config/odoo.conf` to a local master password.
4. Start the services:

   ```sh
   docker compose up -d
   ```

5. Open [http://localhost:8069](http://localhost:8069) and create a development database. Use the `admin_passwd` value from `config/odoo.conf` when the database manager asks for the master password, and set a unique administrator login password.
6. In Apps, update the app list if needed, then install **Commerce ERP Starter**. It installs the standard Odoo Website/eCommerce, Sales, Inventory, Purchase, and Accounting apps together.

Stop the services with `docker compose down`. Persistent database and Odoo files remain in Docker volumes. To erase local development data, remove those volumes explicitly with `docker compose down --volumes`.

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
