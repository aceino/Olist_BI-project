with orders as ( 
    select * from {{ ref('stg_orders') }}
), 

order_items as ( 
    select * from {{ref('stg_order_items') }}
), 

customer as ( 
    select * from {{ref('stg_customers')}}
),

order_total as ( 
    select 
        order_id, 
        sum(price) as order_value
    from order_items 
    
    group by order_id 
), 

joined as ( 
     select
        c.customer_unique_id,
        o.order_id,
        o.purchased_at,
        ot.order_value

    from orders as o
    left join order_total as ot
        on o.order_id = ot.order_id
    left join customer as c
        on o.customer_id = c.customer_id

)

select * from joined