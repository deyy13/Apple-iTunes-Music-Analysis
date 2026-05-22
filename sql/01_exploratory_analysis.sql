-- ============================================================
-- iTunes Music Analysis — Exploratory Analysis
-- Database: MySQL
-- Run these queries one section at a time in MySQL Workbench
-- ============================================================


-- ============================================================
-- SECTION 1: ROW COUNTS (Are all records imported correctly?)
-- ============================================================

SELECT 'customer'       AS table_name, COUNT(*) AS row_count FROM customer
UNION ALL
SELECT 'employee',                      COUNT(*) FROM employee
UNION ALL
SELECT 'invoice',                       COUNT(*) FROM invoice
UNION ALL
SELECT 'invoice_line',                  COUNT(*) FROM invoice_line
UNION ALL
SELECT 'track',                         COUNT(*) FROM track
UNION ALL
SELECT 'album',                         COUNT(*) FROM album
UNION ALL
SELECT 'artist',                        COUNT(*) FROM artist
UNION ALL
SELECT 'genre',                         COUNT(*) FROM genre
UNION ALL
SELECT 'media_type',                    COUNT(*) FROM media_type
UNION ALL
SELECT 'playlist',                      COUNT(*) FROM playlist
UNION ALL
SELECT 'playlist_track',                COUNT(*) FROM playlist_track;


-- ============================================================
-- SECTION 2: DATE RANGE (What time period does the data cover?)
-- ============================================================

SELECT
    MIN(invoice_date)                        AS earliest_invoice,
    MAX(invoice_date)                        AS latest_invoice,
    TIMESTAMPDIFF(MONTH,
        MIN(invoice_date),
        MAX(invoice_date))                   AS months_covered
FROM invoice;


-- ============================================================
-- SECTION 3: CUSTOMER OVERVIEW
-- ============================================================

-- Total customers by country (top 10)
SELECT
    country,
    COUNT(*)                                 AS customer_count
FROM customer
GROUP BY country
ORDER BY customer_count DESC
LIMIT 10;

-- Customers with no support rep assigned (data quality check)
SELECT COUNT(*) AS customers_without_rep
FROM customer
WHERE support_rep_id IS NULL;


-- ============================================================
-- SECTION 4: REVENUE OVERVIEW
-- ============================================================

-- Overall revenue stats
SELECT
    ROUND(SUM(total), 2)                     AS total_revenue,
    ROUND(AVG(total), 2)                     AS avg_invoice_value,
    ROUND(MIN(total), 2)                     AS min_invoice,
    ROUND(MAX(total), 2)                     AS max_invoice,
    COUNT(*)                                 AS total_invoices
FROM invoice;

-- Revenue by country (top 10)
SELECT
    billing_country,
    COUNT(*)                                 AS invoice_count,
    ROUND(SUM(total), 2)                     AS total_revenue,
    ROUND(AVG(total), 2)                     AS avg_revenue_per_invoice
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC
LIMIT 10;

-- Revenue by year
SELECT
    YEAR(invoice_date)                       AS year,
    COUNT(*)                                 AS invoice_count,
    ROUND(SUM(total), 2)                     AS annual_revenue
FROM invoice
GROUP BY YEAR(invoice_date)
ORDER BY year;


-- ============================================================
-- SECTION 5: MUSIC CATALOG OVERVIEW
-- ============================================================

-- Track count per genre
SELECT
    g.name                                   AS genre,
    COUNT(t.track_id)                        AS track_count
FROM genre g
LEFT JOIN track t ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY track_count DESC;

-- Track count per media type
SELECT
    mt.name                                  AS media_type,
    COUNT(t.track_id)                        AS track_count
FROM media_type mt
LEFT JOIN track t ON mt.media_type_id = t.media_type_id
GROUP BY mt.name
ORDER BY track_count DESC;

-- Average track price per genre
SELECT
    g.name                                   AS genre,
    ROUND(AVG(t.unit_price), 2)              AS avg_price,
    COUNT(t.track_id)                        AS track_count
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY avg_price DESC;

-- Albums per artist (top 10 most prolific artists)
SELECT
    ar.name                                  AS artist,
    COUNT(al.album_id)                       AS album_count
FROM artist ar
LEFT JOIN album al ON ar.artist_id = al.artist_id
GROUP BY ar.name
ORDER BY album_count DESC
LIMIT 10;


-- ============================================================
-- SECTION 6: SALES OVERVIEW
-- ============================================================

-- Top 10 customers by total spend
SELECT
    CONCAT(c.first_name, ' ', c.last_name)   AS customer_name,
    c.country,
    ROUND(SUM(i.total), 2)                   AS total_spent,
    COUNT(i.invoice_id)                      AS purchase_count
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_spent DESC
LIMIT 10;

-- Top 10 best-selling tracks by revenue
SELECT
    t.name                                   AS track_name,
    ar.name                                  AS artist,
    g.name                                   AS genre,
    SUM(il.quantity)                         AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice_line il
JOIN track t  ON il.track_id  = t.track_id
JOIN album al ON t.album_id   = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
JOIN genre g  ON t.genre_id   = g.genre_id
GROUP BY t.track_id, t.name, ar.name, g.name
ORDER BY revenue DESC
LIMIT 10;

-- Tracks that have NEVER been purchased (potential dead stock)
SELECT
    t.name                                   AS track_name,
    ar.name                                  AS artist,
    g.name                                   AS genre
FROM track t
LEFT JOIN invoice_line il ON t.track_id = il.track_id
JOIN album al              ON t.album_id  = al.album_id
JOIN artist ar             ON al.artist_id = ar.artist_id
JOIN genre g               ON t.genre_id  = g.genre_id
WHERE il.invoice_line_id IS NULL
ORDER BY ar.name, t.name;


-- ============================================================
-- SECTION 7: EMPLOYEE OVERVIEW
-- ============================================================

-- Employees and how many customers they support
SELECT
    CONCAT(e.first_name, ' ', e.last_name)   AS employee,
    e.title,
    COUNT(c.customer_id)                     AS customers_supported
FROM employee e
LEFT JOIN customer c ON e.employee_id = c.support_rep_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.title
ORDER BY customers_supported DESC;

-- Revenue generated per support rep
SELECT
    CONCAT(e.first_name, ' ', e.last_name)   AS sales_rep,
    ROUND(SUM(i.total), 2)                   AS total_revenue,
    COUNT(DISTINCT c.customer_id)            AS unique_customers,
    COUNT(i.invoice_id)                      AS total_invoices
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i  ON c.customer_id  = i.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_revenue DESC;


-- ============================================================
-- SECTION 8: PLAYLIST OVERVIEW
-- ============================================================

-- Tracks per playlist (top 10)
SELECT
    p.name                                   AS playlist,
    COUNT(pt.track_id)                       AS track_count
FROM playlist p
LEFT JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
GROUP BY p.name
ORDER BY track_count DESC
LIMIT 10;
