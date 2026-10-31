{
    "name": "Commerce Storefront",
    "summary": "Responsive homepage for the connected Odoo online store",
    "version": "20.0.1.1.0",
    "author": "SwannTS",
    "category": "Website/eCommerce",
    "license": "LGPL-3",
    "depends": ["website_sale"],
    "data": ["views/homepage.xml"],
    "assets": {
        "web.assets_frontend": [
            "commerce_storefront/static/src/scss/storefront.scss",
        ],
    },
    "installable": True,
    "application": False,
    "auto_install": False,
}
