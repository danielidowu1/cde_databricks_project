-- ad_detail_id is the ad identifier (it joins to snapchat_ads_ad.ad_id).
-- ad_spend is already in currency units, not Snapchat API micro-currency.

with source as (

    select * from {{ source('snapchat', 'snapchat_ads_stats') }}

)

select
    cast(ad_detail_id as string)          as ad_id,
    ad_date                               as report_date,
    upper(trim(ad_country))               as country_code,
    upper(trim(ad_currency_code))         as currency_code,
    cast(ad_spend as decimal(18, 6))      as spend,
    {{ clean_count('ad_impressions') }}   as impressions,
    {{ clean_count('ad_clicks') }}        as clicks,
    data_src                              as source_system
from source
