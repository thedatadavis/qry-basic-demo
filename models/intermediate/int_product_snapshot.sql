select
    i.product_id,
    p.product_category_name,
    min(o.order_purchase_at) as first_order_at,
    max(o.order_purchase_at) as last_order_at,
    count(*) as units_sold,
    count(distinct i.order_id) as lifetime_orders,
    sum(i.price) as lifetime_revenue,
    avg(i.price) as average_sale_price,
    count(distinct o.customer_unique_id) as distinct_customers,
    count(distinct i.seller_id) as distinct_sellers,
    avg(o.review_score) as average_review_score,
    avg(case when o.is_late then 1.0 else 0.0 end) as late_delivery_rate,
    current_timestamp as snapshot_updated_at
from {{ ref('stg_items') }} as i
inner join {{ ref('int_order_snapshot') }} as o on i.order_id = o.order_id
left join {{ ref('stg_products') }} as p on i.product_id = p.product_id
group by i.product_id, p.product_category_name
