{% set base_table = ref('stg_amazon_selling_partner__financial_charge_component_base') if var('amazon_selling_partner_sources',[]) != [] else source('amazon_selling_partner', 'financial_charge_component') %}

with base as (

    select * 
    from {{ base_table }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(base_table),
                staging_columns=get_financial_charge_component_columns()
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
        charge_kind,
        charge_type,
        currency_amount,
        currency_code,
        index,
        linked_to,
        linked_to_id
    from fields
)

select *
from final
