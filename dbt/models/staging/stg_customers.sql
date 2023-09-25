with source as (

    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ source('sheets', 'ingested_raw_customers') }}
    where id > 5
),

renamed as (

    select
        id as customer_id,
        first_name as customer_first_name,
        email
    from source

)

select * from renamed
