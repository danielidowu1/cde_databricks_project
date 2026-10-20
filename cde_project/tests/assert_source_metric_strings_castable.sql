-- Flags any raw count value that is present but cannot be cast to bigint.
-- clean_count() turns those into 0, so this test is what stops them being
-- lost silently. Common null tokens ('', 'null', 'none', 'nan') are allowed.
-- Severity is warn so one bad value does not block the mart; check the
-- returned rows if it warns.

{{ config(severity='warn') }}

{%- set checks = [
    ('facebook', 'ads_stats', 'ad_impressions'),
    ('facebook', 'ads_stats', 'ad_clicks'),
    ('snapchat', 'snapchat_ads_stats', 'ad_clicks'),
] -%}

{% for source_name, table_name, column_name in checks %}

select
    '{{ source_name }}.{{ table_name }}'    as source_table,
    '{{ column_name }}'                     as column_name,
    {{ column_name }}                       as raw_value
from {{ source(source_name, table_name) }}
where {{ column_name }} is not null
  and lower(trim({{ column_name }})) not in ('', 'null', 'none', 'nan')
  and try_cast(trim({{ column_name }}) as bigint) is null

{% if not loop.last %}union all{% endif %}

{% endfor %}
