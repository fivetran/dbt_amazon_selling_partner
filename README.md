# Amazon Selling Partner dbt Package ([Docs](https://fivetran.github.io/dbt_amazon_selling_partner/))

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_amazon_selling_partner/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

## What does this dbt package do?

This package models Amazon Selling Partner data from [Fivetran's connector](https://fivetran.com/docs/applications/amazon-selling-partner). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/amazon-selling-partner#schemainformation), **specifically the `ORDERS`, `CATALOG`, and `FBA` Seller Central modules.**

> This package is currently not compatible with any [Vendor Central modules](https://fivetran.com/docs/connectors/applications/amazon-selling-partner#vendormodules). If you would like to see Vendor Central compatibility (or the use of any other [Seller Central modules](https://fivetran.com/docs/connectors/applications/amazon-selling-partner#sellermodules)), please open up a Feature Request.

The main focus of the package is to transform core Seller Central object tables into analytics-ready models, including:
  - Materializes [Amazon Selling Partner staging tables](https://fivetran.github.io/dbt_amazon_selling_partner/#!/overview/amazon_selling_partner_source/models/?g_v=1) which leverage data in the format described by the `ORDERS`, `CATALOG`, and `FBA` Seller Central modules from [this ERD](https://fivetran.com/docs/applications/amazon-selling-partner/#schemainformation). These staging tables clean, test, and prepare your Amazon Selling Partner data from [Fivetran's connector](https://fivetran.com/docs/applications/amazon-selling-partner) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
      - Primary keys are renamed from `_fivetran_id` to `<table name>_id`.
      - Foreign key names explicitly map onto their related tables (ie `owner_id` -> `owner_user_id`).
      - Datetime fields are renamed to `<event happened>_at`.
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
  - Generates a comprehensive data dictionary of your Amazon Selling Partner data through the [dbt docs site](https://fivetran.github.io/dbt_amazon_selling_partner/).
  - [Insert additional custom details here.]

> This package does not apply freshness tests to source data due to the variability of survey cadences.

<!--section="amazon_selling_partner_model"-->
The following table provides a detailed list of all models materialized within this package by default. 
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_amazon_selling_partner/#!/overview/amazon_selling_partner).

| **model**                 | **description**                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [amazon_selling_partner__orders]()  | Model description   |
| [amazon_selling_partner__order_items]()  | Model description   |
| [amazon_selling_partner__item_inventory]()  | Model description   |
<!--section-end-->

## How do I use the dbt package?

### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Amazon Selling Partner connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

#### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Step 2: Install the package
Include the following Amazon Selling Partner package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/amazon_selling_partner
    version: [">=0.1.0", "<0.2.0"] # we recommend using ranges to capture non-breaking changes automatically
```

### Step 3: Define database and schema variables
#### Single connector
By default, this package runs using your destination and the `amazon_selling_partner` schema. If this is not where your Amazon Selling Partner data is (for example, if your Amazon Selling Partner schema is named `amazon_selling_partner_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    amazon_selling_partner_database: your_database_name
    amazon_selling_partner_schema: your_schema_name
```
#### Union multiple connectors
If you have multiple Amazon Selling Partner connectors in Fivetran and want to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `amazon_selling_partner_union_schemas` OR `amazon_selling_partner_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    amazon_selling_partner_union_schemas: ['amazon_selling_partner_usa','amazon_selling_partner_canada'] # use this if the data is in different schemas/datasets of the same database/project
    amazon_selling_partner_union_databases: ['amazon_selling_partner_usa','amazon_selling_partner_canada'] # use this if the data is in different databases/projects but uses the same schema name
```

The native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.


### Step 4: Enable/Disable Variables
[If necessary, use this step to detail enable/disable variables. See below as an example. If this is not necessary you can delete this section.]

By default, this package does not bring in data from the Amazon Selling Partner example source tables. However, if you want the package to bring in these sources and the downstream models, add the following configuration to your `dbt_project.yml`:

```yml
vars:
    amazon_selling_partner__using_core_contacts: True # default = False
    amazon_selling_partner__using_core_mailing_lists: True # default = False
```

### (Optional) Step 5: Additional configurations

[If necessary, use this step to detail passthrough variables. See below as an example. If this is not necessary you can delete this section.]
#### Passing Through Additional Fields
This package includes all source columns defined in the macros folder. You can add more columns using our pass-through column variables. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables:

```yml
# dbt_project.yml

vars:
  amazon_selling_partner__X_through_columns:
    - name: "that_field"
      alias: "renamed_to_this_field"
      transform_sql: "cast(renamed_to_this_field as string)"
  amazon_selling_partner__Y_pass_through_columns:
    - name: "this_field"
  amazon_selling_partner__Z_contact_pass_through_columns:
    - name: "old_name"
      alias: "new_name"
```

> Create an [issue](https://github.com/fivetran/dbt_amazon_selling_partner/issues) if you'd like to see passthrough column support for other tables in the Qualtrics schema.

#### Changing the Build Schema
By default this package will build the Amazon Selling Partner staging models within a schema titled (<target_schema> + `_stg_amazon_selling_partner`) and the Amazon Selling Partner final models within a schema titled (<target_schema> + `_amazon_selling_partner`) in your target database. If this is not where you want your modeled qualtrics data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

models:
  amazon_selling_partner:
    +schema: my_new_schema_name # leave blank for just the target_schema
    staging:
        +schema: my_new_schema_name # leave blank for just the target_schema
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_amazon_selling_partner/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
# dbt_project.yml

vars:
    amazon_selling_partner_<default_source_table_name>_identifier: your_table_name 
```
</details>


### (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>
    
Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>


## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
    
```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/amazon_selling_partner/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_amazon_selling_partner/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

## Are there any resources available?
- If you have questions or want to reach out for help, refer to the [GitHub Issue](https://github.com/fivetran/dbt_amazon_selling_partner/issues/new/choose) section to find the right avenue of support for you.
- If you want to provide feedback to the dbt package team at Fivetran or want to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to be part of the community discourse? Create a post in the [Fivetran community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) and our team along with the community can join in on the discussion.
