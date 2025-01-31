{% macro get_catalog_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": "datetime"},
    {"name": "asin", "datatype": dbt.type_string()},
    {"name": "marketplace_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
