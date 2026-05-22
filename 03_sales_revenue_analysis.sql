-- ============================================================
-- iTunes Music Analysis — Sales & Revenue Analysis
-- Database: MySQL
-- ============================================================


-- ============================================================
-- Q1: Monthly revenue trends
-- ============================================================

SELECT
    YEAR(invoice_date)                          AS year,
    MONTH(invoice_date)                         AS month,
    DATE_FORMAT(invoice_date, '%b %Y')          AS month_label,
    COUNT(invoice_id)                           AS invoice_count,
    ROUND(SUM(total), 2)                        AS monthly_revenue
FROM invoice
GROUP BY YEAR(invoice_date), MONTH(invoice_date), month_label
ORDER BY year, month;


-- ============================================================
-- Q2: Quarterly revenue trends
-- ============================================================

SELECT
    YEAR(invoice_date)                          AS year,
    QUARTER(invoice_date)                       AS quarter,
    CONCAT('Q', QUARTER(invoice_date), ' ',
           YEAR(invoice_date))                  AS quarter_label,
    COUNT(invoice_id)                           AS invoice_count,
    ROUND(SUM(total), 2)                        AS quarterly_revenue
FROM invoice
GROUP BY YEAR(invoice_date), QUARTER(invoice_date), quarter_label
ORDER BY year, quarter;


-- ============================================================
-- Q3: Average invoice value overall and by country
-- ============================================================

-- Overall
SELECT
    ROUND(AVG(total), 2)                        AS avg_invoice_value,
    ROUND(STDDEV(total), 2)                     AS std_dev
FROM invoice;

-- By country
SELECT
    billing_country,
    COUNT(*)                                    AS invoice_count,
    ROUND(AVG(total), 2)                        AS avg_invoice_value,
    ROUND(SUM(total), 2)                        AS total_revenue
FROM invoice
GROUP BY billing_country
ORDER BY avg_invoice_value DESC
LIMIT 15;


-- ============================================================
-- Q4: Peak months and quarters for music sales
-- ============================================================

-- Best months (across all years combined)
SELECT
    DATE_FORMAT(invoice_date, '%M')             AS month_name,
    MONTH(invoice_date)                         AS month_number,
    COUNT(invoice_id)                           AS invoice_count,
    ROUND(SUM(total), 2)                        AS total_revenue,
    ROUND(AVG(total), 2)                        AS avg_revenue
FROM invoice
GROUP BY month_name, month_number
ORDER BY total_revenue DESC;

-- Best quarters (across all years combined)
SELECT
    CONCAT('Q', QUARTER(invoice_date))          AS quarter,
    COUNT(invoice_id)                           AS invoice_count,
    ROUND(SUM(total), 2)                        AS total_revenue
FROM invoice
GROUP BY quarter
ORDER BY total_revenue DESC;


-- ============================================================
-- Q5: Revenue contribution per sales representative
-- ============================================================

SELECT
    CONCAT(e.first_name, ' ', e.last_name)      AS sales_rep,
    e.title,
    COUNT(DISTINCT c.customer_id)               AS customers_managed,
    COUNT(i.invoice_id)                         AS total_invoices,
    ROUND(SUM(i.total), 2)                      AS total_revenue,
    ROUND(AVG(i.total), 2)                      AS avg_invoice_value,
    ROUND(SUM(i.total) * 100.0 /
        SUM(SUM(i.total)) OVER (), 1)           AS revenue_share_pct
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i  ON c.customer_id = i.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.title
ORDER BY total_revenue DESC;


-- ============================================================
-- Q6: Revenue by media type (MPEG, AAC, etc.)
-- ============================================================

SELECT
    mt.name                                     AS media_type,
    COUNT(DISTINCT t.track_id)                  AS tracks_available,
    SUM(il.quantity)                            AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS total_revenue,
    ROUND(SUM(il.unit_price * il.quantity) * 100.0 /
        SUM(SUM(il.unit_price * il.quantity)) OVER (), 1) AS revenue_share_pct
FROM media_type mt
JOIN track t        ON mt.media_type_id = t.media_type_id
JOIN invoice_line il ON t.track_id      = il.track_id
GROUP BY mt.media_type_id, mt.name
ORDER BY total_revenue DESC;


-- ============================================================
-- Q7: Year-over-year revenue growth
-- ============================================================

SELECT
    year,
    annual_revenue,
    LAG(annual_revenue) OVER (ORDER BY year)    AS prev_year_revenue,
    ROUND(
        (annual_revenue - LAG(annual_revenue) OVER (ORDER BY year))
        / LAG(annual_revenue) OVER (ORDER BY year) * 100
    , 1)                                        AS yoy_growth_pct
FROM (
    SELECT
        YEAR(invoice_date)                      AS year,
        ROUND(SUM(total), 2)                    AS annual_revenue
    FROM invoice
    GROUP BY YEAR(invoice_date)
) AS yearly
ORDER BY year;


-- ============================================================
-- Q8: Invoice value buckets (understanding purchase sizes)
-- ============================================================

SELECT
    CASE
        WHEN total < 2    THEN 'Under $2'
        WHEN total < 5    THEN '$2 – $4.99'
        WHEN total < 10   THEN '$5 – $9.99'
        WHEN total < 15   THEN '$10 – $14.99'
        ELSE '$15 and above'
    END                                         AS invoice_bucket,
    COUNT(*)                                    AS invoice_count,
    ROUND(SUM(total), 2)                        AS bucket_revenue,
    ROUND(AVG(total), 2)                        AS avg_invoice_in_bucket
FROM invoice
GROUP BY invoice_bucket
ORDER BY MIN(total);


-- ============================================================
-- Q9: Running total of revenue over time (cumulative growth)
-- ============================================================

SELECT
    DATE_FORMAT(invoice_date, '%Y-%m')          AS month,
    ROUND(SUM(total), 2)                        AS monthly_revenue,
    ROUND(SUM(SUM(total)) OVER (
        ORDER BY DATE_FORMAT(invoice_date, '%Y-%m')
    ), 2)                                       AS cumulative_revenue
FROM invoice
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY month;


-- ============================================================
-- Q10: Top 10 highest value individual invoices
-- ============================================================

SELECT
    i.invoice_id,
    CONCAT(c.first_name, ' ', c.last_name)      AS customer_name,
    c.country,
    i.invoice_date,
    i.total,
    COUNT(il.invoice_line_id)                   AS tracks_purchased
FROM invoice i
JOIN customer c      ON i.customer_id  = c.customer_id
JOIN invoice_line il ON i.invoice_id   = il.invoice_id
GROUP BY i.invoice_id, c.first_name, c.last_name, c.country, i.invoice_date, i.total
ORDER BY i.total DESC
LIMIT 10;
