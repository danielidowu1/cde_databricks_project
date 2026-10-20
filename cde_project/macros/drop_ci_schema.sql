{#
    Drops this CI run's schema, plus any schema created with it as a
    prefix (for example ci_run_12_elementary). Called by the CI
    workflow after the build:

        dbt run-operation drop_ci_schema

    Guards: only runs on the ci target, and only on schemas named
    ci_run_<number> or ci_pr_<number>, so a wrong CI_SCHEMA value can
    never drop raw or dev data.
#}
{% macro drop_ci_schema() %}

    {% if target.name != 'ci' %}
        {{ exceptions.raise_compiler_error(
            "drop_ci_schema only runs on the ci target, not '" ~ target.name ~ "'"
        ) }}
    {% endif %}

    {% set ci_schema = target.schema | lower %}

    {% if not modules.re.match('^ci_(run|pr)_[0-9]+$', ci_schema) %}
        {{ exceptions.raise_compiler_error(
            "Refusing to drop schema '" ~ ci_schema ~ "': expected ci_run_<number> or ci_pr_<number>"
        ) }}
    {% endif %}

    {% set find_schemas %}
        select schema_name
        from `{{ target.database }}`.information_schema.schemata
        where lower(schema_name) = '{{ ci_schema }}'
           or startswith(lower(schema_name), '{{ ci_schema }}_')
    {% endset %}

    {% set schemas = run_query(find_schemas).columns[0].values() %}

    {% if schemas | length == 0 %}
        {% do log("No CI schema found for " ~ ci_schema ~ ", nothing to drop", info=true) %}
    {% endif %}

    {% for schema_name in schemas %}
        {% do log("Dropping " ~ target.database ~ "." ~ schema_name, info=true) %}
        {% do run_query(
            "drop schema if exists `" ~ target.database ~ "`.`" ~ schema_name ~ "` cascade"
        ) %}
    {% endfor %}

{% endmacro %}