-- ============================================================
-- Q3: State-wise Revenue & Order Volume
-- ============================================================
-- Business question:
--   Where are our customers concentrated?
--   Which states are high-revenue but high-cost (freight)?
--   Which states are underserved and represent growth opportunity?
--
-- How to use:
--   Run in DB Browser for SQLite, then Export → CSV
--   Save result as: outputs/q3_state_revenue.csv
--   This CSV feeds the Power BI filled map visual (choropleth).
-- ============================================================

SELECT
    c.customer_state                                    AS state,

    -- Volume
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    COUNT(DISTINCT o.customer_id)                       AS unique_customers,

    -- Revenue
    ROUND(SUM(oi.price + oi.freight_value), 2)          AS total_revenue,
    ROUND(SUM(oi.price), 2)                             AS product_revenue,
    ROUND(SUM(oi.freight_value), 2)                     AS freight_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2)          AS avg_order_value,

    -- Freight as % of order value (high = logistics cost issue)
    ROUND(
        SUM(oi.freight_value) * 100.0
        / NULLIF(SUM(oi.price + oi.freight_value), 0),
        1
    )                                                   AS freight_pct_of_revenue,

    -- State's share of national revenue
    ROUND(
        SUM(oi.price + oi.freight_value) * 100.0
        / SUM(SUM(oi.price + oi.freight_value)) OVER (),
        2
    )                                                   AS national_revenue_share_pct

FROM orders o
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN customers   c  ON o.customer_id = c.customer_id

WHERE
    o.order_status = 'delivered'

GROUP BY
    state

ORDER BY
    total_revenue DESC;

-- ── Expected output ───────────────────────────────────────────
-- 27 rows (one per Brazilian state)
-- SP typically ~42% of all orders
-- SP + RJ + MG together ~60% of national revenue
-- Northern states (AM, RR, AP) have highest freight_pct
-- ──────────────────────────────────────────────────────────────
