-- ============================================================
-- iTunes Music Analysis — Artist & Genre Performance
-- Database: MySQL
-- ============================================================


-- ============================================================
-- Q1: Top 10 highest-grossing artists
-- ============================================================

SELECT
    ar.name                                     AS artist,
    COUNT(DISTINCT al.album_id)                 AS total_albums,
    COUNT(DISTINCT t.track_id)                  AS total_tracks,
    SUM(il.quantity)                            AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS total_revenue
FROM artist ar
JOIN album al        ON ar.artist_id  = al.artist_id
JOIN track t         ON al.album_id   = t.album_id
JOIN invoice_line il ON t.track_id    = il.track_id
GROUP BY ar.artist_id, ar.name
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- Q2: Top 10 genres by units sold
-- ============================================================

SELECT
    g.name                                      AS genre,
    SUM(il.quantity)                            AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS total_revenue,
    ROUND(SUM(il.quantity) * 100.0 /
        SUM(SUM(il.quantity)) OVER (), 1)       AS market_share_pct
FROM genre g
JOIN track t         ON g.genre_id  = t.genre_id
JOIN invoice_line il ON t.track_id  = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY units_sold DESC;


-- ============================================================
-- Q3: Top 10 genres by total revenue
-- ============================================================

SELECT
    g.name                                      AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS total_revenue,
    ROUND(SUM(il.unit_price * il.quantity) * 100.0 /
        SUM(SUM(il.unit_price * il.quantity)) OVER (), 1) AS revenue_share_pct,
    COUNT(DISTINCT t.track_id)                  AS tracks_in_catalog,
    SUM(il.quantity)                            AS units_sold
FROM genre g
JOIN track t         ON g.genre_id  = t.genre_id
JOIN invoice_line il ON t.track_id  = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY total_revenue DESC;


-- ============================================================
-- Q4: Genre popularity by country
--     (which genre is #1 in each country?)
-- ============================================================

WITH genre_country AS (
    SELECT
        i.billing_country                       AS country,
        g.name                                  AS genre,
        SUM(il.quantity)                        AS units_sold,
        RANK() OVER (
            PARTITION BY i.billing_country
            ORDER BY SUM(il.quantity) DESC
        )                                       AS genre_rank
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id  = il.invoice_id
    JOIN track t         ON il.track_id   = t.track_id
    JOIN genre g         ON t.genre_id    = g.genre_id
    GROUP BY i.billing_country, g.genre_id, g.name
)
SELECT
    country,
    genre                                       AS top_genre,
    units_sold
FROM genre_country
WHERE genre_rank = 1
ORDER BY units_sold DESC;


-- ============================================================
-- Q5: Full genre breakdown by country (top 3 genres per country)
-- ============================================================

WITH genre_country AS (
    SELECT
        i.billing_country                       AS country,
        g.name                                  AS genre,
        SUM(il.quantity)                        AS units_sold,
        RANK() OVER (
            PARTITION BY i.billing_country
            ORDER BY SUM(il.quantity) DESC
        )                                       AS genre_rank
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id  = il.invoice_id
    JOIN track t         ON il.track_id   = t.track_id
    JOIN genre g         ON t.genre_id    = g.genre_id
    GROUP BY i.billing_country, g.genre_id, g.name
)
SELECT
    country,
    genre,
    units_sold,
    genre_rank
FROM genre_country
WHERE genre_rank <= 3
ORDER BY country, genre_rank;


-- ============================================================
-- Q6: Artists with tracks in the most genres
--     (most versatile artists)
-- ============================================================

SELECT
    ar.name                                     AS artist,
    COUNT(DISTINCT g.genre_id)                  AS genres_spanned,
    GROUP_CONCAT(DISTINCT g.name ORDER BY g.name SEPARATOR ', ') AS genres
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t  ON al.album_id  = t.album_id
JOIN genre g  ON t.genre_id   = g.genre_id
GROUP BY ar.artist_id, ar.name
ORDER BY genres_spanned DESC
LIMIT 15;


-- ============================================================
-- Q7: Artists with zero sales (never purchased)
-- ============================================================

SELECT
    ar.name                                     AS artist,
    COUNT(DISTINCT al.album_id)                 AS albums_in_store,
    COUNT(DISTINCT t.track_id)                  AS tracks_in_store
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t  ON al.album_id  = t.album_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY ar.artist_id, ar.name
HAVING SUM(CASE WHEN il.invoice_line_id IS NOT NULL THEN 1 ELSE 0 END) = 0
ORDER BY tracks_in_store DESC;


-- ============================================================
-- Q8: Genre revenue trend by year
--     (which genres are growing or declining?)
-- ============================================================

SELECT
    YEAR(i.invoice_date)                        AS year,
    g.name                                      AS genre,
    SUM(il.quantity)                            AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS revenue
FROM invoice i
JOIN invoice_line il ON i.invoice_id  = il.invoice_id
JOIN track t         ON il.track_id   = t.track_id
JOIN genre g         ON t.genre_id    = g.genre_id
GROUP BY YEAR(i.invoice_date), g.genre_id, g.name
ORDER BY year, revenue DESC;


-- ============================================================
-- Q9: Top artist per genre by revenue
-- ============================================================

WITH artist_genre_revenue AS (
    SELECT
        g.name                                  AS genre,
        ar.name                                 AS artist,
        ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue,
        RANK() OVER (
            PARTITION BY g.genre_id
            ORDER BY SUM(il.unit_price * il.quantity) DESC
        )                                       AS artist_rank
    FROM genre g
    JOIN track t         ON g.genre_id   = t.genre_id
    JOIN album al        ON t.album_id   = al.album_id
    JOIN artist ar       ON al.artist_id = ar.artist_id
    JOIN invoice_line il ON t.track_id   = il.track_id
    GROUP BY g.genre_id, g.name, ar.artist_id, ar.name
)
SELECT
    genre,
    artist                                      AS top_artist,
    revenue
FROM artist_genre_revenue
WHERE artist_rank = 1
ORDER BY revenue DESC;


-- ============================================================
-- Q10: Average revenue per track by artist (efficiency metric)
--      Which artists earn the most per track available?
-- ============================================================

SELECT
    ar.name                                     AS artist,
    COUNT(DISTINCT t.track_id)                  AS total_tracks,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS total_revenue,
    ROUND(SUM(il.unit_price * il.quantity) /
        COUNT(DISTINCT t.track_id), 2)          AS revenue_per_track
FROM artist ar
JOIN album al        ON ar.artist_id = al.artist_id
JOIN track t         ON al.album_id  = t.album_id
JOIN invoice_line il ON t.track_id   = il.track_id
GROUP BY ar.artist_id, ar.name
HAVING COUNT(DISTINCT t.track_id) >= 5          -- at least 5 tracks for fairness
ORDER BY revenue_per_track DESC
LIMIT 15;
