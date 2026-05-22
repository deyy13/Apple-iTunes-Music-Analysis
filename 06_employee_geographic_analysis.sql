-- ============================================================
-- iTunes Music Analysis — Employee & Geographic Analysis
-- Database: MySQL
-- ============================================================


-- ============================================================
-- PART A: EMPLOYEE & OPERATIONAL EFFICIENCY
-- ============================================================


-- ============================================================
-- Q1: Full employee hierarchy
-- ============================================================

SELECT
    CONCAT(e.first_name, ' ', e.last_name)      AS employee,
    e.title,
    e.hire_date,
    CONCAT(m.first_name, ' ', m.last_name)      AS reports_to,
    e.city,
    e.country
FROM employee e
LEFT JOIN employee m ON e.reports_to = m.employee_id
ORDER BY e.reports_to, e.employee_id;


-- ============================================================
-- Q2: Customers and revenue per support representative
-- ============================================================

SELECT
    CONCAT(e.first_name, ' ', e.last_name)      AS sales_rep,
    e.title,
    e.hire_date,
    COUNT(DISTINCT c.customer_id)               AS total_customers,
    COUNT(i.invoice_id)                         AS total_invoices,
    ROUND(SUM(i.total), 2)                      AS total_revenue,
    ROUND(AVG(i.total), 2)                      AS avg_invoice_value,
    ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM employee e
LEFT JOIN customer c ON e.employee_id  = c.support_rep_id
LEFT JOIN invoice i  ON c.customer_id  = i.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.title, e.hire_date
ORDER BY total_revenue DESC;


-- ============================================================
-- Q3: Average number of customers per employee
-- ============================================================

SELECT
    ROUND(AVG(customer_count), 1)               AS avg_customers_per_rep,
    MIN(customer_count)                         AS min_customers,
    MAX(customer_count)                         AS max_customers
FROM (
    SELECT
        e.employee_id,
        COUNT(c.customer_id)                    AS customer_count
    FROM employee e
    LEFT JOIN customer c ON e.employee_id = c.support_rep_id
    GROUP BY e.employee_id
) AS rep_counts;


-- ============================================================
-- Q4: Monthly revenue per sales rep (performance over time)
-- ============================================================

SELECT
    CONCAT(e.first_name, ' ', e.last_name)      AS sales_rep,
    DATE_FORMAT(i.invoice_date, '%Y-%m')        AS month,
    COUNT(i.invoice_id)                         AS invoices,
    ROUND(SUM(i.total), 2)                      AS monthly_revenue
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i  ON c.customer_id = i.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name, DATE_FORMAT(i.invoice_date, '%Y-%m')
ORDER BY month, monthly_revenue DESC;


-- ============================================================
-- Q5: Sales rep performance ranking using RANK()
-- ============================================================

SELECT
    sales_rep,
    total_revenue,
    total_customers,
    RANK() OVER (ORDER BY total_revenue DESC)   AS revenue_rank,
    RANK() OVER (ORDER BY total_customers DESC) AS customer_rank
FROM (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name)  AS sales_rep,
        COUNT(DISTINCT c.customer_id)            AS total_customers,
        ROUND(SUM(i.total), 2)                   AS total_revenue
    FROM employee e
    JOIN customer c ON e.employee_id = c.support_rep_id
    JOIN invoice i  ON c.customer_id = i.customer_id
    GROUP BY e.employee_id, e.first_name, e.last_name
) AS rep_summary;


-- ============================================================
-- PART B: GEOGRAPHIC TRENDS
-- ============================================================


-- ============================================================
-- Q6: Countries with the highest number of customers
-- ============================================================

SELECT
    country,
    COUNT(customer_id)                          AS customer_count,
    ROUND(COUNT(customer_id) * 100.0 /
        SUM(COUNT(customer_id)) OVER (), 1)     AS pct_of_total
FROM customer
GROUP BY country
ORDER BY customer_count DESC;


-- ============================================================
-- Q7: Revenue by country with per-customer breakdown
-- ============================================================

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id)               AS customers,
    COUNT(i.invoice_id)                         AS invoices,
    ROUND(SUM(i.total), 2)                      AS total_revenue,
    ROUND(AVG(i.total), 2)                      AS avg_invoice_value,
    ROUND(SUM(i.total) /
        COUNT(DISTINCT c.customer_id), 2)       AS revenue_per_customer
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;


-- ============================================================
-- Q8: Cities with the highest number of customers
-- ============================================================

SELECT
    city,
    country,
    COUNT(customer_id)                          AS customer_count
FROM customer
GROUP BY city, country
ORDER BY customer_count DESC
LIMIT 20;


-- ============================================================
-- Q9: Underserved regions
--     (countries with customers but low average spend)
-- ============================================================

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id)               AS customers,
    ROUND(SUM(i.total), 2)                      AS total_revenue,
    ROUND(SUM(i.total) /
        COUNT(DISTINCT c.customer_id), 2)       AS revenue_per_customer,
    CASE
        WHEN SUM(i.total) /
             COUNT(DISTINCT c.customer_id) <
             (SELECT AVG(total) FROM invoice)
        THEN 'Underserved'
        ELSE 'Well served'
    END                                         AS status
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue_per_customer ASC;


-- ============================================================
-- Q10: Genre preferences by country
--      (top genre per country with revenue)
-- ============================================================

WITH country_genre AS (
    SELECT
        i.billing_country                       AS country,
        g.name                                  AS genre,
        SUM(il.quantity)                        AS units_sold,
        ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue,
        RANK() OVER (
            PARTITION BY i.billing_country
            ORDER BY SUM(il.unit_price * il.quantity) DESC
        )                                       AS rnk
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id  = il.invoice_id
    JOIN track t         ON il.track_id   = t.track_id
    JOIN genre g         ON t.genre_id    = g.genre_id
    GROUP BY i.billing_country, g.genre_id, g.name
)
SELECT
    country,
    genre                                       AS top_genre,
    units_sold,
    revenue
FROM country_genre
WHERE rnk = 1
ORDER BY revenue DESC;


-- ============================================================
-- Q11: Revenue growth by country year over year
-- ============================================================

SELECT
    billing_country                             AS country,
    YEAR(invoice_date)                          AS year,
    ROUND(SUM(total), 2)                        AS annual_revenue,
    ROUND(SUM(total) - LAG(SUM(total)) OVER (
        PARTITION BY billing_country
        ORDER BY YEAR(invoice_date)
    ), 2)                                       AS yoy_change
FROM invoice
GROUP BY billing_country, YEAR(invoice_date)
ORDER BY billing_country, year;
