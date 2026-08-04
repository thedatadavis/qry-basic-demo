select
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    cast(review_creation_date as timestamp) as review_created_at,
    cast(review_answer_timestamp as timestamp) as review_answered_at
from {{ ref('olist_order_reviews_dataset') }}
