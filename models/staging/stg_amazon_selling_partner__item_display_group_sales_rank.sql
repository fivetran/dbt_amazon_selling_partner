{{ config(enabled=var('amazon_selling_partner__using_catalog_module', true)) }}

{% set base_table = ref('stg_amazon_selling_partner__item_display_group_sales_rank_base') if var('amazon_selling_partner_sources',[]) != [] else source('amazon_selling_partner', 'item_display_group_sales_rank') %}

with base as (

    select * 
    from {{ base_table }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(base_table),
                staging_columns=get_item_display_group_sales_rank_columns()
            )
        }}
        
        {{ amazon_selling_partner_apply_source_relation() }}
        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        asin,
        link,
        rank,
        title,
        website_display_group
    from fields
)

select *
from final
