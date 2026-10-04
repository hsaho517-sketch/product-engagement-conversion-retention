-- ============================================================
-- PRODUCT ENGAGEMENT, CONVERSION & RETENTION ANALYSIS
-- 01. DATA QUALITY AUDIT
-- ============================================================

-- ------------------------------------------------------------
-- USERS
-- Validate row count and missing values in key attributes
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_users,
    COUNT(*) FILTER (WHERE user_id IS NULL) AS null_user_id,
    COUNT(*) FILTER (WHERE signup_date IS NULL) AS null_signup_date,
    COUNT(*) FILTER (WHERE country IS NULL) AS null_country,
    COUNT(*) FILTER (WHERE acquisition_channel IS NULL) AS null_acquisition_channel,
    COUNT(*) FILTER (WHERE signup_device IS NULL) AS null_signup_device
FROM users;


-- ------------------------------------------------------------
-- EVENTS
-- Check for duplicated event IDs
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_event_rows,
    COUNT(DISTINCT event_id) AS unique_event_ids,
    COUNT(*) - COUNT(DISTINCT event_id) AS duplicate_event_rows
FROM events;


-- ------------------------------------------------------------
-- EVENT TYPES
-- Review available product behaviours
-- ------------------------------------------------------------

SELECT DISTINCT
    event_name
FROM events
ORDER BY event_name;


-- ------------------------------------------------------------
-- SUBSCRIPTIONS
-- Validate date coverage and pricing range
-- ------------------------------------------------------------

SELECT
    MIN(start_date) AS first_subscription_date,
    MAX(start_date) AS last_subscription_date,
    MIN(monthly_price) AS minimum_monthly_price,
    MAX(monthly_price) AS maximum_monthly_price
FROM subscriptions;
