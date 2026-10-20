-- Facebook daily ad stats enriched with ad, ad group, campaign and account
-- attributes, shaped to the common marketing schema.

with stats as (

    select * from {{ ref('stg_facebook__ads_stats') }}

),

ads as (

    select * from {{ ref('stg_facebook__ads') }}

),

ad_groups as (

    select * from {{ ref('stg_facebook__adgroup') }}

),

campaigns as (

    select * from {{ ref('stg_facebook__campaign') }}

),

accounts as (

    select * from {{ ref('stg_facebook__account') }}

)

select
    'facebook'                    as platform,
    stats.report_date,
    stats.account_id,
    accounts.account_name,
    ads.campaign_id,
    campaigns.campaign_name,
    ads.ad_group_id,
    ad_groups.ad_group_name,
    stats.ad_id,
    ads.ad_name,
    ads.ad_status,
    cast(null as string)          as country_code,
    accounts.currency_code,
    stats.spend,
    stats.impressions,
    stats.clicks
from stats
left join ads
    on stats.ad_id = ads.ad_id
left join ad_groups
    on ads.ad_group_id = ad_groups.ad_group_id
left join campaigns
    on ads.campaign_id = campaigns.campaign_id
left join accounts
    on stats.account_id = accounts.account_id
