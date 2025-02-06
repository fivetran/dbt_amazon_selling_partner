{{ config(enabled=var('amazon_selling_partner__using_orders_module', true)) }}

with orders as (

    select *
    from {{ ref('stg_amazon_selling_partner__orders') }}
),

order_item as (

    select *
    from {{ ref('stg_amazon_selling_partner__order_item') }}
),

{% if var('amazon_selling_partner__using_catalog_module', true) %}
{# Open Q: Should we bring item in here?  #}
item as (

    select *
    from {{ ref('int_amazon_selling_partner__item') }}
),
{% endif %}

order_item_promotion_id as (
    
    select *
    from {{ ref('stg_amazon_selling_partner__order_item_promotion_id') }}
),

aggregate_promotions as (

    select 
        source_relation,
        amazon_order_id,
        order_item_id,
        count(distinct promotion_id) as count_promotions_used

    from order_item_promotion_id 
    group by 1,2,3
),

joined as (

    select 
        order_item.*,
        {# Open Q: What other order/header level fields would be useful to have here? #}
        orders.purchase_date as order_purchase_date,
        orders.order_total_amount, 
        orders.order_status,
        orders.order_total_currency_code,
        orders.marketplace_id,

        aggregate_promotions.count_promotions_used,

        {# Open Q: Which item columns (if any) should we bring in here? #}
        {% if var('amazon_selling_partner__using_catalog_module', true) %}
        item.item_name,
        item.display_name,
        item.brand,
        item.color,
        item.size,
        item.style,
        item.product_type,
        item.package_quantity,
        item.manufacturer,
        item.contributors,
        item.item_classification,
        item.classification_id,
        item.classification_link,
        item.classification_sales_rank,
        item.website_display_group,
        item.website_display_group_name,
        item.website_display_group_link,
        item.website_display_group_sales_rank,
        item.is_memorabilia,
        item.release_date,
        item.is_adult_product,
        item.is_autographed,
        item.is_trade_in_eligible,
        item.model_number,
        item.part_number,
        item.ean,
        item.gtin,
        item.isbn,
        item.jan,
        item.minsan,
        item.upc,
        item.count_images,
        item.count_swatch_images,
        item.package_height_unit,
        item.package_height_value,
        item.package_length_unit,
        item.package_length_value,
        item.package_weight_unit,
        item.package_weight_value,
        item.package_width_unit,
        item.package_width_value
        {% endif %}

    from order_item 
    {% if var('amazon_selling_partner__using_catalog_module', true) %}
    left join item 
        on order_item.asin = item.asin 
        and order_item.source_relation = item.source_relation
    {% endif %}
    left join orders 
        on order_item.amazon_order_id = orders.amazon_order_id
        and order_item.source_relation = orders.source_relation
    left join aggregate_promotions
        on order_item.amazon_order_id = aggregate_promotions.amazon_order_id
        and order_item.order_item_id = aggregate_promotions.order_item_id
        and order_item.source_relation = aggregate_promotions.source_relation
)

select *
from joined