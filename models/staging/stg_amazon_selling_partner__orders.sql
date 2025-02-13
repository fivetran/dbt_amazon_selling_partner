{{ config(enabled=var('amazon_selling_partner__using_orders_module', true)) }}

{% set base_table = ref('stg_amazon_selling_partner__orders_base') if var('amazon_selling_partner_sources',[]) != [] else source('amazon_selling_partner', 'orders') %}

with base as (

    select * 
    from {{ base_table }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(base_table),
                staging_columns=get_orders_columns()
            )
        }}
        
        {{ amazon_selling_partner_apply_source_relation() }}
        
    from base
),

final as (
    
    select 
        source_relation, 
        amazon_order_id,
        marketplace_id,
        replaced_order_id,
        seller_order_id,
        buyer_info_purchase_order_number,

        cast({{ dbt.date_trunc('day', 'purchase_date') }} as date) as purchase_date,
        sales_channel,
        order_channel,
        order_type,
        order_status,
        payment_method,
        order_total_amount,
        order_total_currency_code,
        cast({{ dbt.date_trunc('day', 'promise_response_due_date') }} as date) as promise_response_due_date,
        cast({{ dbt.date_trunc('day', 'last_update_date') }} as date) as last_update_date,
        cast({{ dbt.date_trunc('day', 'latest_delivery_date') }} as date) as latest_delivery_date,
        cast({{ dbt.date_trunc('day', 'latest_ship_date') }} as date) as latest_ship_date,
        number_of_items_shipped,
        number_of_items_unshipped,
        cast({{ dbt.date_trunc('day', 'earliest_delivery_date') }} as date) as earliest_delivery_date,
        cast({{ dbt.date_trunc('day', 'earliest_ship_date') }} as date) as earliest_ship_date,
        easy_ship_shipment_status,
        electronic_invoice_status,
        fulfillment_channel,
        fulfillment_supply_source_id,
        has_regulated_items,
        is_access_point_order,
        is_business_order,
        is_estimated_ship_date_set,
        is_global_express_enabled,
        is_iba,
        is_ispu,
        is_premium_order,
        is_prime,
        is_replacement_order,
        is_sold_by_ab,
        ship_service_level,
        shipment_service_level_category,
        automated_shipping_setting_automated_carrier,
        automated_shipping_setting_automated_ship_method,
        automated_shipping_setting_has_automated_shipping_settings,
        default_ship_from_location_address_line_1,
        default_ship_from_location_address_line_2,
        default_ship_from_location_address_line_3,
        default_ship_from_location_address_type,
        default_ship_from_location_city,
        default_ship_from_location_country_code,
        default_ship_from_location_county,
        default_ship_from_location_district,
        default_ship_from_location_municipality,
        default_ship_from_location_name,
        default_ship_from_location_phone,
        default_ship_from_location_postal_code,
        default_ship_from_location_state_or_region,
        
        {# Shipping address lines 1-3 are restricted by Amazon due to being PII #}
        shipping_address_address_type,
        shipping_address_city,
        shipping_address_country_code,
        shipping_address_county,
        shipping_address_district,
        shipping_address_municipality,
        shipping_address_postal_code,
        shipping_address_state_or_region

    from fields
)

select *
from final
