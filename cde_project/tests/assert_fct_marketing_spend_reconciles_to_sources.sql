-- Row count and total spend per platform in fct_marketing_spend must match
-- the raw stats tables. Catches rows dropped or duplicated by the joins.

with source_totals as (

    select
        'facebook'                                as platform,
        count(*)                                  as row_count,
        sum(cast(ad_spend as decimal(18, 6)))     as spend
    from {{ source('facebook', 'ads_stats') }}

    union all

    select
        'snapchat'                                as platform,
        count(*)                                  as row_count,
        sum(cast(ad_spend as decimal(18, 6)))     as spend
    from {{ source('snapchat', 'snapchat_ads_stats') }}

),

model_totals as (

    select
        platform,
        count(*)                                  as row_count,
        sum(spend)                                as spend
    from {{ ref('fct_marketing_spend') }}
    group by platform

)

select
    coalesce(s.platform, m.platform)              as platform,
    s.row_count                                   as source_row_count,
    m.row_count                                   as model_row_count,
    s.spend                                       as source_spend,
    m.spend                                       as model_spend
from source_totals as s
full outer join model_totals as m
    on s.platform = m.platform
where coalesce(s.row_count, -1) <> coalesce(m.row_count, -1)
   or coalesce(s.spend, 0) <> coalesce(m.spend, 0)
