{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

order_payments as (

    select
        order_id,

        {% for payment_method in payment_methods -%}
        sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount,
        {% endfor -%}

        sum(amount) as total_amount

    from payments

    group by order_id

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,

        {% for payment_method in payment_methods -%}

        order_payments.{{ payment_method }}_amount,

        {% endfor -%}

        order_payments.total_amount as payment_amount

    from orders


    left join order_payments
        on orders.order_id = order_payments.order_id

)


select 

*,
    '{{ env_var("PARADIME_WORKSPACE_NAME", "manual") }}' as _audit_workspace_name,
    '{{ env_var("PARADIME_SCHEDULE_NAME", "manual") }}' as _audit_schedule_name,
    '{{ env_var("PARADIME_SCHEDULE_RUN_ID", "manual") }}' as _audit_schedule_run_id,
    '{{ env_var("PARADIME_SCHEDULE_RUN_START_DTTM", "manual") }}' as _audit_schedule_run_start_dttm,
    '{{ env_var("PARADIME_SCHEDULE_TRIGGER", "manual") }}' as _audit_schedule_trigger,
    '{{ env_var("PARADIME_SCHEDULE_GIT_SHA", "manual") }}' as _audit_schedule_git_sha,
    '{{ env_var("DBT_MODEL_GROUP", "manual") }}' as _audit_dbt_model_group,
    '{{ env_var("DBT_MODEL_ACCESS", "manual") }}' as _audit_dbt_model_access,
    '{{ env_var("DBT_MODEL_VERSION", "manual") }}' as _audit_dbt_model_version,
    '{{ env_var("DBT_MODEL_CONTRACT", "manual") }}' as _audit_dbt_model_contract
    

from final
