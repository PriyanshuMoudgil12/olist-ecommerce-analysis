-- ============================================================
-- Q4: Delivery Performance — On-time vs Late
-- ============================================================
-- Business question:
--   What % of orders are delivered on time nationally?
--   Which states have the worst delivery reliability?
--   How does delivery speed vary, and does it affect reviews?
--
-- How to use:
--   Run each section separately in DB Browser.
--   Export results as:
--     outputs/q4a_delivery_overall.csv
--     outputs/q4b_delivery_by_state.csv
-- ============================================================


-- ── Part A: Overall delivery performance ────────────────────
SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END                                                 AS delivery_status,

    COUNT(*)                                            AS order_count,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        1
    )                                                   AS pct_of_orders,

    ROUND(AVG(
        julianday(order_delivered_customer_date) -
        julianday(order_purchase_timestamp)
    ), 1)                                               AS avg_delivery_days,

    ROUND(MIN(
        julianday(order_delivered_customer_date) -
        julianday(order_purchase_timestamp)
    ), 0)                                               AS min_delivery_days,

    ROUND(MAX(
        julianday(order_delivered_customer_date) -
        julianday(order_purchase_timestamp)
    ), 0)                                               AS max_delivery_days

FROM orders
WHERE
    order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL

GROUP BY
    delivery_status;


-- ── Part B: Delivery performance by state (all 27 states) ───
SELECT
    c.customer_state                                    AS state,
    COUNT(o.order_id)                                   AS total_orders,

    -- Speed
    ROUND(AVG(
        julianday(o.order_delivered_customer_date) -
        julianday(o.order_purchase_timestamp)
    ), 1)                                               AS avg_delivery_days,

    ROUND(AVG(
        julianday(o.order_estimated_delivery_date) -
        julianday(o.order_purchase_timestamp)
    ), 1)                                               AS avg_promised_days,

    -- How many days early/late on average (negative = early)
    ROUND(AVG(
        julianday(o.order_delivered_customer_date) -
        julianday(o.order_estimated_delivery_date)
    ), 1)                                               AS avg_days_vs_promise,

    -- Late rate
    ROUND(
        SUM(CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        1
    )                                                   AS late_delivery_pct,

    -- Satisfaction (join to reviews)
    ROUND(AVG(r.review_score), 2)                       AS avg_review_score

FROM orders o
JOIN customers    c ON o.customer_id = c.customer_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id

WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL

GROUP BY
    state

HAVING
    total_orders >= 50      -- filter out states with too few orders to be meaningful

ORDER BY
    late_delivery_pct DESC;

-- ── Expected output ───────────────────────────────────────────
-- Part A: ~93-94% on time nationally
-- Part B: Northern states (AM, RR, AP) worst performers
--   Negative avg_days_vs_promise = delivered early on average
--   States with high late_pct typically show lower avg_review_score
-- ──────────────────────────────────────────────────────────────
