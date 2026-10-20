{#
    Casts a raw count metric (impressions, clicks) to bigint.
    Source counts arrive as strings on some tables, with null tokens such
    as 'null' and empty values. Unparseable and missing values become 0 so
    the metric stays additive. tests/assert_source_metric_strings_castable.sql
    warns if a non-null value cannot be cast, so nothing is lost silently.
#}
{% macro clean_count(column_name) -%}
    coalesce(try_cast(trim(cast({{ column_name }} as string)) as bigint), 0)
{%- endmacro %}
