select
    i.seller_id,
    any_value(s.seller_city) as seller_city,
    any_value(s.seller_state) as seller_state,
    min(o.order_purchase_at) as first_order_at,
    max(o.order_purchase_at) as last_order_at,
    count(distinct o.order_id) as lifetime_orders,
    sum(i.price) as lifetime_revenue,
    avg(o.order_value) as average_order_value,
    count(*) as items_sold,
    count(distinct o.customer_unique_id) as distinct_customers,
    count(distinct i.product_id) as distinct_products,
    avg(o.review_score) as average_review_score,
    avg(case when o.is_late then 1.0 else 0.0 end) as late_delivery_rate,
    avg(case when o.is_canceled then 1.0 else 0.0 end) as cancellation_rate,
    sum(case when o.is_undelivered then 1 else 0 end) as open_order_count,
    sum(case when o.requires_attention then 1 else 0 end) as at_risk_order_count,
    sum(case when o.requires_attention then 1 else 0 end) > 0 as requires_attention,
    case
        when sum(case when o.is_undelivered then 1 else 0 end) > 0 then 'open_orders'
        when avg(case when o.is_late then 1.0 else 0.0 end) > 0 then 'late_delivery'
        when avg(case when o.is_canceled then 1.0 else 0.0 end) > 0 then 'cancellations'
    end as attention_reason,
    current_timestamp as snapshot_updated_at
from {{ ref('stg_items') }} as i
inner join {{ ref('int_order_snapshot') }} as o on i.order_id = o.order_id
left join {{ ref('stg_sellers') }} as s on i.seller_id = s.seller_id
group by i.seller_id
