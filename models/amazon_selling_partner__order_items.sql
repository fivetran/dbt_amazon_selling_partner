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
)