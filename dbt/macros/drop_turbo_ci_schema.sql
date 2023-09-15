{# dbt macro to delete BigQuery datasets created by paradime Turbo CI #}
{% macro drop_turbo_ci_schema(dryrun=True) %}

{# Get the bigquery catalog name and dataset name from information schema matching "paradime_turbo_ci%"  #}

{% set cleanup_query %}

      WITH TURBO_CI_DROP_SCHEMA AS (
                SELECT 
                    catalog_name, 
                    schema_name 
                FROM `dbt-demo-project.region-europe-west2.INFORMATION_SCHEMA.SCHEMATA`
                -- `<enter-here-the-bigquery-project-name>.region-<the-region-where-your-datasets-lives>.INFORMATION_SCHEMA.SCHEMATA` 
                -- replace the above using your own bigquery project + region -> should look something like this -> `demo-dbt-project.region-europe-west2.INFORMATION_SCHEMA.SCHEMATA` 
                WHERE schema_name LIKE "paradime_turbo_ci_pr%"
              ) 
      SELECT 
        'DROP SCHEMA ' || '`' || catalog_name || '.' || schema_name || '`' || ' CASCADE' || ';' as DROP_COMMANDS
      FROM 
        TURBO_CI_DROP_SCHEMA
  {% endset %}

{% set drop_commands = run_query(cleanup_query).columns[0].values() %}

{# Execute each of the drop commands for each matching schema #}

{% if drop_commands %}
  {% if dryrun | as_bool == False %}
    {% do log('Executing DROP commands...', True) %}
  {% else %}
    {% do log('Printing DROP commands...', True) %}
  {% endif %}
  {% for drop_command in drop_commands %}
    {% do log(drop_command, True) %}
    {% if dryrun | as_bool == False %}
      {% do run_query(drop_command) %}
    {% endif %}
  {% endfor %}
{% else %}
  {% do log('No relations to clean.', True) %}
{% endif %}

{%- endmacro -%}