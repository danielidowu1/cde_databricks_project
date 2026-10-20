with source as (

    select * from {{ source('facebook', 'ads') }}

),

renamed as (

    select
        cast(ad_id as string)             as ad_id,
        cast(ad_group_id as string)       as ad_group_id,
        cast(campaign_id as string)       as campaign_id,
        cast(account_id as string)        as account_id,
        trim(ad_name)                     as ad_name,
        lower(trim(ad_status))            as ad_status,
        ad_updated_at
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
    campaign_id,
    account_id,
    ad_name,
    ad_status,
    ad_updated_at
from deduplicated
where row_num = 1
