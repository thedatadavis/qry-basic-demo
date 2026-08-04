select
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
from {{ ref('olist_customers_dataset') }}
