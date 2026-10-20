-- Unions every platform model into one schema. To add a platform, build
-- int_<platform>_ads with the same columns and add it to the list below.

{%- set platform_models = ['int_facebook_ads', 'int_snapchat_ads'] -%}

{%- set columns = [
    'platform',
    'report_date',
    'account_id',
    'account_name',
    'campaign_id',
    'campaign_name',
    'ad_group_id',
    'ad_group_name',
    'ad_id',
    'ad_name',
    'ad_status',
    'country_code',
    'currency_code',
    'spend',
    'impressions',
    'clicks',
] %}

{% for platform_model in platform_models %}

select
    {{ columns | join(',\n    ') }}
from {{ ref(platform_model) }}

{% if not loop.last %}union all{% endif %}

{% endfor %}
