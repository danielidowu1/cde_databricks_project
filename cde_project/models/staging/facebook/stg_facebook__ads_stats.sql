with source as (

    select * from {{ source('facebook', 'ads_stats') }}

)

select
    cast(ad_id as string)                 as ad_id,
    cast(account_id as string)            as account_id,
    ad_date                               as report_date,
    cast(ad_spend as decimal(18, 6))      as spend,
    {{ clean_count('ad_impressions') }}   as impressions,
    {{ clean_count('ad_clicks') }}        as clicks
from source