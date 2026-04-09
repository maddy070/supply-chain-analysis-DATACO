/*
================================================================
PROJECT:    Supply Chain Performance Analysis
AUTHOR:     Madhavan Padmanaban
DATE:       April 2026
SOURCE:     DataCo Smart Supply Chain Dataset (Kaggle)
TOOL:       SQL Server Management Studio

DESCRIPTION:
    End-to-end supply chain analysis covering category
    performance, delivery efficiency, customer behaviour,
    and inventory classification using cleaned dataset.

QUERIES:
    1.  Sales and profit by category
    2.  Delivery performance by shipping mode
    3.  Late delivery risk by region
    4.  Top 10 customers by sales
    5.  Monthly sales trend with MoM growth
    6.  Department profitability ranking
    7.  Order status breakdown
    8.  Shipping delay analysis
    9.  ABC analysis by product category
    10. Customer segment performance
    11. RFM customer segmentation
================================================================
*/

-- ============================================================
-- QUERY 1: SALES AND PROFIT BY CATEGORY
-- Which product categories drive the most revenue and profit?
-- ============================================================

SELECT
    category_name,
    COUNT(DISTINCT order_id)                        AS total_orders,
    SUM(sales)                                      AS total_sales,
    SUM(order_profit_per_order)                     AS total_profit,
    ROUND(SUM(order_profit_per_order)
          / SUM(sales) * 100, 2)                    AS profit_margin_pct 
FROM dataco_cleaned
GROUP BY category_name
ORDER BY total_sales DESC;

-- ============================================================
-- QUERY 2: DELIVERY PERFORMANCE BY SHIPPING MODE
-- Which shipping mode has the best on-time delivery rate?
-- ============================================================

WITH delivery_stats AS (
    SELECT
        shipping_mode,
        COUNT(*)                                        AS total_orders,
        SUM(CASE WHEN late_delivery_risk = 1
            THEN 1 ELSE 0 END)                          AS late_orders,
        ROUND(AVG(days_for_shipping_real * 1.0), 2)     AS avg_actual_days,
        ROUND(AVG(days_for_shipment_scheduled * 1.0)
        , 2)                                            AS avg_scheduled_days
    FROM dataco_cleaned
    GROUP BY shipping_mode
)
SELECT *,
    ROUND(late_orders * 1.0 / total_orders * 100, 2)    AS late_delivery_pct,
    ROUND(avg_actual_days - avg_scheduled_days, 2)      AS avg_delay_days
FROM delivery_stats
ORDER BY late_delivery_pct DESC;

-- ============================================================
-- QUERY 3: LATE DELIVERY RISK BY REGION
-- Which regions have the highest late delivery risk?
-- ============================================================

SELECT
    order_region,
    COUNT(*)                                        AS total_orders,
    SUM(late_delivery_risk)                         AS late_risk_orders,
    ROUND(
        SUM(late_delivery_risk) * 1.0
        / COUNT(*) * 100
    , 2)                                            AS late_delivery_risk_pct
FROM dataco_cleaned
GROUP BY order_region
ORDER BY late_delivery_risk_pct DESC;

-- ============================================================
-- QUERY 4: TOP 10 CUSTOMERS BY TOTAL SALES
-- Who are the highest value customers?
-- ============================================================

SELECT TOP 10
    customer_id,
    customer_fname + ' ' + customer_lname           AS customer_name,
    customer_segment,
    customer_country,
    COUNT(DISTINCT order_id)                        AS total_orders,
    SUM(sales)                                      AS total_sales,
    SUM(order_profit_per_order)                     AS total_profit,
    AVG(sales)                                      AS avg_order_value
FROM dataco_cleaned
GROUP BY
    customer_id,
    customer_fname,
    customer_lname,
    customer_segment,
    customer_country
ORDER BY total_sales DESC;

-- ============================================================
-- QUERY 5: MONTHLY SALES TREND WITH MOM GROWTH
-- How have sales grown month over month?
-- ============================================================

WITH monthly_sales AS (
    SELECT
        YEAR(order_date)                            AS yr,
        MONTH(order_date)                           AS mo,
        ROUND(SUM(sales), 2)                        AS total_sales,
        ROUND(SUM(order_profit_per_order), 2)       AS total_profit,
        COUNT(DISTINCT order_id)                    AS total_orders
    FROM dataco_cleaned
    GROUP BY
        YEAR(order_date),   
        MONTH(order_date)
)
SELECT *,
    LAG(total_sales) OVER (
        ORDER BY yr, mo
    )                                               AS prev_month_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY yr, mo))
        / LAG(total_sales) OVER (ORDER BY yr, mo) * 100
    , 2)                                            AS mom_growth_pct
FROM monthly_sales
ORDER BY yr, mo;

-- ============================================================
-- QUERY 6: DEPARTMENT PROFITABILITY RANKING
-- Which departments are most and least profitable?
-- ============================================================

SELECT
    department_name,
    COUNT(DISTINCT order_id)                        AS total_orders,
    SUM(sales)                                      AS total_sales,
    SUM(order_profit_per_order)                     AS total_profit,
    ROUND(AVG(order_item_profit_ratio) * 100, 2)    AS avg_profit_margin_pct,
    RANK() OVER (
        ORDER BY SUM(order_profit_per_order) DESC
    )                                               AS profit_rank
FROM dataco_cleaned
GROUP BY department_name
ORDER BY profit_rank;

-- ============================================================
-- QUERY 7: ORDER STATUS BREAKDOWN
-- What percentage of orders are in each status?
-- ============================================================

WITH status_counts AS (
    SELECT
        order_status,
        COUNT(*)                                    AS order_count
    FROM dataco_cleaned
    GROUP BY order_status
)
SELECT *,
    SUM(order_count) OVER ()                        AS total_orders,
    ROUND(
        order_count * 1.0
        / SUM(order_count) OVER () * 100
    , 2)                                            AS pct_of_total
FROM status_counts
ORDER BY order_count DESC;

-- ============================================================
-- QUERY 8: SHIPPING DELAY ANALYSIS
-- How many days late are orders by delivery status?
-- Note: delay = actual days minus scheduled days
--       negative = arrived early, positive = arrived late
-- ============================================================

WITH delivery_tab AS (
    SELECT
        delivery_status,
        (days_for_shipping_real * 1)
        - (days_for_shipment_scheduled * 1)         AS delay_days
    FROM dataco_cleaned
)
SELECT
    delivery_status,
    COUNT(*)                                        AS total_orders,
    ROUND(AVG(delay_days * 1.0), 2)                AS avg_delay_days,
    MAX(delay_days)                                 AS max_delay_days,
    MIN(delay_days)                                 AS min_delay_days
FROM delivery_tab
GROUP BY delivery_status
ORDER BY avg_delay_days DESC;

-- ============================================================
-- QUERY 9: ABC ANALYSIS BY PRODUCT CATEGORY
-- Classify categories by revenue contribution
-- A = top 80% of revenue  (high priority)
-- B = next 15% of revenue (medium priority)
-- C = bottom 5% of revenue (low priority)
-- Note: classic Pareto principle applied to inventory mgmt
-- ============================================================

WITH category_sales AS (
    SELECT
        category_name,
        ROUND(SUM(sales), 2)                        AS total_sales
    FROM dataco_cleaned
    GROUP BY category_name
),
running_total AS (
    SELECT *,
        SUM(total_sales) OVER (
            ORDER BY total_sales DESC
        )                                           AS cumulative_sales,
        SUM(total_sales) OVER ()                    AS grand_total
    FROM category_sales
)
SELECT
    category_name,
    total_sales,
    ROUND(
        cumulative_sales / grand_total * 100
    , 2)                                            AS cumulative_pct,
    CASE
        WHEN cumulative_sales / grand_total * 100 <= 80
            THEN 'A - high value'
        WHEN cumulative_sales / grand_total * 100 <= 95
            THEN 'B - medium value'
        ELSE 'C - low value'
    END                                             AS abc_class
FROM running_total
ORDER BY total_sales DESC;

-- ============================================================
-- QUERY 10: CUSTOMER SEGMENT PERFORMANCE
-- How do Consumer, Corporate, Home Office segments compare?
-- ============================================================

WITH segment_stats AS (
    SELECT
        customer_segment,
        COUNT(DISTINCT order_id)                    AS total_orders,
        COUNT(DISTINCT customer_id)                 AS unique_customers,
        ROUND(SUM(sales), 2)                        AS total_sales,
        ROUND(SUM(order_profit_per_order), 2)       AS total_profit,
        ROUND(AVG(sales), 2)                        AS avg_order_value,
        COUNT(DISTINCT CASE
            WHEN late_delivery_risk = 1
            THEN order_id END)                      AS late_orders
    FROM dataco_cleaned
    GROUP BY customer_segment
)
SELECT *,
    ROUND(
        total_profit / total_sales * 100
    , 2)                                            AS profit_margin_pct,
    ROUND(
        late_orders * 1.0
        / total_orders * 100
    , 2)                                            AS late_delivery_pct
FROM segment_stats
ORDER BY total_sales DESC;

-- ============================================================
-- QUERY 11: RFM CUSTOMER SEGMENTATION
-- Segments customers by Recency, Frequency, Monetary value
-- R = days since last order  (lower = more recent = better)
-- F = number of orders       (higher = more loyal = better)
-- M = total spend            (higher = more valuable = better)
-- Scored 1-5 using NTILE, 5 = best
-- ============================================================

WITH rfm_base AS (
    SELECT
        customer_id,
        customer_fname + ' ' + customer_lname       AS customer_name,
        customer_segment,
        -- Recency: days between last order and latest date in dataset
        DATEDIFF(day,
            MAX(order_date),
            (SELECT MAX(order_date) FROM dataco_cleaned)
        )                                           AS recency_days,
        -- Frequency: number of unique orders
        COUNT(DISTINCT order_id)                    AS frequency,
        -- Monetary: total spend
        SUM(sales)                        AS monetary
    FROM dataco_cleaned
    GROUP BY
        customer_id,
        customer_fname,
        customer_lname,
        customer_segment
),
rfm_scored AS (
    SELECT *,
        -- Score 1-5, 5 = most recent
        NTILE(5) OVER (ORDER BY recency_days ASC)   AS r_score,
        -- Score 1-5, 5 = most frequent
        NTILE(5) OVER (ORDER BY frequency DESC)     AS f_score,
        -- Score 1-5, 5 = highest spend
        NTILE(5) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_base
),
rfm_segmented AS (
    SELECT *,
        r_score + f_score + m_score                 AS rfm_total,
        CASE
            WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4   THEN 'champion'
            WHEN r_score >= 3
             AND f_score >= 3   THEN 'loyal'
            WHEN r_score >= 4
             AND f_score <= 2   THEN 'new customer'
            WHEN r_score <= 2
             AND f_score >= 3   THEN 'at risk'
            WHEN r_score = 1
             AND f_score = 1    THEN 'lost'
            ELSE 'potential'
        END                                         AS rfm_segment
    FROM rfm_scored
)
-- OPTION 1: SUMMARY BY SEGMENT (for Tableau dashboard)
SELECT
    rfm_segment,
    COUNT(*)                                        AS customer_count,
    ROUND(AVG(recency_days), 0)                     AS avg_recency_days,
    ROUND(AVG(frequency * 1.0), 1)                  AS avg_frequency,
    ROUND(AVG(monetary), 2)                         AS avg_monetary,
    ROUND(SUM(monetary), 2)                         AS total_revenue
FROM rfm_segmented
GROUP BY rfm_segment
ORDER BY total_revenue DESC;