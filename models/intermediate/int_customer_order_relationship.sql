select
    customer_unique_id,
    order_id,
    order_purchase_at,
    order_status,
    order_value,
    delivery_delay_days,
    review_score,
    distinct_seller_count as seller_count,
    distinct_product_count as product_count,
    requires_attention,
    attention_reason
from {{ ref('int_order_snapshot') }}
