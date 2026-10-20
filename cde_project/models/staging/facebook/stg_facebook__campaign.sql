with source as (

    select * from {{ source('facebook', 'campaign') }}

),

renamed as (

    select
        cast(campaign_id as string)       as campaign_id,
        trim(campaign_name)               as campaign_name,
        campaign_updated_at
    from source

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by campaign_id
            order by campaign_updated_at desc nulls last
        ) as row_num
    from renamed

)

select
    campaign_id,
    campaign_name,
    campaign_updated_at
from deduplicated
where row_num = 1
