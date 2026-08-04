select
    seller_id,
    seller_city,
    seller_state
from {{ ref('olist_sellers_dataset') }}
