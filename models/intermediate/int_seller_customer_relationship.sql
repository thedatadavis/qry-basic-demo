select
    i.seller_id,
    o.customer_unique_id,
    any_value(o.customer_state) as customer_state,
    min(o.order_purchase_at) as first_order_at,
    max(o.order_purchase_at) as last_order_at,
    count(distinct o.order_id) as order_count,
    sum(i.price) as revenue,
    avg(o.order_value) as average_order_value,
    avg(o.review_score) as average_review_score,
    sum(case when o.is_late then 1 else 0 end) as late_order_count,
    avg(case when o.is_late then 1.0 else 0.0 end) as late_order_rate,
    max_by(o.order_id, o.order_purchase_at) as latest_order_id,
    max_by(o.order_status, o.order_purchase_at) as latest_order_status
from {{ ref('stg_items') }} as i
inner join {{ ref('int_order_snapshot') }} as o on i.order_id = o.order_id
group by i.seller_id, o.customer_unique_id
