{{ config(materialized='table') }}

-- Grain: one row per platform, ad, day and country.
-- country_code is null for Facebook (not reported at country level).
-- spend is in currency_code: convert before summing across currencies.

with marketing_ads as (

    select * from {{ ref('int_marketing_ads') }}

)

select
    {{ dbt_utils.generate_surrogate_key([
        'platform',
        'ad_id',
        'report_date',
        'country_code',
    ]) }}                                                       as marketing_spend_id,
    platform,
    report_date,
    account_id,
    account_name,
    campaign_id,
    campaign_name,
    ad_group_id,
    ad_group_name,
    ad_id,
    ad_name,
    ad_status,
    country_code,
    currency_code,
    spend,
    impressions,
    clicks,
    cast(try_divide(clicks, impressions) as decimal(18, 6))      as ctr,
    cast(try_divide(spend, clicks) as decimal(18, 6))            as cpc,
    cast(try_divide(spend * 1000, impressions) as decimal(18, 6)) as cpm
from marketing_ads
