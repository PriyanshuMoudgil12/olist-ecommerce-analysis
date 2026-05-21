-- ============================================================
-- Q5: Customer Review Score by Product Category
-- ============================================================
-- Business question:
--   Are our highest-revenue categories also the highest-rated?
--   Which categories have a satisfaction problem?
--   Is there a trade-off between revenue and customer experience?
--
-- How to use:
--   Run in DB Browser for SQLite, then Export → CSV
--   Save result as: outputs/q5_reviews_by_category.csv
--   Use in Tableau scatter chart (revenue vs review score).
-- ============================================================

SELECT
    COALESCE(
        t.product_category_name_english,
        'Uncategorised'
    )                                                   AS category,

    -- Review metrics
    ROUND(AVG(r.review_score), 2)                       AS avg_review_score,
    COUNT(DISTINCT r.review_id)                         AS total_reviews,

    -- Score distribution (useful for a stacked bar in Tableau)
    SUM(CASE WHEN r.review_score = 5 THEN 1 ELSE 0 END) AS score_5,
    SUM(CASE WHEN r.review_score = 4 THEN 1 ELSE 0 END) AS score_4,
    SUM(CASE WHEN r.review_score = 3 THEN 1 ELSE 0 END) AS score_3,
    SUM(CASE WHEN r.review_score = 2 THEN 1 ELSE 0 END) AS score_2,
    SUM(CASE WHEN r.review_score = 1 THEN 1 ELSE 0 END) AS score_1,

    -- Positive/negative summary
    ROUND(
        SUM(CASE WHEN r.review_score >= 4 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        1
    )                                                   AS positive_review_pct,

    ROUND(
        SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        1
    )                                                   AS negative_review_pct,

    -- Revenue (to cross-reference in scatter plot)
    ROUND(SUM(oi.price), 2)                             AS total_revenue,
    COUNT(DISTINCT oi.order_id)                         AS total_orders

FROM order_reviews r
JOIN orders      o  ON r.order_id    = o.order_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name

WHERE
    o.order_status = 'delivered'

GROUP BY
    category

HAVING
    total_reviews >= 100    -- need enough reviews to be statistically meaningful

ORDER BY
    avg_review_score DESC;

-- ── Expected output ───────────────────────────────────────────
-- ~60–70 categories with 100+ reviews
-- Best reviewed: books, fashion, food/drinks tend to score 4.2+
-- Worst reviewed: office_furniture, diapers, cool_stuff around 3.6–3.8
-- Interesting find: some low-revenue categories have great reviews
--   and vice versa — highlight this in your business insight!
-- ──────────────────────────────────────────────────────────────
