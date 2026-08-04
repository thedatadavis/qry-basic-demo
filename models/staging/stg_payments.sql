select
    order_id,
    payment_type,
    payment_installments,
    payment_value
from {{ ref('olist_order_payments_dataset') }}
