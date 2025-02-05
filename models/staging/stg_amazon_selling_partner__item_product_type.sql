{% set base_table = ref('stg_amazon_selling_partner__item_product_type_base') if var('amazon_selling_partner_sources',[]) != [] else source('amazon_selling_partner', 'item_product_type') %}

with base as (

    select * 
    from {{ base_table }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(base_table),
                staging_columns=get_item_product_type_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='amazon_selling_partner_union_schemas', 
            union_database_variable='amazon_selling_partner_union_databases') 
        }}
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        asin,
        marketplace_id,
        product_type
    from fields
)

select *
from final
