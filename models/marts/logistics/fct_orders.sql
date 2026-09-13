-- FULFILLMENT TIME (ON-TIME DELIVERY RATE)

 select 
    order_id,
    customer_id, 
    purchased_at, 
    delivered_to_customer_at, 
    estimated_at, 

    date_diff('day', purchased_at, delivered_to_customer_at) as fulfillment_days, 
    case when delivered_to_customer_at <= estimated_at then 1 else 0 end as delivered_on_time


from {{ ref ('stg_orders') }}
where delivered_to_customer_at is not null 

