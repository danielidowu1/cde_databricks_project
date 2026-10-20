with source as (

    select * from {{ source('snapchat', 'snapchat_ads_adgroup') }}

),

renamed as (

    -- _surrogate_key is an upstream loader column and is not carried forward
    select
        cast(ad_group_id as string)       as ad_group_id,
        cast(campaign_id as string)       as campaign_id,
        trim(ad_group_name)               as ad_group_name,
        ad_group_updated_at
    from source

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by ad_group_id
            order by ad_group_updated_at desc nulls last
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
