-- ============================================================
--  E-Commerce Sales Analysis — Core Queries
--  January 2026 | Analyzed 10,000+ transaction records
-- ============================================================


-- ╔══════════════════════════════════════════════════════════╗
--  QUERY 1 — Monthly Revenue Growth (with MoM % change)
--  Window Function: LAG() to compare month-over-month
-- ╚══════════════════════════════════════════════════════════╝
WITH monthly_revenue AS (
    SELECT
        TO_CHAR(o.order_date, 'YYYY-MM')          AS month,
        DATE_TRUNC('month', o.order_date)          AS month_dt,
        COUNT(DISTINCT o.order_id)                 AS total_orders,
        SUM(oi.line_total)                         AS gross_revenue,
        SUM(oi.line_total * (1 - o.discount_pct/100)) AS net_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY 1, 2
),
growth AS (
    SELECT
        month,
        total_orders,
        ROUND(gross_revenue, 2)                                         AS gross_revenue,
        ROUND(net_revenue, 2)                                           AS net_revenue,
        LAG(net_revenue) OVER (ORDER BY month_dt)                       AS prev_month_revenue,
        ROUND(
            100.0 * (net_revenue - LAG(net_revenue) OVER (ORDER BY month_dt))
                  / NULLIF(LAG(net_revenue) OVER (ORDER BY month_dt), 0),
        2)                                                              AS mom_growth_pct
    FROM monthly_revenue
)
SELECT
    month,
    total_orders,
    gross_revenue,
    net_revenue,
    COALESCE(CAST(mom_growth_pct AS VARCHAR), 'N/A (first month)') AS mom_growth_pct
FROM growth
ORDER BY month;


-- ╔══════════════════════════════════════════════════════════╗
--  QUERY 2 — Regional Revenue Distribution
--  Joins: customers → orders → order_items
-- ╚══════════════════════════════════════════════════════════╝
SELECT
    c.region,
    COUNT(DISTINCT c.customer_id)                           AS unique_customers,
    COUNT(DISTINCT o.order_id)                              AS total_orders,
    ROUND(SUM(oi.line_total), 2)                            AS total_revenue,
    ROUND(AVG(oi.line_total), 2)                            AS avg_order_value,
    ROUND(
        100.0 * SUM(oi.line_total)
              / SUM(SUM(oi.line_total)) OVER (),
    2)                                                      AS revenue_share_pct
FROM customers c
JOIN orders o     ON o.customer_id  = c.customer_id
JOIN order_items oi ON oi.order_id  = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.region
ORDER BY total_revenue DESC;


-- ╔══════════════════════════════════════════════════════════╗
--  QUERY 3 — Top 10 Best-Selling Products (Revenue & Units)
--  Aggregation + RANK window function
-- ╚══════════════════════════════════════════════════════════╝
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                                        AS units_sold,
    ROUND(SUM(oi.line_total), 2)                            AS total_revenue,
    ROUND(SUM(oi.line_total - p.cost_price * oi.quantity), 2) AS gross_profit,
    ROUND(
        100.0 * (SUM(oi.line_total) - SUM(p.cost_price * oi.quantity))
              / NULLIF(SUM(oi.line_total), 0),
    2)                                                      AS profit_margin_pct,
    RANK() OVER (ORDER BY SUM(oi.line_total) DESC)          AS revenue_rank
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o       ON o.order_id    = oi.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;


-- ╔══════════════════════════════════════════════════════════╗
--  QUERY 4 — Products Contributing 40%+ of Total Revenue
--  💡 Key Insight: Pareto / revenue concentration analysis
--  Window: Running cumulative % using SUM() OVER()
-- ╚══════════════════════════════════════════════════════════╝
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        ROUND(SUM(oi.line_total), 2)    AS product_revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o       ON o.order_id    = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY p.product_id, p.product_name, p.category
),
cumulative AS (
    SELECT
        product_name,
        category,
        product_revenue,
        ROUND(
            100.0 * product_revenue / SUM(product_revenue) OVER (),
        2)                              AS pct_of_total,
        ROUND(
            100.0 * SUM(product_revenue) OVER (ORDER BY product_revenue DESC
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                  / SUM(product_revenue) OVER (),
        2)                              AS cumulative_pct
    FROM product_revenue
)
SELECT
    product_name,
    category,
    product_revenue,
    pct_of_total         AS individual_share_pct,
    cumulative_pct       AS running_total_pct,
    CASE WHEN cumulative_pct <= 40 THEN '⭐ Top 40% Revenue Driver' ELSE '' END AS flag
FROM cumulative
ORDER BY product_revenue DESC;


-- ╔══════════════════════════════════════════════════════════╗
--  QUERY 5 — Customer Purchasing Patterns (RFM Analysis)
--  Recency · Frequency · Monetary — classic segmentation
-- ╚══════════════════════════════════════════════════════════╝
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.region,
        c.age_group,
        MAX(o.order_date)                          AS last_order_date,
        COUNT(DISTINCT o.order_id)                 AS frequency,
        ROUND(SUM(oi.line_total), 2)               AS monetary
    FROM customers c
    JOIN orders o       ON o.customer_id  = c.customer_id
    JOIN order_items oi ON oi.order_id    = o.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.full_name, c.region, c.age_group
),
rfm_scored AS (
    SELECT *,
        CURRENT_DATE - last_order_date              AS recency_days,
        NTILE(5) OVER (ORDER BY CURRENT_DATE - last_order_date ASC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC)                      AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)                       AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    full_name,
    region,
    age_group,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score)                  AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN '🏆 Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN '💎 Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 7  THEN '🔄 Potential Loyalists'
        WHEN r_score >= 4                         THEN '🆕 New Customers'
        WHEN m_score >= 4 AND f_score <= 2        THEN '🛒 Big Spenders'
        ELSE                                           '😴 At Risk'
    END                                            AS customer_segment
FROM rfm_scored
ORDER BY rfm_total DESC;


-- ╔══════════════════════════════════════════════════════════╗
--  QUERY 6 — Category Performance Heatmap (Quarter × Category)
--  Pivot-style aggregation using FILTER clause
-- ╚══════════════════════════════════════════════════════════╝
SELECT
    p.category,
    ROUND(SUM(oi.line_total) FILTER (WHERE EXTRACT(QUARTER FROM o.order_date) = 1), 2) AS Q1_revenue,
    ROUND(SUM(oi.line_total) FILTER (WHERE EXTRACT(QUARTER FROM o.order_date) = 2), 2) AS Q2_revenue,
    ROUND(SUM(oi.line_total) FILTER (WHERE EXTRACT(QUARTER FROM o.order_date) = 3), 2) AS Q3_revenue,
    ROUND(SUM(oi.line_total) FILTER (WHERE EXTRACT(QUARTER FROM o.order_date) = 4), 2) AS Q4_revenue,
    ROUND(SUM(oi.line_total), 2)                                                        AS annual_revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o       ON o.order_id    = oi.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY annual_revenue DESC;


-- ╔══════════════════════════════════════════════════════════╗
--  QUERY 7 — Return Rate Impact on Revenue
-- ╚══════════════════════════════════════════════════════════╝
SELECT
    p.category,
    COUNT(DISTINCT o.order_id)                         AS total_orders,
    COUNT(DISTINCT o.order_id) FILTER (WHERE o.status = 'Returned')  AS returned_orders,
    ROUND(
        100.0 * COUNT(DISTINCT o.order_id) FILTER (WHERE o.status = 'Returned')
              / NULLIF(COUNT(DISTINCT o.order_id), 0),
    2)                                                 AS return_rate_pct,
    ROUND(SUM(oi.line_total) FILTER (WHERE o.status = 'Returned'), 2) AS lost_revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o       ON o.order_id    = oi.order_id
GROUP BY p.category
ORDER BY lost_revenue DESC;


-- ╔══════════════════════════════════════════════════════════╗
--  QUERY 8 — Cohort Retention (signup month vs purchase month)
-- ╚══════════════════════════════════════════════════════════╝
WITH cohorts AS (
    SELECT
        c.customer_id,
        DATE_TRUNC('month', c.signup_date)  AS cohort_month,
        DATE_TRUNC('month', o.order_date)   AS order_month
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'Completed'
)
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM')        AS cohort,
    TO_CHAR(order_month,  'YYYY-MM')        AS active_month,
    EXTRACT(MONTH FROM AGE(order_month, cohort_month)) AS months_since_signup,
    COUNT(DISTINCT customer_id)             AS active_customers
FROM cohorts
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;
