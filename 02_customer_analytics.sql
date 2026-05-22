-- ============================================================
-- iTunes Music Analysis — Customer Analytics
-- Database: MySQL
-- ============================================================


-- ============================================================
-- Q1: Which customers have spent the most money?
-- ============================================================

SELECT
    CONCAT(c.first_name, ' ', c.last_name)     AS customer_name,
    c.email,
    c.country,
    COUNT(i.invoice_id)                         AS total_purchases,
    ROUND(SUM(i.total), 2)                      AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.country
ORDER BY total_spent DESC
LIMIT 10;


-- ============================================================
-- Q2: What is the average customer lifetime value (CLV)?
-- ============================================================

SELECT
    ROUND(AVG(customer_total), 2)               AS avg_lifetime_value,
    ROUND(MIN(customer_total), 2)               AS min_lifetime_value,
    ROUND(MAX(customer_total), 2)               AS max_lifetime_value
FROM (
    SELECT
        c.customer_id,
        SUM(i.total)                            AS customer_total
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) AS customer_spend;


-- ============================================================
-- Q3: Repeat purchasers vs one-time purchasers
-- ============================================================

SELECT
    purchase_type,
    COUNT(*)                                    AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM (
    SELECT
        c.customer_id,
        CASE
            WHEN COUNT(i.invoice_id) = 1 THEN 'One-time purchaser'
            ELSE 'Repeat purchaser'
        END                                     AS purchase_type
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) AS purchase_classification
GROUP BY purchase_type;


-- ============================================================
-- Q4: Which country generates the most revenue per customer?
-- ============================================================

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id)               AS customer_count,
    ROUND(SUM(i.total), 2)                      AS total_revenue,
    ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue_per_customer DESC
LIMIT 15;


-- ============================================================
-- Q5: Customers who haven't purchased in the last 6 months
--     (relative to the latest invoice date in the dataset)
-- ============================================================

-- First find the latest date in the dataset
SELECT MAX(invoice_date) AS latest_date FROM invoice;

-- Then find inactive customers
SELECT
    CONCAT(c.first_name, ' ', c.last_name)     AS customer_name,
    c.email,
    c.country,
    MAX(i.invoice_date)                         AS last_purchase_date,
    TIMESTAMPDIFF(MONTH, MAX(i.invoice_date),
        (SELECT MAX(invoice_date) FROM invoice)) AS months_inactive
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.country
HAVING months_inactive >= 6
ORDER BY months_inactive DESC;


-- ============================================================
-- Q6: Distribution of customers by number of purchases
-- ============================================================

SELECT
    total_purchases,
    COUNT(*)                                    AS customer_count
FROM (
    SELECT
        c.customer_id,
        COUNT(i.invoice_id)                     AS total_purchases
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) AS purchase_counts
GROUP BY total_purchases
ORDER BY total_purchases;


-- ============================================================
-- Q7: Average time (in days) between purchases per customer
--     (customers with 2+ purchases only)
-- ============================================================

SELECT
    ROUND(AVG(days_between), 1)                 AS avg_days_between_purchases
FROM (
    SELECT
        customer_id,
        DATEDIFF(
            LEAD(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date),
            invoice_date
        )                                       AS days_between
    FROM invoice
) AS gaps
WHERE days_between IS NOT NULL;


-- ============================================================
-- Q8: Customers who purchase from more than one genre
-- ============================================================

SELECT
    CONCAT(c.first_name, ' ', c.last_name)     AS customer_name,
    c.country,
    COUNT(DISTINCT g.genre_id)                  AS genres_purchased
FROM customer c
JOIN invoice i      ON c.customer_id  = i.customer_id
JOIN invoice_line il ON i.invoice_id  = il.invoice_id
JOIN track t        ON il.track_id    = t.track_id
JOIN genre g        ON t.genre_id     = g.genre_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY genres_purchased DESC;

-- Summary: % of customers buying from multiple genres
SELECT
    CASE
        WHEN genres_purchased = 1 THEN 'Single genre'
        ELSE 'Multiple genres'
    END                                         AS genre_diversity,
    COUNT(*)                                    AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM (
    SELECT
        c.customer_id,
        COUNT(DISTINCT g.genre_id)              AS genres_purchased
    FROM customer c
    JOIN invoice i       ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id  = il.invoice_id
    JOIN track t         ON il.track_id   = t.track_id
    JOIN genre g         ON t.genre_id    = g.genre_id
    GROUP BY c.customer_id
) AS genre_counts
GROUP BY genre_diversity;


-- ============================================================
-- Q9: Full customer summary (combine key metrics)
-- ============================================================

SELECT
    CONCAT(c.first_name, ' ', c.last_name)     AS customer_name,
    c.country,
    COUNT(DISTINCT i.invoice_id)                AS total_invoices,
    COUNT(il.invoice_line_id)                   AS total_tracks_bought,
    ROUND(SUM(i.total), 2)                      AS total_spent,
    ROUND(AVG(i.total), 2)                      AS avg_invoice_value,
    MIN(i.invoice_date)                         AS first_purchase,
    MAX(i.invoice_date)                         AS last_purchase,
    TIMESTAMPDIFF(MONTH,
        MIN(i.invoice_date),
        MAX(i.invoice_date))                    AS customer_lifespan_months
FROM customer c
JOIN invoice i       ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id  = il.invoice_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_spent DESC;
