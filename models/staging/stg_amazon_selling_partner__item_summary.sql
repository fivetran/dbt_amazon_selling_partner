{{ config(enabled=var('amazon_selling_partner__using_catalog_module', true)) }}

{% set base_table = ref('stg_amazon_selling_partner__item_summary_base') if var('amazon_selling_partner_sources',[]) != [] else source('amazon_selling_partner', 'item_summary') %}

with base as (

    select * 
    from {{ base_table }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(base_table),
                staging_columns=get_item_summary_columns()
            )
        }}
        
        {{ amazon_selling_partner_apply_source_relation() }}
        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        adult_product as is_adult_product,
        asin,
        autographed as is_autographed,
        brand,
        classification_id,
        color,
        contributors,
        display_name,
        item_classification,
        item_name,
        manufacturer,
        marketplace_id,
        memorabilia as is_memorabilia,
        model_number,
        package_quantity,
        part_number,
        cast({{ dbt.date_trunc('day', 'release_date') }} as date) as release_date,
        size,
        style,
        trade_in_eligible as is_trade_in_eligible,
        website_display_group,
        website_display_group_name
    from fields
)

select *
from final
