{{ config(enabled=var('amazon_selling_partner__using_orders_module', true)) }}

{% set base_table = ref('stg_amazon_selling_partner__payment_method_detail_item_base') if var('amazon_selling_partner_sources',[]) != [] else source('amazon_selling_partner', 'payment_method_detail_item') %}

with base as (

    select * 
    from {{ base_table }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(base_table),
                staging_columns=get_payment_method_detail_item_columns()
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
        amazon_order_id,
        method
    from fields
)

select *
from final
