-- ============================================================
-- PRODUCT ENGAGEMENT, CONVERSION & RETENTION ANALYSIS
-- 02. ANALYTICS LAYER
-- ============================================================

CREATE SCHEMA IF NOT EXISTS analytics;


-- ------------------------------------------------------------
-- CLEAN USERS
-- Standardize missing categorical attributes
-- ------------------------------------------------------------

CREATE VIEW analytics.users_clean AS
SELECT
    user_id,
    signup_date,
    COALESCE(country, 'Unknown') AS country,
    acquisition_channel,
    COALESCE(signup_device, 'Unknown') AS signup_device
FROM users;


-- ------------------------------------------------------------
-- CLEAN EVENTS
-- Remove duplicated event records
-- ------------------------------------------------------------

CREATE VIEW analytics.events_clean AS
SELECT
    event_id,
    user_id,
    session_id,
    event_timestamp,
    event_name
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id
            ORDER BY event_timestamp
        ) AS row_num
    FROM events
) e
WHERE row_num = 1;


CREATE VIEW analytics.sessions_clean AS
SELECT *
FROM sessions;


CREATE VIEW analytics.subscriptions_clean AS
SELECT *
FROM subscriptions;


CREATE VIEW analytics.support_tickets_clean AS
SELECT *
FROM support_tickets;


-- ------------------------------------------------------------
-- USER-LEVEL ANALYTICAL VIEW
-- Grain: one row per user
-- ------------------------------------------------------------

CREATE VIEW analytics.user_metrics AS

WITH early_engagement AS (
    SELECT
        u.user_id,
        COUNT(DISTINCT s.session_id) AS sessions_first_7d,
        COUNT(DISTINCT e.event_name) AS features_first_7d
    FROM analytics.users_clean u
    LEFT JOIN analytics.sessions_clean s
        ON u.user_id = s.user_id
        AND s.session_start >= u.signup_date
        AND s.session_start < u.signup_date + INTERVAL '8 days'
    LEFT JOIN analytics.events_clean e
        ON s.session_id = e.session_id
    GROUP BY u.user_id
),

subscription_metrics AS (
    SELECT
        user_id,
        MIN(start_date) AS subscription_start_date,
        MAX(end_date) AS subscription_end_date,
        MAX(monthly_price) AS monthly_price
    FROM analytics.subscriptions_clean
    GROUP BY user_id
)

SELECT
    u.user_id,
    u.signup_date,
    DATE_TRUNC('month', u.signup_date)::date AS signup_month,
    u.country,
    u.acquisition_channel,
    u.signup_device,

    COALESCE(ee.sessions_first_7d, 0) AS sessions_first_7d,
    COALESCE(ee.features_first_7d, 0) AS features_first_7d,

    CASE
        WHEN COALESCE(ee.sessions_first_7d, 0) >= 2
         AND COALESCE(ee.features_first_7d, 0) >= 3
        THEN 1
        ELSE 0
    END AS activated,

    CASE
        WHEN sm.subscription_start_date IS NOT NULL
        THEN 1
        ELSE 0
    END AS converted,

    sm.subscription_start_date,
    sm.subscription_end_date,
    sm.monthly_price,

    CASE
        WHEN sm.subscription_start_date
             <= DATE '2026-08-31' - INTERVAL '90 days'
        THEN 1
        ELSE 0
    END AS eligible_retention_90d,

    CASE
        WHEN sm.subscription_start_date
             <= DATE '2026-08-31' - INTERVAL '90 days'
         AND (
             sm.subscription_end_date IS NULL
             OR sm.subscription_end_date
                >= sm.subscription_start_date + INTERVAL '90 days'
         )
        THEN 1

        WHEN sm.subscription_start_date
             <= DATE '2026-08-31' - INTERVAL '90 days'
        THEN 0

        ELSE NULL
    END AS retained_90d

FROM analytics.users_clean u
LEFT JOIN early_engagement ee
    ON u.user_id = ee.user_id
LEFT JOIN subscription_metrics sm
    ON u.user_id = sm.user_id;


-- ------------------------------------------------------------
-- FEATURE ADOPTION VIEW
-- Grain: one user x one feature used during first 7 days
-- ------------------------------------------------------------

CREATE VIEW analytics.user_feature_adoption AS

SELECT
    u.user_id,
    u.signup_date,
    u.acquisition_channel,
    e.event_name,
    MIN(e.event_timestamp) AS first_use_timestamp,
    COUNT(*) AS event_count_first_7d

FROM analytics.users_clean u
JOIN analytics.events_clean e
    ON u.user_id = e.user_id
    AND e.event_timestamp >= u.signup_date
    AND e.event_timestamp < u.signup_date + INTERVAL '8 days'

GROUP BY
    u.user_id,
    u.signup_date,
    u.acquisition_channel,
    e.event_name;
