---
id: users-endpoint
title: Using the published users endpoint
summary: Explains the shape and intended use of the user data product published through Qry.
domain: user-data
owner: analytics-engineering
tasks: [user-lookup, endpoint-demo]
tags: [users, qry, api]
resources:
  - "{{ ref('users_model') }}"
meta:
  qry_endpoint: /users
---
# Using the published users endpoint

`users_model` is the curated relation published through Qry at `/users`. It returns one row per demo user with `user_id`, `full_name`, and `email`.

Use the optional `user_id` parameter for a deterministic lookup. Without that parameter, the endpoint may return the full three-row demo dataset subject to the configured response limit.

This model combines first and last name into `full_name`; it does not add behavioral, account, or activity data. A successful lookup confirms only that the synthetic record exists in the demo dataset.
