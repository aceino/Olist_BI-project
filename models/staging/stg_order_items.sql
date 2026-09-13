with source as ( 
    select * from {{ source("olist", "olist_order_items_dataset") }}
)

select 
    order_id,
    order_item_id,
    product_id, 
    seller_id, 
    price,
    cast (freight_value as float) as freight_value, 
    cast(shipping_limit_date as timestamp) as shipping_limit_at

from source 