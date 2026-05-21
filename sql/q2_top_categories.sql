-- ============================================================
-- Q2: Top Product Categories by Revenue
-- ============================================================
-- Business question:
--   Which product categories generate the most revenue?
--   Is revenue concentration a risk (too dependent on one category)?
--
-- How to use:
--   Run in DB Browser for SQLite, then Export → CSV
--   Save result as: outputs/q2_top_categories.csv
--   This CSV feeds the Tableau "Category Performance" bar chart.
-- ============================================================

SELECT
    COALESCE(
        t.product_category_name_english,
        'Uncategorised'
    )                                                   AS category,

    -- Volume
    COUNT(DISTINCT oi.order_id)                         AS total_orders,
    COUNT(oi.order_item_id)                             AS total_units_sold,

    -- Revenue
    ROUND(SUM(oi.price), 2)                             AS total_revenue,
    ROUND(AVG(oi.price), 2)                             AS avg_unit_price,

    -- Market share (window function — shows % of all category revenue)
    ROUND(
        SUM(oi.price) * 100.0
        / SUM(SUM(oi.price)) OVER (),
        2
    )                                                   AS revenue_share_pct,

    -- Running cumulative share (useful for 80/20 analysis in Excel)
    ROUND(
        SUM(SUM(oi.price)) OVER (
            ORDER BY SUM(oi.price) DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 100.0
        / SUM(SUM(oi.price)) OVER (),
        1
    )                                                   AS cumulative_share_pct

FROM order_items oi
JOIN products  p  ON oi.product_id  = p.product_id
JOIN orders    o  ON oi.order_id    = o.order_id

LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name

WHERE
    o.order_status = 'delivered'

GROUP BY
    category

ORDER BY
    total_revenue DESC

LIMIT 20;

-- ── Expected output ───────────────────────────────────────────
-- Top categories typically: health_beauty, watches_gifts,
--   bed_bath_table, sports_leisure, computers_accessories
-- Top 3 categories usually account for ~25% of all revenue
-- ──────────────────────────────────────────────────────────────
