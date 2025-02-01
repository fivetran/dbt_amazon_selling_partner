with orders as (

    select *
    from {{ ref('stg_amazon_selling_partner__orders') }}
),

order_item as (

    select *
    from {{ ref('stg_amazon_selling_partner__order_item') }}
),

item as (

    select *
    from {{ ref('int_amazon_selling_partner__item') }}
),

joined as (

    select 
        order_item.*,
        item.*,
        order.order_status,
        order.purchase_date
        order.marketplace_id
        
    from order_item 
    left join item 
        on order_item.asin = item.asin 
        and order_item.source_relation = item.source_relation
    left join order 
        on order_item.amazon_order_id = order.amazon_order_id
        and order_item.source_relation = order.source_relation
)