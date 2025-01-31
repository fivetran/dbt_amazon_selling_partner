
with base as (

    select * 
    from {{ ref('stg_amazon_selling_partner__item_classification_sales_rank_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_amazon_selling_partner__item_classification_sales_rank_base')),
                staging_columns=get_item_classification_sales_rank_columns()
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
        classification_id,
        link,
        rank,
        title
    from fields
)

select *
from final
