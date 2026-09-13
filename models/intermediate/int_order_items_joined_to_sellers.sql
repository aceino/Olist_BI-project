with orders as ( 
    select * from {{ ref ('stg_orders') }}
), 

order_items as ( 
    select * from {{ ref('stg_order_items') }}
), 

seller as ( 
    select * from {{ ref('stg_sellers') }}
), 

joined as ( 
    select 
        oi.order_id, 
        oi.seller_id, 
        oi.price,
        o.purchased_at, 
        o.delivered_to_customer_at
    
    from {{ ref('stg_order_items') }} as oi 
    left join {{ ref ('stg_sellers') }} as s 
        on oi.seller_id = s.seller_id 
    left join {{ ref('stg_orders') }} as o 
        on oi.order_id = o.order_id 
)

select * from joined 