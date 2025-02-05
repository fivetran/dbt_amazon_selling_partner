with orders as (

    select *
    from {{ ref('stg_amazon_selling_partner__orders')}}
),

order_item as (

    select *
    from {{ ref('stg_amazon_selling_partner__order_item') }}
),

aggregate_order_items as (

    select 
        source_relation,
        amazon_order_id,
        count(distinct order_item_id) as count_order_items,
        sum(coalesce(item_price_amount, 0)) as total_item_price_amount,
        {{ fivetran_utils.string_agg('distinct item_price_currency_code', "', '") }} as item_price_currency_code,
        sum(coalesce(item_tax_amount, 0)) as total_item_tax_amount,
        {{ fivetran_utils.string_agg('distinct item_tax_currency_code', "', '") }} as item_tax_currency_code,
        sum(coalesce(shipping_discount_amount, 0)) as total_shipping_discount_amount,
        {{ fivetran_utils.string_agg('distinct shipping_discount_currency_code', "', '") }} as shipping_discount_currency_code,
        sum(coalesce(shipping_discount_tax_amount, 0)) as total_shipping_discount_tax_amount,
        {{ fivetran_utils.string_agg('distinct shipping_discount_tax_currency_code', "', '") }} as shipping_discount_tax_currency_code,
        sum(coalesce(shipping_price_amount, 0)) as total_shipping_price_amount,
        {{ fivetran_utils.string_agg('distinct shipping_price_currency_code', "', '") }} as shipping_price_currency_code,
        sum(coalesce(shipping_tax_amount, 0)) as total_shipping_tax_amount,
        {{ fivetran_utils.string_agg('distinct shipping_tax_currency_code', "', '") }} as shipping_tax_currency_code,
        sum(coalesce(promotion_discount_amount, 0)) as total_promotion_discount_amount,
        {{ fivetran_utils.string_agg('distinct promotion_discount_currency_code', "', '") }} as promotion_discount_currency_code,
        sum(coalesce(promotion_discount_tax_amount, 0)) as total_promotion_discount_tax_amount,
        {{ fivetran_utils.string_agg('distinct promotion_discount_tax_currency_code', "', '") }} as promotion_discount_tax_currency_code

    from order_item
    group by 1,2
),

joined as (

    select 
        orders.*,
        aggregate_order_items.count_order_items,
        aggregate_order_items.total_item_price_amount,
        aggregate_order_items.item_price_currency_code,
        aggregate_order_items.total_item_tax_amount,
        aggregate_order_items.item_tax_currency_code,
        aggregate_order_items.total_shipping_discount_amount,
        aggregate_order_items.shipping_discount_currency_code,
        aggregate_order_items.total_shipping_discount_tax_amount,
        aggregate_order_items.shipping_discount_tax_currency_code,
        aggregate_order_items.total_shipping_price_amount,
        aggregate_order_items.shipping_price_currency_code,
        aggregate_order_items.total_shipping_tax_amount,
        aggregate_order_items.shipping_tax_currency_code,
        aggregate_order_items.total_promotion_discount_amount,
        aggregate_order_items.promotion_discount_currency_code,
        aggregate_order_items.total_promotion_discount_tax_amount,
        aggregate_order_items.promotion_discount_tax_currency_code

    from orders 
    left join aggregate_order_items
        on orders.amazon_order_id = aggregate_order_items.amazon_order_id
        and orders.source_relation = aggregate_order_items.source_relation
)

select *
from joined