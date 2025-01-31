
with base as (

    select * 
    from {{ ref('stg_amazon_selling_partner__financial_fee_component_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_amazon_selling_partner__financial_fee_component_base')),
                staging_columns=get_financial_fee_component_columns()
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
        currency_amount,
        currency_code,
        fee_kind,
        fee_type,
        index,
        linked_to,
        linked_to_id
    from fields
)

select *
from final
