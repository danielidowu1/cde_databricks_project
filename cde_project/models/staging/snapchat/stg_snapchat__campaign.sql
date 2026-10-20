-- No timestamp column on this table, so exact duplicates are removed with
-- distinct. The unique test on campaign_id catches conflicting versions.

with source as (

    select * from {{ source('snapchat', 'snapchat_ads_campaign') }}

)

select distinct
    cast(campaign_id as string)           as campaign_id,
    cast(account_id as string)            as account_id,
    trim(campaign_name)                   as campaign_name
from source
