with customer_dim as (
    select
        c.customer_unique_id,
        any_value(c.customer_city) as customer_city,
        any_value(c.customer_state) as customer_state
    from {{ ref('stg_customers') }} as c
    group by c.customer_unique_id
),

base as (
    select
        o.*,
        row_number()
            over (
                partition by o.customer_unique_id
                order by o.order_purchase_at desc, o.order_id desc
            )
            as rn
    from {{ ref('int_order_snapshot') }} as o
),

customer_products as (
    select
        c.customer_unique_id,
        count(distinct i.product_id) as distinct_products,
        count(distinct p.product_category_name) as distinct_categories,
        count(distinct i.seller_id) as distinct_sellers
    from {{ ref('stg_items') }} as i
    inner join {{ ref('stg_orders') }} as o on i.order_id = o.order_id
    inner join {{ ref('stg_customers') }} as c on o.customer_id = c.customer_id
    left join {{ ref('stg_products') }} as p on i.product_id = p.product_id
    group by c.customer_unique_id
),

agg as (
    select
        b.customer_unique_id,
        min(b.order_purchase_at) as first_order_at,
        max(b.order_purchase_at) as last_order_at,
        count(*) as lifetime_orders,
        sum(b.order_value) as lifetime_revenue,
        avg(b.order_value) as average_order_value,
        sum(b.item_count) as total_items,
        avg(b.review_score) as average_review_score,
        count(b.review_score) as review_count,
        sum(case when b.is_late then 1 else 0 end) as late_delivery_count,
        sum(case when b.is_undelivered then 1 else 0 end) as undelivered_order_count,
        sum(case when b.is_canceled then 1 else 0 end) as canceled_order_count
    from base as b
    group by b.customer_unique_id
),

latest as (
    select b.* from base as b
    where b.rn = 1
)

select
    a.customer_unique_id,
    c.customer_city,
    c.customer_state,
    a.first_order_at,
    a.last_order_at,
    datediff('day', a.last_order_at, current_timestamp) as days_since_last_order,
    a.lifetime_orders,
    a.lifetime_revenue,
    a.average_order_value,
    a.total_items,
    cp.distinct_products,
    cp.distinct_categories,
    cp.distinct_sellers,
    a.average_review_score,
    a.review_count,
    a.late_delivery_count,
    a.undelivered_order_count,
    a.canceled_order_count,
    l.order_id as latest_order_id,
    l.order_status as latest_order_status,
    l.order_value as latest_order_value,
    l.order_purchase_at as latest_order_at,
    l.order_expected_delivery_at as latest_expected_delivery_at,
    l.order_delivered_at as latest_delivered_at,
    l.delivery_delay_days as latest_delivery_delay_days,
    a.late_delivery_count > 0
    or a.undelivered_order_count > 0
    or a.canceled_order_count > 0 as requires_attention,
    case
        when a.undelivered_order_count > 0 then 'undelivered_order'
        when a.late_delivery_count > 0 then 'late_delivery'
        when a.canceled_order_count > 0 then 'canceled_order'
    end as attention_reason,
    current_timestamp as snapshot_updated_at
from agg as a
inner join customer_dim as c on a.customer_unique_id = c.customer_unique_id
left join customer_products as cp on a.customer_unique_id = cp.customer_unique_id
inner join latest as l on a.customer_unique_id = l.customer_unique_id
order by a.lifetime_revenue desc, a.customer_unique_id asc
