---
id: user-data-quality
title: Interpreting the demo user records
summary: Defines the identity fields and data-quality limits shared by the seeded and staged user data.
domain: user-data
owner: analytics-engineering
tasks: [data-quality-review, user-lookup]
tags: [users, identity, data-quality]
resources:
  - "{{ ref('users') }}"
  - "{{ ref('stg_users') }}"
meta:
  grain: one row per demo user
---
# Interpreting the demo user records

`user_id` is the stable identifier for joining or filtering these records. Names and email addresses are display attributes and should not be used as durable identifiers.

The seed contains three fixed synthetic users. `stg_users` passes the four seed columns through without cleansing, deduplication, or validation, so its presence does not imply that email addresses are verified or unique.
