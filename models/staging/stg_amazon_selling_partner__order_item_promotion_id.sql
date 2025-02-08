{{ config(enabled=var('amazon_selling_partner__using_orders_module', true)) }}

{% set base_table = ref('stg_amazon_selling_partner__order_item_promotion_id_base') if var('amazon_selling_partner_sources',[]) != [] else source('amazon_selling_partner', 'order_item_promotion_id') %}

with base as (

    select * 
    from {{ base_table }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(base_table),
                staging_columns=get_order_item_promotion_id_columns()
            )
        }}
        
        {{ amazon_selling_partner_apply_source_relation() }}
        
    from base
),

final as (
    
    select 
        source_relation, 
        amazon_order_id,
        order_item_id,
        promotion_id
    from fields
)

select *
from final
