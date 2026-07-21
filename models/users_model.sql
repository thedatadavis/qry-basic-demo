select
    user_id,
    first_name || ' ' || last_name as full_name,
    email
from {{ ref('stg_users') }}
