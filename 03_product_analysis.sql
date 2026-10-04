-- ============================================================
-- PRODUCT ENGAGEMENT, CONVERSION & RETENTION ANALYSIS
-- 03. PRODUCT ANALYSIS
-- ============================================================


-- ------------------------------------------------------------
-- 1. MONTHLY USER ACQUISITION
-- Validate whether acquisition is actually growing
-- ------------------------------------------------------------

SELECT
    signup_month,
    COUNT(*) AS new_users
FROM analytics.user_metrics
GROUP BY signup_month
ORDER BY signup_month;


-- ------------------------------------------------------------
-- 2. ACQUISITION CHANNEL MIX
-- ------------------------------------------------------------

SELECT
    acquisition_channel,
    COUNT(*) AS users,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS user_share_pct
FROM analytics.user_metrics
GROUP BY acquisition_channel
ORDER BY users DESC;


-- ------------------------------------------------------------
-- 3. CONVERSION RATE BY ACQUISITION CHANNEL
-- ------------------------------------------------------------

SELECT
    acquisition_channel,
    COUNT(*) AS users,
    SUM(converted) AS converted_users,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM analytics.user_metrics
GROUP BY acquisition_channel
ORDER BY conversion_rate_pct DESC;


-- ------------------------------------------------------------
-- 4. H1 2025 VS H1 2026 CONVERSION BY CHANNEL
-- Compare equivalent six-month periods
-- ------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM signup_date) AS signup_year,
    acquisition_channel,
    COUNT(*) AS users,
    SUM(converted) AS converted_users,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM analytics.user_metrics
WHERE EXTRACT(YEAR FROM signup_date) IN (2025, 2026)
  AND EXTRACT(MONTH FROM signup_date) BETWEEN 1 AND 6
GROUP BY
    EXTRACT(YEAR FROM signup_date),
    acquisition_channel
ORDER BY
    acquisition_channel,
    signup_year;


-- ------------------------------------------------------------
-- 5. EARLY ENGAGEMENT: H1 2025 VS H1 2026
-- ------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM signup_date) AS signup_year,
    acquisition_channel,
    ROUND(AVG(sessions_first_7d), 2) AS avg_sessions_first_7d,
    ROUND(AVG(features_first_7d), 2) AS avg_features_first_7d
FROM analytics.user_metrics
WHERE EXTRACT(YEAR FROM signup_date) IN (2025, 2026)
  AND EXTRACT(MONTH FROM signup_date) BETWEEN 1 AND 6
GROUP BY
    EXTRACT(YEAR FROM signup_date),
    acquisition_channel
ORDER BY
    acquisition_channel,
    signup_year;


-- ------------------------------------------------------------
-- 6. ACTIVATION AND CONVERSION
-- Activated = >= 2 sessions and >= 3 distinct features
-- during first 7 days
-- ------------------------------------------------------------

SELECT
    activated,
    COUNT(*) AS users,
    SUM(converted) AS converted_users,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM analytics.user_metrics
GROUP BY activated
ORDER BY activated DESC;


-- ------------------------------------------------------------
-- 7. H1 ACTIVATION RATE BY ACQUISITION CHANNEL
-- ------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM signup_date) AS signup_year,
    acquisition_channel,
    COUNT(*) AS users,
    SUM(activated) AS activated_users,
    ROUND(
        100.0 * SUM(activated) / COUNT(*),
        2
    ) AS activation_rate_pct
FROM analytics.user_metrics
WHERE EXTRACT(YEAR FROM signup_date) IN (2025, 2026)
  AND EXTRACT(MONTH FROM signup_date) BETWEEN 1 AND 6
GROUP BY
    EXTRACT(YEAR FROM signup_date),
    acquisition_channel
ORDER BY
    acquisition_channel,
    signup_year;


-- ------------------------------------------------------------
-- 8. 90-DAY RETENTION
-- Only subscriptions with a complete 90-day observation window
-- ------------------------------------------------------------

SELECT
    retained_90d,
    COUNT(*) AS users,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS share_pct
FROM analytics.user_metrics
WHERE eligible_retention_90d = 1
GROUP BY retained_90d
ORDER BY retained_90d DESC;


-- ------------------------------------------------------------
-- 9. ACTIVATION VS 90-DAY RETENTION
-- ------------------------------------------------------------

SELECT
    activated,
    COUNT(*) AS eligible_users,
    SUM(retained_90d) AS retained_users,
    ROUND(
        100.0 * SUM(retained_90d) / COUNT(*),
        2
    ) AS retention_rate_90d_pct
FROM analytics.user_metrics
WHERE eligible_retention_90d = 1
GROUP BY activated
ORDER BY activated DESC;


-- ------------------------------------------------------------
-- 10. EARLY FEATURE USAGE AND CONVERSION
-- Compare users who used each feature during their first 7 days
-- against users who did not
-- ------------------------------------------------------------

WITH features AS (
    SELECT DISTINCT event_name
    FROM analytics.user_feature_adoption
),

user_feature_matrix AS (
    SELECT
        f.event_name,
        u.user_id,
        u.converted,
        CASE
            WHEN ufa.user_id IS NOT NULL THEN 1
            ELSE 0
        END AS used_feature
    FROM features f
    CROSS JOIN analytics.user_metrics u
    LEFT JOIN analytics.user_feature_adoption ufa
        ON u.user_id = ufa.user_id
        AND f.event_name = ufa.event_name
)

SELECT
    event_name,

    ROUND(
        100.0 * SUM(converted) FILTER (WHERE used_feature = 1)
        / NULLIF(COUNT(*) FILTER (WHERE used_feature = 1), 0),
        2
    ) AS conversion_used_pct,

    ROUND(
        100.0 * SUM(converted) FILTER (WHERE used_feature = 0)
        / NULLIF(COUNT(*) FILTER (WHERE used_feature = 0), 0),
        2
    ) AS conversion_not_used_pct

FROM user_feature_matrix
GROUP BY event_name
ORDER BY conversion_used_pct DESC;


-- ------------------------------------------------------------
-- 11. PAID SOCIAL FEATURE ADOPTION
-- H1 2025 VS H1 2026
-- ------------------------------------------------------------

WITH paid_social_users AS (
    SELECT
        user_id,
        EXTRACT(YEAR FROM signup_date)::integer AS signup_year
    FROM analytics.user_metrics
    WHERE acquisition_channel = 'Paid Social'
      AND EXTRACT(YEAR FROM signup_date) IN (2025, 2026)
      AND EXTRACT(MONTH FROM signup_date) BETWEEN 1 AND 6
),

feature_users AS (
    SELECT
        p.signup_year,
        ufa.event_name,
        COUNT(DISTINCT p.user_id) AS feature_users
    FROM paid_social_users p
    JOIN analytics.user_feature_adoption ufa
        ON p.user_id = ufa.user_id
    GROUP BY
        p.signup_year,
        ufa.event_name
),

year_totals AS (
    SELECT
        signup_year,
        COUNT(*) AS total_users
    FROM paid_social_users
    GROUP BY signup_year
)

SELECT
    f.signup_year,
    f.event_name,
    f.feature_users,
    y.total_users,
    ROUND(
        100.0 * f.feature_users / y.total_users,
        2
    ) AS adoption_rate_pct
FROM feature_users f
JOIN year_totals y
    ON f.signup_year = y.signup_year
ORDER BY
    f.event_name,
    f.signup_year;
