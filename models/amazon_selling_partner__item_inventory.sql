{{ config(enabled=var('amazon_selling_partner__using_catalog_module', true)) }}

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
    from {{ ref('stg_amazon_selling_partner__fba_inventory_researching') }}
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
        -- Open Q: should we include all item columns? I lean towards yes as this is kinda an item_enhacned model
        item.*, 

        -- Open Q: should we include all fba_inventory_summary columns?
        fba_inventory_summary.inventory_summary_id,
        fba_inventory_summary.fn_sku,
        fba_inventory_summary.seller_sku,
        fba_inventory_summary.product_name,
        fba_inventory_summary.condition,
        fba_inventory_summary.granularity_id,
        fba_inventory_summary.granularity_type,
        fba_inventory_summary.last_updated_time,
        fba_inventory_summary.total_quantity,
        fba_inventory_summary.total_researching_quantity,
        fba_inventory_summary.total_reserved_quantity,
        fba_inventory_summary.fullfillable_quantity,
        fba_inventory_summary.total_unfulfillable_quantity,
        fba_inventory_summary.pending_customer_order_quantity,
        fba_inventory_summary.pending_transshipment_quantity,
        fba_inventory_summary.fc_processing_quantity,
        fba_inventory_summary.inblound_shipped_quantity,
        fba_inventory_summary.inbound_receiving_quantity,
        fba_inventory_summary.inbound_working_quantity,
        fba_inventory_summary.warehouse_damaged_quantity,
        fba_inventory_summary.carrier_damaged_quantity,
        fba_inventory_summary.customer_damaged_quantity,
        fba_inventory_summary.defective_quantity,
        fba_inventory_summary.distributor_damaged_quantity,
        fba_inventory_summary.expired_quantity,

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