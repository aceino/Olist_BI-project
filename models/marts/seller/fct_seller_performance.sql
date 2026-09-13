with order_items_joined as (

    select * from {{ ref('int_order_items_joined_to_sellers') }}

),

seller_performance as (

    select
        seller_id,
        count(*) as total_items_sold,
        avg(datediff('day', purchased_at, delivered_to_customer_at)) as avg_fulfillment_days

    from order_items_joined
    where delivered_to_customer_at is not null
    group by seller_id

)

select * from seller_performance