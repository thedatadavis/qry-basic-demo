with items as (
    select
        i.order_id,
        count(*) as item_count,
        count(distinct i.product_id) as distinct_product_count,
        count(distinct i.seller_id) as distinct_seller_count,
        sum(i.price) as item_value,
        sum(i.freight_value) as freight_value
    from {{ ref('stg_items') }} as i
    group by i.order_id
),

payments as (
    select
        p.order_id,
        sum(p.payment_value) as payment_value
    from {{ ref('stg_payments') }} as p
    group by p.order_id
),

reviews as (
    select
        r.order_id,
        avg(r.review_score) as review_score,
        max(
            case
                when
                    coalesce(r.review_comment_title, '') <> ''
                    or coalesce(r.review_comment_message, '') <> ''
                    then 1
                else 0
            end
        ) as review_comment_present
    from {{ ref('stg_reviews') }} as r
    group by r.order_id
)

select
    o.order_id,
    c.customer_unique_id,
    c.customer_state,
    o.order_purchase_at,
    o.order_approved_at,
    o.order_shipped_at,
    o.order_delivered_at,
    o.order_expected_delivery_at,
    o.order_status,
    case
        when o.order_delivered_at is not null and o.order_expected_delivery_at is not null
            then datediff('day', o.order_expected_delivery_at, o.order_delivered_at)
    end as delivery_delay_days,
    case
        when
            o.order_delivered_at is not null and o.order_expected_delivery_at is not null
            and o.order_delivered_at > o.order_expected_delivery_at then true
        else false
    end as is_late,
    case
        when
            o.order_delivered_at is null and o.order_status not in ('canceled', 'unavailable')
            then true
        else false
    end as is_undelivered,
    case when o.order_status = 'canceled' then true else false end as is_canceled,
    coalesce(p.payment_value, i.item_value, 0) as order_value,
    coalesce(i.freight_value, 0) as freight_value,
    coalesce(i.item_count, 0) as item_count,
    coalesce(i.distinct_product_count, 0) as distinct_product_count,
    coalesce(i.distinct_seller_count, 0) as distinct_seller_count,
    r.review_score,
    coalesce(r.review_comment_present, 0) = 1 as review_comment_present,
    case
        when
            (o.order_delivered_at is null and o.order_status not in ('canceled', 'unavailable'))
            or (
                o.order_delivered_at is not null
                and o.order_expected_delivery_at is not null
                and o.order_delivered_at > o.order_expected_delivery_at
            )
            or o.order_status = 'canceled' then true
        else false
    end as requires_attention,
    case
        when o.order_status = 'canceled' then 'canceled'
        when
            o.order_delivered_at is null and o.order_status not in ('canceled', 'unavailable')
            then 'undelivered'
        when o.order_delivered_at > o.order_expected_delivery_at then 'late_delivery'
    end as attention_reason,
    current_timestamp as snapshot_updated_at
from {{ ref('stg_orders') }} as o
inner join {{ ref('stg_customers') }} as c on o.customer_id = c.customer_id
left join items as i on o.order_id = i.order_id
left join payments as p on o.order_id = p.order_id
left join reviews as r on o.order_id = r.order_id
