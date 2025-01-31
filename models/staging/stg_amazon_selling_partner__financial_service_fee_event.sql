
with base as (

    select * 
    from {{ ref('stg_amazon_selling_partner__financial_service_fee_event_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_amazon_selling_partner__financial_service_fee_event_base')),
                staging_columns=get_financial_service_fee_event_columns()
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
        _fivetran_id,
        amazon_order_id,
        asin,
        fee_description,
        fee_reason,
        financial_event_group_id,
        fn_sku,
        seller_sku
    from fields
)

select *
from final
