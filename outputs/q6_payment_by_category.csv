-- ============================================================
-- Q6: Payment Method Analysis
-- ============================================================
-- Business question:
--   Which payment methods do customers prefer?
--   Do payment methods differ by order size or product category?
--   Are installment payments linked to higher-value purchases?
--
-- How to use:
--   Run each section separately in DB Browser.
--   Export results as:
--     outputs/q6a_payment_overall.csv
--     outputs/q6b_payment_by_category.csv
-- ============================================================


-- ── Part A: Overall payment method breakdown ─────────────────
SELECT
    op.payment_type,

    -- Volume
    COUNT(DISTINCT op.order_id)                         AS total_orders,

    ROUND(
        COUNT(DISTINCT op.order_id) * 100.0
        / SUM(COUNT(DISTINCT op.order_id)) OVER (),
        1
    )                                                   AS order_share_pct,

    -- Value
    ROUND(SUM(op.payment_value), 2)                     AS total_payment_value,
    ROUND(AVG(op.payment_value), 2)                     AS avg_payment_value,
    ROUND(MIN(op.payment_value), 2)                     AS min_payment_value,
    ROUND(MAX(op.payment_value), 2)                     AS max_payment_value,

    -- Installment behaviour (only relevant for credit_card)
    ROUND(AVG(op.payment_installments), 1)              AS avg_installments,
    MAX(op.payment_installments)                        AS max_installments,

    -- % of orders using multiple installments (> 1)
    ROUND(
        SUM(CASE WHEN op.payment_installments > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        1
    )                                                   AS pct_using_installments

FROM order_payments op
JOIN orders o ON op.order_id = o.order_id

WHERE
    o.order_status   = 'delivered'
    AND op.payment_type != 'not_defined'

GROUP BY
    op.payment_type

ORDER BY
    total_orders DESC;


-- ── Part B: Payment method preference by product category ────
-- (Which categories are bought on credit vs boleto?)
SELECT
    COALESCE(
        t.product_category_name_english,
        'Uncategorised'
    )                                                   AS category,

    COUNT(DISTINCT CASE
        WHEN op.payment_type = 'credit_card' THEN op.order_id
    END)                                                AS credit_card_orders,

    COUNT(DISTINCT CASE
        WHEN op.payment_type = 'boleto'      THEN op.order_id
    END)                                                AS boleto_orders,

    COUNT(DISTINCT CASE
        WHEN op.payment_type = 'debit_card'  THEN op.order_id
    END)                                                AS debit_card_orders,

    COUNT(DISTINCT CASE
        WHEN op.payment_type = 'voucher'     THEN op.order_id
    END)                                                AS voucher_orders,

    COUNT(DISTINCT op.order_id)                         AS total_orders,

    ROUND(AVG(op.payment_value), 2)                     AS avg_order_value,
    ROUND(AVG(op.payment_installments), 1)              AS avg_installments

FROM order_payments op
JOIN orders      o  ON op.order_id   = o.order_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name

WHERE
    o.order_status   = 'delivered'
    AND op.payment_type != 'not_defined'

GROUP BY
    category

HAVING
    total_orders >= 200

ORDER BY
    total_orders DESC

LIMIT 20;

-- ── Expected output ───────────────────────────────────────────
-- Part A: credit_card ~74%, boleto ~19%, voucher ~5%, debit ~2%
--   Boleto avg order value is typically HIGHER than credit card
--   Credit card avg installments ~3–4 (buy now, pay later culture)
-- Part B: High-ticket categories (computers, furniture) show
--   higher boleto usage and more installments
-- ──────────────────────────────────────────────────────────────
