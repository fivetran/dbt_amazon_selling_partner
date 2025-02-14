{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with source as (

    select 
        count(*) as row_count,
        count(distinct amazon_order_id) as count_distinct_orders,
        count(distinct asin) as count_distinct_asin,
        count(distinct order_item_id) as count_distinct_order_items
        sum(coalesce(quantity_ordered, 0)) as quantity_ordered,
        sum(coalesce(quantity_shipped, 0)) as quantity_shipped,
        sum(coalesce(item_price_amount, 0)) as item_price_amount,
        sum(coalesce(item_tax_amount, 0)) as item_tax_amount,
        sum(coalesce(shipping_discount_amount, 0)) as shipping_discount_amount,
        sum(coalesce(shipping_discount_tax_amount, 0)) as shipping_discount_tax_amount,
        sum(coalesce(shipping_price_amount, 0)) as shipping_price_amount,
        sum(coalesce(shipping_tax_amount, 0)) as shipping_tax_amount,
        sum(coalesce(promotion_discount_amount, 0)) as promotion_discount_amount,
        sum(coalesce(promotion_discount_tax_amount, 0)) as promotion_discount_tax_amount

    from {{ target.schema }}_amazon_selling_partner_dev.stg_amazon_selling_partner__order_item
),

model as (

    select 
        count(*) as row_count,
        count(distinct amazon_order_id) as count_distinct_orders,
        count(distinct asin) as count_distinct_asin,
        count(distinct order_item_id) as count_distinct_order_items
        sum(coalesce(quantity_ordered, 0)) as quantity_ordered,
        sum(coalesce(quantity_shipped, 0)) as quantity_shipped,
        sum(coalesce(item_price_amount, 0)) as item_price_amount,
        sum(coalesce(item_tax_amount, 0)) as item_tax_amount,
        sum(coalesce(shipping_discount_amount, 0)) as shipping_discount_amount,
        sum(coalesce(shipping_discount_tax_amount, 0)) as shipping_discount_tax_amount,
        sum(coalesce(shipping_price_amount, 0)) as shipping_price_amount,
        sum(coalesce(shipping_tax_amount, 0)) as shipping_tax_amount,
        sum(coalesce(promotion_discount_amount, 0)) as promotion_discount_amount,
        sum(coalesce(promotion_discount_tax_amount, 0)) as promotion_discount_tax_amount

    from {{ target.schema }}_amazon_selling_partner_dev.amazon_selling_partner__order_items
)

select 
    model.row_count as model_row_count,
    source.row_count as source_row_count,
    model.count_distinct_orders as model_count_distinct_orders,
    source.count_distinct_orders as source_count_distinct_orders,
    model.count_distinct_asin as model_count_distinct_asin,
    source.count_distinct_asin as source_count_distinct_asin,
    model.count_distinct_order_items as model_count_distinct_order_items,
    source.count_distinct_order_items as source_count_distinct_order_items,
    model.quantity_ordered as model_quantity_ordered,
    source.quantity_ordered as source_quantity_ordered,
    model.quantity_shipped as model_quantity_shipped,
    source.quantity_shipped as source_quantity_shipped,
    model.item_price_amount as model_item_price_amount,
    source.item_price_amount as source_item_price_amount,
    model.item_tax_amount as model_item_tax_amount,
    source.item_tax_amount as source_item_tax_amount,
    model.shipping_discount_amount as model_shipping_discount_amount,
    source.shipping_discount_amount as source_shipping_discount_amount,
    model.shipping_discount_tax_amount as model_shipping_discount_tax_amount,
    source.shipping_discount_tax_amount as source_shipping_discount_tax_amount,
    model.shipping_price_amount as model_shipping_price_amount,
    source.shipping_price_amount as source_shipping_price_amount,
    model.shipping_tax_amount as model_shipping_tax_amount,
    source.shipping_tax_amount as source_shipping_tax_amount,
    model.promotion_discount_amount as model_promotion_discount_amount,
    source.promotion_discount_amount as source_promotion_discount_amount,
    model.promotion_discount_tax_amount as model_promotion_discount_tax_amount,
    source.promotion_discount_tax_amount as source_promotion_discount_tax_amount

from model 
join source on true
where 
    model.row_count != source.row_count
    model.count_distinct_orders != source.count_distinct_orders
    model.count_distinct_asin != source.count_distinct_asin
    model.count_distinct_order_items != source.count_distinct_order_items
    model.quantity_ordered != source.quantity_ordered
    model.quantity_shipped != source.quantity_shipped
    model.item_price_amount != source.item_price_amount
    model.item_tax_amount != source.item_tax_amount
    model.shipping_discount_amount != source.shipping_discount_amount
    model.shipping_discount_tax_amount != source.shipping_discount_tax_amount
    model.shipping_price_amount != source.shipping_price_amount
    model.shipping_tax_amount != source.shipping_tax_amount
    model.promotion_discount_amount != source.promotion_discount_amount
    model.promotion_discount_tax_amount != source.promotion_discount_tax_amount