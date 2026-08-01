/* ============================================================
   OLIST E-COMMERCE — ANALYSIS
   ============================================================ */


/* ------------------------------------------------------------
   Q1: Cohort retention — of customers who first bought in
   month X(a specific starting month), how many placed another order in a later month?
   ------------------------------------------------------------ */
WITH first_purchase AS (
    SELECT c.customer_unique_id,
           TO_CHAR(MIN(o.order_purchase_timestamp), 'YYYY-MM') AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
orders_with_cohort AS (
    SELECT c.customer_unique_id, fp.cohort_month,
           TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN first_purchase fp ON c.customer_unique_id = fp.customer_unique_id
    WHERE o.order_status = 'delivered'
)
SELECT cohort_month,
       COUNT(DISTINCT customer_unique_id) AS cohort_size,
       SUM(CASE WHEN order_month > cohort_month THEN 1 ELSE 0 END) AS orders_after_first_month
FROM orders_with_cohort
GROUP BY cohort_month
ORDER BY cohort_month;


/* ------------------------------------------------------------
   Q2: Does a late first delivery kill future purchases?
   Comparing the repeat-purchase rate for customers whose FIRST
   order arrived late vs. on time.
   ------------------------------------------------------------ */
WITH order_lateness AS (
    SELECT o.order_id, c.customer_unique_id,
           CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN 1 ELSE 0 END AS was_late
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
),
customer_first_order AS (
    SELECT customer_unique_id, MIN(order_id) AS first_order_id
    FROM order_lateness
    GROUP BY customer_unique_id
),
customer_order_counts AS (
    SELECT customer_unique_id, COUNT(*) AS total_orders
    FROM order_lateness
    GROUP BY customer_unique_id
)
SELECT ol.was_late,
       COUNT(DISTINCT cfo.customer_unique_id) AS customers,
       SUM(CASE WHEN coc.total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN coc.total_orders > 1 THEN 1 ELSE 0 END)
             / COUNT(DISTINCT cfo.customer_unique_id), 2) AS repeat_rate_pct
FROM customer_first_order cfo
JOIN order_lateness ol ON cfo.first_order_id = ol.order_id
JOIN customer_order_counts coc ON cfo.customer_unique_id = coc.customer_unique_id
GROUP BY ol.was_late;


/* ------------------------------------------------------------
   Q3: RFM customer segmentation (Recency- when was the last purchase, Frequency- how many purchases, Monetary- how much was spent)
   Uses NTILE() to score every customer, then buckets into
   named segments.
   ------------------------------------------------------------ */
WITH customer_rfm AS (
    SELECT
        c.customer_unique_id,
        DATE '2018-10-17' - MAX(o.order_purchase_timestamp)::date AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC)     AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC)      AS m_score
    FROM customer_rfm
)
SELECT
    CASE
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
        WHEN r_score >= 3 AND f_score <= 2 THEN 'New/Promising'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk (were loyal)'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost/Low Value'
        ELSE 'Needs Attention'
    END AS segment,
    COUNT(*) AS num_customers,
    ROUND(AVG(monetary), 2) AS avg_spend,
    ROUND(SUM(monetary), 2) AS total_revenue
FROM rfm_scored
GROUP BY segment
ORDER BY total_revenue DESC;


/* -----------------------------------------------------------------
   Q4: Determining if there is growth as the months progresses 
   and what percentange is every month growing relative to the other
   Month-over-month revenue change using LAG().
   ----------------------------------------------------------------- */
WITH monthly AS (
    SELECT TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS ym,
           SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY ym
    HAVING TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') BETWEEN '2017-01' AND '2018-08'
)
SELECT ym, revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY ym), 2) AS change_vs_prev_month,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY ym))
             / LAG(revenue) OVER (ORDER BY ym), 1) AS pct_growth
FROM monthly
ORDER BY ym;


/* ------------------------------------------------------------
   Q5: Does a bad first-order review predict churn?
   Comparing repeat-purchase rate by the review score given
   on each customer's FIRST order.
   ------------------------------------------------------------ */
WITH first_order AS (
    SELECT c.customer_unique_id, o.order_id,
           ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id
                               ORDER BY o.order_purchase_timestamp) AS rn
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
first_order_review AS (
    SELECT fo.customer_unique_id, r.review_score
    FROM first_order fo
    JOIN order_reviews r ON fo.order_id = r.order_id
    WHERE fo.rn = 1
),
customer_order_counts AS (
    SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT fr.review_score,
       COUNT(*) AS customers,
       SUM(CASE WHEN coc.total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN coc.total_orders > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM first_order_review fr
JOIN customer_order_counts coc ON fr.customer_unique_id = coc.customer_unique_id
GROUP BY fr.review_score
ORDER BY fr.review_score;
