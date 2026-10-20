with source as (

    select * from {{ source('facebook', 'account') }}

),

renamed as (

    select
        cast(account_id as string)        as account_id,
        trim(account_name)                as account_name,
        upper(trim(ad_currency_code))     as currency_code,
        account_created_at,
        account_updated_at
    from source

),

-- cdc_stg can hold several versions of a record: keep the latest
deduplicated as (

    select
        *,
        row_number() over (
            partition by account_id
            order by account_updated_at desc nulls last
        ) as row_num
    from renamed

)

select
    account_id,
    account_name,
    currency_code,
    account_created_at,
    account_updated_at
from deduplicated
where row_num = 1
