with order_base as (
    select
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_at,
        o.order_approved_at,
        o.order_shipped_at,
        o.order_delivered_at
    from {{ ref('stg_orders') }} as o
    inner join {{ ref('stg_customers') }} as c on o.customer_id = c.customer_id
),

review_activities as (
    select
        c.customer_unique_id,
        o.order_id,
        'reviewed_order' as activity_name,
        r.review_created_at as activity_at
    from {{ ref('stg_reviews') }} as r
    inner join {{ ref('stg_orders') }} as o on r.order_id = o.order_id
    inner join {{ ref('stg_customers') }} as c on o.customer_id = c.customer_id
    where r.review_created_at is not null
)

select
    customer_unique_id,
    order_id,
    'placed_order' as activity_name,
    order_purchase_at as activity_at
from order_base
where order_purchase_at is not null
union all
select
    customer_unique_id,
    order_id,
    'approved_order' as activity_name,
    order_approved_at as activity_at
from order_base
where order_approved_at is not null
union all
select
    customer_unique_id,
    order_id,
    'shipped_order' as activity_name,
    order_shipped_at as activity_at
from order_base
where order_shipped_at is not null
union all
select
    customer_unique_id,
    order_id,
    'delivered_order' as activity_name,
    order_delivered_at as activity_at
from order_base
where order_delivered_at is not null
union all
select * from review_activities
