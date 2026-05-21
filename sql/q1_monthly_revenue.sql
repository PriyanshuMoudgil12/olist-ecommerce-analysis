-- ============================================================
-- Q1: Monthly Revenue Trend (2017-01 to 2018-08)
-- ============================================================
-- Business question:
--   Is the business growing month-over-month?
--   When are the seasonal peaks?
--
-- How to use:
--   Run in DB Browser for SQLite, then Export → CSV
--   Save result as: outputs/q1_monthly_revenue.csv
--   This CSV feeds the Tableau "Revenue Trend" line chart.
-- ============================================================

SELECT
    strftime('%Y-%m', o.order_purchase_timestamp)      AS month,

    -- Volume
    COUNT(DISTINCT o.order_id)                         AS total_orders,

    -- Revenue components
    ROUND(SUM(oi.price), 2)                            AS product_revenue,
    ROUND(SUM(oi.freight_value), 2)                    AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2)         AS total_revenue,

    -- Average values
    ROUND(AVG(oi.price + oi.freight_value), 2)         AS avg_order_value,
    ROUND(AVG(oi.price), 2)                            AS avg_product_price

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE
    o.order_status = 'delivered'
    -- Exclude 2016 (too few orders, skews the chart)
    -- Exclude Sep–Dec 2018 (incomplete months in the dataset)
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'

GROUP BY
    month

ORDER BY
    month ASC;

-- ── Expected output ───────────────────────────────────────────
-- ~20 rows (Jan 2017 → Aug 2018)
-- Peak month is typically Nov 2017 (Black Friday effect)
-- You should see a clear upward trend overall
-- ──────────────────────────────────────────────────────────────
