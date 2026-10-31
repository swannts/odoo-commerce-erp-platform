# Engineering Standards

These standards turn the project requirements into implementation rules for Odoo addons, integrations, operations, and team delivery. They apply to code in this repository and to any later deployment of it.

## Solution design

- Start with a written business process and acceptance criteria. Check standard Odoo configuration and installed apps first; customize only where an approved requirement is not met.
- Keep custom behavior in version-specific addons under `addons/`, organized around clear business capabilities. Do not patch Odoo core or hide business rules in manual production-only edits.
- Keep edition-specific and provider-specific behavior behind explicit addon dependencies or adapters so the project can make those choices without entangling unrelated workflows.
- Record major architecture and data decisions, including the reason, owner, affected processes, and upgrade impact.

## Odoo implementation

- Use the Odoo ORM for normal reads and writes. If direct SQL is necessary for a measured reporting or bulk-operation need, parameterize it, preserve access-control expectations, and document why ORM use is insufficient.
- Define model fields, constraints, computed fields, business methods, access groups, ACLs, record rules, and field-level restrictions in the relevant addon.
- Use XML for menus, actions, views, access data, and configuration records. Use QWeb for Odoo templates and reports. Use JavaScript and Owl when the requested interaction needs client-side behavior that configuration, views, or QWeb cannot provide.
- Keep module manifests explicit about dependencies, version, license, data, and application status. Avoid broad dependencies and implicit coupling between addons.
- Make imports, scheduled jobs, and integration-triggered actions safe to retry. Use database constraints and transaction boundaries for correctness rather than relying on UI-only checks.

## Integration design

- Create an integration contract before implementation: system of record per entity, field mapping, authentication, request/response examples, timeouts, retry policy, idempotency, rate limits, reconciliation, monitoring, and support owner.
- Use a dedicated least-privilege Odoo bot user and scoped, rotated credentials for automated access. Never use an administrator account or commit API keys, passwords, or customer data.
- Prefer supported Odoo APIs available to the chosen edition and hosting plan. Odoo 20 documents the JSON-2 API and notes that external API access is plan-dependent; confirm availability before selecting it. Avoid starting new integrations on legacy XML-RPC/JSON-RPC services where a supported alternative is available. See [Odoo external API documentation](https://www.odoo.com/documentation/20.0/developer/reference/external_api.html).
- Use custom REST controllers only for a defined integration need. Apply explicit authentication, authorization, input validation, rate limiting, audit logging, and stable versioned request/response schemas.
- Redact secrets and unnecessary personal data from logs. Give external calls bounded timeouts and move slow or failure-prone work to retryable jobs where the business process permits it.

## Localization and compliance

- Maintain a localization matrix per country/legal entity: accounting localization, chart of accounts, tax rules, fiscal positions, invoice requirements, currency, language, HR/payroll localization, and regulatory reports.
- Have qualified local finance, tax, HR, and legal owners approve each jurisdiction's configuration and acceptance evidence.
- Keep local rules in standard localization modules or isolated country-specific addons. Do not invent one global tax/payroll implementation for jurisdictions that have different rules.
- Do not post production transactions until the relevant entity, fiscal localization, taxes, and opening balances are approved.

## Security and performance reviews

- Treat every controller, public model method, import, webhook, and scheduled job as a trust boundary. Enforce access rights, record rules, company boundaries, input validation, and safe error handling at the server boundary.
- Use `sudo` only for a reviewed need, limit the record set and fields it can touch, and document the authorization reason. Review access as each role, not only as the administrator.
- Review sensitive data exposure in views, exports, reports, APIs, logs, and attachments. Keep secrets in deployment-managed secret storage.
- Measure performance on realistic catalog, order, and warehouse volumes. Review query counts, batch ORM operations, prefetch behavior, indexes, pagination, worker/concurrency settings, and queue depth before optimizing.
- For each code review, check business correctness, access control, multi-company behavior, transaction safety, upgrade compatibility, query behavior, and observability.

## Release, upgrades, and operations

- Pin the Odoo release, PostgreSQL major version, and external addon revisions per environment. Promote the same reviewed source revision through development, staging, and production.
- Before an Odoo major upgrade, inventory addon compatibility, rehearse the database and filestore migration on a restored copy, reconcile key business records, and retain a tested rollback backup. Custom migration scripts must be versioned with their addon.
- Keep database and filestore backups coordinated. Define recovery point/time objectives, restore procedures, log/metric alerts, incident ownership, and maintenance windows before production.
- Keep development backup artifacts out of Git. Production backups need a separately secured, off-site destination, retention policy, encryption at rest, restore drills, and access auditing.
- Document environment configuration, secrets rotation, deploy and rollback steps, integration recovery, data repair, and common support procedures.

## Team delivery and documentation

- Functional consultants and business owners own process decisions and acceptance; developers own maintainable implementation and technical risk; finance/HR/legal owners approve jurisdictional rules; operations owners approve support and recovery readiness.
- Each feature has a requirement, process owner, acceptance criteria, technical design, reviewer, and release note.
- Keep module documentation, API contracts, data mappings, architecture decisions, migration notes, user-facing configuration steps, and operational runbooks current with the code.

## Current applicability

The current `commerce_erp` addon only installs standard Odoo applications. These standards do not imply that B2B, payroll, a specific REST API, tax localization, third-party provider, or hosting service has been selected. Those require approved business and edition decisions first.
