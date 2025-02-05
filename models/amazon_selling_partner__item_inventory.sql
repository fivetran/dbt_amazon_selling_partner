with item as (

    select *
    from {{ ref('int_amazon_selling_partner__item') }}
),

fba_inventory_summary as (

    select *
    from {{ ref('stg_amazon_selling_partner__fba_inventory_summary') }}
),

fba_inventory_researching_quantity_entry as (
    select * 
    from {{ ref('stg_amazon_selling_partner__fba_inventory_researching_quantity_entry') }}
),

pivot_researching_quantity as (
    
    select 
        inventory_summary_id,
        source_relation,
        sum(case when lower(name) = 'researchingquantityinshortterm' then quantity else 0 end) as short_term_research_quantity,
        sum(case when lower(name) = 'researchingquantityinmidterm' then quantity else 0 end) as mid_term_research_quantity,
        sum(case when lower(name) = 'researchingquantityinlongterm' then quantity else 0 end) as long_term_research_quantity
    from fba_inventory_researching_quantity_entry
    group by 1,2
),

joined as (

    select 
        item.*, -- Open Q: should we include all columns?
        {{ dbt_utils.star(from=ref('stg_amazon_selling_partner__fba_inventory_summary'), except=["asin", "source_relation"], relation_alias='fba_inventory_summary') }},
        pivot_researching_quantity.short_term_research_quantity,
        pivot_researching_quantity.mid_term_research_quantity,
        pivot_researching_quantity.long_term_research_quantity

    from fba_inventory_summary
    join item 
        on fba_inventory_summary.asin = item.asin
        and fba_inventory_summary.source_relation = item.source_relation
    left join pivot_researching_quantity
        on fba_inventory_summary.inventory_summary_id = pivot_researching_quantity.inventory_summary_id
        and fba_inventory_summary.source_relation = pivot_researching_quantity.source_relation

)

select *
from joined