select
    product_id,
    product_category_name
from {{ ref('olist_products_dataset') }}
