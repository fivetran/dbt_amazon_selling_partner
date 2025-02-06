with spine as (

    {% if execute and flags.WHICH in ('run', 'build') %}

    {%- set first_date_query %}
    select 
        coalesce(
            min(cast(purchase_date as date)), 
            cast({{ dbt.dateadd("month", -1, "current_date") }} as date)
            ) as min_date
    from {{ ref('stg_amazon_selling_partner__orders') }} -- Open Q: should we use items instead, since a shop will likely release items prior to having sales
    {% endset -%}

    {%- set first_date = dbt_utils.get_single_value(first_date_query) %}

    {% else %}
    {%- set first_date = '2016-01-01' %} -- is this a good default start date? 

    {% endif %}

{{
    dbt_utils.date_spine(
        datepart = "day", 
        start_date = "cast('" ~ first_date ~ "' as date)",
        end_date = dbt.dateadd("week", 1, "current_date")
    )   
}}

), recast as (
    select
        cast(date_day as date) as date_day
    from spine
)

select *
from recast