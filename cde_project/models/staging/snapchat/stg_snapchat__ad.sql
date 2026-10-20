with source as (

    select * from {{ source('snapchat', 'snapchat_ads_ad') }}

),

renamed as (

    select
        cast(ad_id as string)             as ad_id,
        cast(ad_group_id as string)       as ad_group_id,
        trim(ad_name)                     as ad_name,
        ad_detail_updated_at              as ad_updated_at
    from source

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by ad_id
            order by ad_updated_at desc nulls last
        ) as row_num
    from renamed

)

select
    ad_id,
    ad_group_id,
    ad_name,
    ad_updated_at
from deduplicated
where row_num = 1