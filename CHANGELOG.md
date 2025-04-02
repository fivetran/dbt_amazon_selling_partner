# dbt_amazon_selling_partner v0.1.1

[PR #3](https://github.com/fivetran/dbt_amazon_selling_partner/pull/3) includes the following updates:

## Bug Fixes
- Handles `ORDER_ITEM` `*_amount` fields and `ORDERS.order_total_amount` coming in as strings. Cleans them (removes non-numeric-compatible characters) and safely converts them to numeric fields to avoid downstream data type errors. The affected end models and fields are:
  - In the `amazon_selling_partner__orders` end model:
    - `order_total_amount`
    - `total_item_price_amount`
    - `total_item_tax_amount`
    - `total_shipping_discount_amount`
    - `total_shipping_discount_tax_amount`
    - `total_shipping_price_amount`
    - `total_shipping_tax_amount`
    - `total_promotion_discount_amount`
    - `total_promotion_discount_tax_amount`
  - In the `amazon_selling_partner__order_item` end model:
    - `order_total_amount`
    - `item_price_amount`
    - `item_tax_amount`
    - `shipping_discount_amount`
    - `shipping_discount_tax_amount`
    - `shipping_price_amount`
    - `shipping_tax_amount`
    - `promotion_discount_amount`
    - `promotion_discount_tax_amount`

## Under the Hood
- Added the `convert_string_to_numeric` [macro](https://github.com/fivetran/dbt_amazon_selling_partner/tree/main/macros/convert_string_to_numeric.sql) to support the above bug fix.
- Added consistency data validation tests for the `amazon_selling_partner__orders` and `amazon_selling_partner__order_items` end models.

# dbt_amazon_selling_partner v0.1.0
This is the initial release of the Amazon Selling Partner dbt package!

## What does this dbt package do?

This package models Amazon Selling Partner data from [Fivetran's connector](https://fivetran.com/docs/applications/amazon-selling-partner). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/amazon-selling-partner#schemainformation), specifically the **ORDERS**, **CATALOG**, and **FBA** Seller Central modules.

> This package is currently not compatible with any [Vendor Central modules](https://fivetran.com/docs/connectors/applications/amazon-selling-partner#vendormodules). If you would like to see Vendor Central compatibility (or the use of any other [Seller Central modules](https://fivetran.com/docs/connectors/applications/amazon-selling-partner#sellermodules)), please open up a Feature Request.

The main focus of the package is to transform core Seller Central object tables into analytics-ready models, including:
  - Materializes [Amazon Selling Partner staging tables](https://fivetran.github.io/dbt_amazon_selling_partner/#!/overview/amazon_selling_partner_source/models/?g_v=1) which leverage data in the format described by the **ORDERS**, **CATALOG**, and **FBA** Seller Central modules from [this ERD](https://fivetran.com/docs/applications/amazon-selling-partner/#schemainformation). These staging tables clean, test, and prepare your Amazon Selling Partner data from [Fivetran's connector](https://fivetran.com/docs/applications/amazon-selling-partner) for analysis by doing the following:
  - Names columns for consistency across all packages and for easier analysis
      - Primary keys are renamed from `_fivetran_id` to `<table name>_id`.
      - Foreign key names explicitly map onto their related tables (ie `owner_id` -> `owner_user_id`).
      - Datetime fields are renamed to `<event happened>_at`.
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
  - Generates a comprehensive data dictionary of your Amazon Selling Partner data through the [dbt docs site](https://fivetran.github.io/dbt_amazon_selling_partner/).
  - Enables you to better analyze your Amazon Seller data by enriching the orders, order items, and listed items with catalog information and sales and current inventory aggregates.

> This package does not apply freshness tests to source data due to the variability of survey cadences.

The following table provides a detailed list of all models materialized within this package by default. 
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_amazon_selling_partner/#!/overview/amazon_selling_partner).

| **model**                 | **description**                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [amazon_selling_partner__orders](https://fivetran.github.io/dbt_amazon_selling_partner/#!/model/model.amazon_selling_partner.amazon_selling_partner__orders)  | Table of orders placed in Amazon, enhanced with payment method information and order item aggregates.    |
| [amazon_selling_partner__order_items](https://fivetran.github.io/dbt_amazon_selling_partner/#!/model/model.amazon_selling_partner.amazon_selling_partner__order_items)  | Table of single line items of Amazon orders, enhanced with order and catalog item information.   |
| [amazon_selling_partner__item_inventory](https://fivetran.github.io/dbt_amazon_selling_partner/#!/model/model.amazon_selling_partner.amazon_selling_partner__item_inventory)  | Table containing current inventory levels pertaining to individual Amazon catalog items, enhanced with all product descriptors and identifiers, listing metadata, item dimensions, and sales ranks.   |
