-- ============================================================
--  E-Commerce Sales Analysis — Reusable Views
-- ============================================================

-- ─────────────────────────────────────────────
--  vw_sales_summary  —  flat denormalised table
--  (handy for BI tools / dashboards)
-- ─────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_sales_summary AS
SELECT
    o.order_id,
    o.order_date,
    TO_CHAR(o.order_date, 'YYYY-MM')        AS order_month,
    EXTRACT(QUARTER FROM o.order_date)      AS order_quarter,
    EXTRACT(YEAR   FROM o.order_date)       AS order_year,
    o.status,
    c.customer_id,
    c.full_name                             AS customer_name,
    c.region,
    c.age_group,
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    oi.line_total * (1 - o.discount_pct/100)   AS discounted_total,
    oi.line_total - p.cost_price * oi.quantity  AS gross_profit,
    o.discount_pct,
    o.shipping_cost
FROM orders o
JOIN customers  c  ON c.customer_id  = o.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
JOIN products   p  ON p.product_id   = oi.product_id;


-- ─────────────────────────────────────────────
--  vw_product_kpis  —  per-product KPI rollup
-- ─────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_product_kpis AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity)                                    AS units_sold,
    ROUND(SUM(oi.line_total), 2)                        AS total_revenue,
    ROUND(SUM(oi.line_total - p.cost_price * oi.quantity), 2) AS gross_profit,
    ROUND(AVG(oi.unit_price), 2)                        AS avg_selling_price,
    ROUND(
        100.0 * SUM(oi.line_total)
              / SUM(SUM(oi.line_total)) OVER (),
    2)                                                  AS revenue_share_pct,
    RANK() OVER (ORDER BY SUM(oi.line_total) DESC)      AS revenue_rank
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o       ON o.order_id    = oi.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category;


-- ─────────────────────────────────────────────
--  vw_monthly_kpis  —  month-by-month dashboard
-- ─────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_monthly_kpis AS
WITH base AS (
    SELECT
        DATE_TRUNC('month', o.order_date)               AS month_dt,
        TO_CHAR(o.order_date, 'YYYY-MM')                AS month,
        COUNT(DISTINCT o.order_id)                      AS orders,
        COUNT(DISTINCT o.customer_id)                   AS unique_customers,
        ROUND(SUM(oi.line_total), 2)                    AS gross_revenue,
        ROUND(SUM(oi.line_total * (1-o.discount_pct/100)), 2) AS net_revenue,
        ROUND(AVG(oi.line_total), 2)                    AS avg_order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY 1, 2
)
SELECT
    month,
    orders,
    unique_customers,
    gross_revenue,
    net_revenue,
    avg_order_value,
    ROUND(
        100.0 * (net_revenue - LAG(net_revenue) OVER (ORDER BY month_dt))
              / NULLIF(LAG(net_revenue) OVER (ORDER BY month_dt), 0),
    2) AS mom_growth_pct
FROM base
ORDER BY month_dt;
