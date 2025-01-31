
with base as (

    select * 
    from {{ ref('stg_amazon_selling_partner__fba_inventory_summary_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_amazon_selling_partner__fba_inventory_summary_base')),
                staging_columns=get_fba_inventory_summary_columns()
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
        asin,
        carrier_damaged_quantity,
        condition,
        customer_damaged_quantity,
        defective_quantity,
        distributor_damaged_quantity,
        expired_quantity,
        fc_processing_quantity,
        fn_sku,
        fullfillable_quantity,
        granularity_id,
        granularity_type,
        inblound_shipped_quantity,
        inbound_receiving_quantity,
        inbound_working_quantity,
        last_updated_time,
        pending_customer_order_quantity,
        pending_transshipment_quantity,
        product_name,
        seller_sku,
        total_quantity,
        total_researching_quantity,
        total_reserved_quantity,
        total_unfulfillable_quantity,
        warehouse_damaged_quantity
    from fields
)

select *
from final
