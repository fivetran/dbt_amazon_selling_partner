{{ config(enabled=false) }}

{# I think for this model I need to add some more source tables, namely financial shipment event ones #}

with order_item as (

    select *
    from {{ ref('amazon_selling_partner__order_items') }}
    {# I've been avoiding selecting from other end models but this does make the code DRYer #}
),

date_spine as (

    select *
    from {{ ref('int_amazon_selling_partner__date_spine') }}
),

item as (

    select *
    from {{ ref('int_amazon_selling_partner__item') }}
),

aggregate_orders_on_purchase as (

    select 
        source_relation,
        purchase_date, 
        count(distinct amazon_order_id) as count_orders,
        count(distinct (amazon_order_id || '-' || order_item_id)) as count_order_items,
        {# sum up amounts, but what to do with currencies here? #}
        
    from order_item 
),

aggregate_orders_on_delivery as (

    latest_delivery_date,
    {# metrics around items_ #}
),

aggregate_orders_on_shipping