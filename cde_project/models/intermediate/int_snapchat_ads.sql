-- Snapchat daily ad stats enriched with ad, ad group and campaign
-- attributes, shaped to the common marketing schema. Snapchat has no
-- account table and no ad status, so those columns are null.

with stats as (

    select * from {{ ref('stg_snapchat__stats') }}

),

ads as (

    select * from {{ ref('stg_snapchat__ad') }}

),

ad_groups as (

    select * from {{ ref('stg_snapchat__adgroup') }}

),

campaigns as (

    select * from {{ ref('stg_snapchat__campaign') }}

)

select
    'snapchat'                    as platform,
    stats.report_date,
    campaigns.account_id,
    cast(null as string)          as account_name,
    ad_groups.campaign_id,
    campaigns.campaign_name,
    ads.ad_group_id,
    ad_groups.ad_group_name,
    stats.ad_id,
    ads.ad_name,
    cast(null as string)          as ad_status,
    stats.country_code,
    stats.currency_code,
    stats.spend,
    stats.impressions,
    stats.clicks
from stats
left join ads
    on stats.ad_id = ads.ad_id
left join ad_groups
    on ads.ad_group_id = ad_groups.ad_group_id
left join campaigns
    on ad_groups.campaign_id = campaigns.campaign_id
