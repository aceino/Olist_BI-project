-- CLV (CUSTOMER LIFETIME VALUE)
-- the total revenue a customer generates across all their orders, not just one purchase.

with customer_orders as ( 
    select * from {{ ref('int_customer_order_value') }}
),

customer_ltv as ( 

    select 
        customer_unique_id,
        count(order_id) as total_orders, -- how many orders that customer has placed
        sum(order_value) as lifetime_value, -- this CLV itself, total revenue across every order        
        min(purchased_at) as first_purchase_at, 
        max(purchased_at) as last_purchase_at

    from customer_orders
    group by customer_unique_id
)

select * From customer_ltv