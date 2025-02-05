{% set base_table = ref('stg_amazon_selling_partner__order_item_base') if var('amazon_selling_partner_sources',[]) != [] else source('amazon_selling_partner', 'order_item') %}

with base as (

    select * 
    from {{ base_table }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(base_table),
                staging_columns=get_order_item_columns()
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
        order_item_id,
        asin,
        seller_sku,
        title,
        product_info_detail_number_of_items,
        scheduled_delivery_start_date,
        scheduled_delivery_end_date,
        quantity_ordered,
        quantity_shipped,

        item_price_amount,
        item_price_currency_code,
        item_tax_amount,
        item_tax_currency_code,
        shipping_discount_amount,
        shipping_discount_currency_code,
        shipping_discount_tax_amount,
        shipping_discount_tax_currency_code,
        shipping_price_amount,
        shipping_price_currency_code,
        shipping_tax_amount,
        shipping_tax_currency_code,
        promotion_discount_amount,
        promotion_discount_currency_code,
        promotion_discount_tax_amount,
        promotion_discount_tax_currency_code,

        condition_id,
        condition_note,
        condition_subtype_id,
        buyer_requested_cancel_buyer_cancel_reason as buyer_requested_cancel_reason,
        buyer_requested_cancel_is_buyer_requested_cancel as is_buyer_requested_cancel,

        deemed_reseller_category,
        ioss_number,
        is_gift,
        is_transparency,
        serial_number_required as is_serial_number_required, -- only populated for Easy Ship orders
        store_chain_store_id,
        tax_collection_model, -- always MarketplaceFacilitator in US
        tax_collection_responsible_party -- always Amazon Web Services in US

        {# item_approval_context_approval_status,
        item_approval_context_approval_type, #}

        {# points_granted_monetary_amount,
        points_granted_monetary_currency_code,
        points_granted_points_number, #}
        {# price_designation, #}
        
    from fields
)

select *
from final
