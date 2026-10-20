-- The raw adgroup table is denormalised (ad, campaign, account and daily
-- stats columns are repeated on every row). Only the ad group attributes
-- are taken here; stats come from ads_stats, the other entities from
-- their own tables.

with source as (

    select * from {{ source('facebook', 'adgroup') }}

),

renamed as (

    select
        cast(ad_group_id as string)       as ad_group_id,
        cast(campaign_id as string)       as campaign_id,
        trim(ad_group_name)               as ad_group_name,
        ad_group_updated_at
    from source
    where ad_group_id is not null

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by ad_group_id
            order by ad_group_updated_at desc nulls last, ad_group_name
        ) as row_num
    from renamed

)

select
    ad_group_id,
    campaign_id,
    ad_group_name,
    ad_group_updated_at
from deduplicated
where row_num = 1
