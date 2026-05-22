-- ============================================================
-- iTunes Music Analysis — Product & Content Analysis
-- Database: MySQL
-- ============================================================


-- ============================================================
-- Q1: Top 20 tracks by revenue
-- ============================================================

SELECT
    t.name                                      AS track_name,
    ar.name                                     AS artist,
    al.title                                    AS album,
    g.name                                      AS genre,
    SUM(il.quantity)                            AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS total_revenue
FROM invoice_line il
JOIN track t    ON il.track_id   = t.track_id
JOIN album al   ON t.album_id    = al.album_id
JOIN artist ar  ON al.artist_id  = ar.artist_id
JOIN genre g    ON t.genre_id    = g.genre_id
GROUP BY t.track_id, t.name, ar.name, al.title, g.name
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================
-- Q2: Top 10 albums by revenue
-- ============================================================

SELECT
    al.title                                    AS album,
    ar.name                                     AS artist,
    COUNT(DISTINCT t.track_id)                  AS tracks_in_album,
    SUM(il.quantity)                            AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS total_revenue
FROM invoice_line il
JOIN track t    ON il.track_id  = t.track_id
JOIN album al   ON t.album_id   = al.album_id
JOIN artist ar  ON al.artist_id = ar.artist_id
GROUP BY al.album_id, al.title, ar.name
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- Q3: Tracks that have NEVER been purchased (dead stock)
-- ============================================================

SELECT
    t.name                                      AS track_name,
    ar.name                                     AS artist,
    al.title                                    AS album,
    g.name                                      AS genre,
    mt.name                                     AS media_type,
    t.unit_price
FROM track t
LEFT JOIN invoice_line il ON t.track_id    = il.track_id
JOIN album al              ON t.album_id   = al.album_id
JOIN artist ar             ON al.artist_id = ar.artist_id
JOIN genre g               ON t.genre_id   = g.genre_id
JOIN media_type mt         ON t.media_type_id = mt.media_type_id
WHERE il.invoice_line_id IS NULL
ORDER BY g.name, ar.name, t.name;

-- Count of unpurchased tracks
SELECT COUNT(*) AS unpurchased_track_count
FROM track t
LEFT JOIN invoice_line il ON t.track_id = il.track_id
WHERE il.invoice_line_id IS NULL;


-- ============================================================
-- Q4: Albums that have never been purchased
-- ============================================================

SELECT
    al.title                                    AS album,
    ar.name                                     AS artist,
    COUNT(t.track_id)                           AS track_count
FROM album al
JOIN artist ar ON al.artist_id = ar.artist_id
JOIN track t   ON al.album_id  = t.album_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY al.album_id, al.title, ar.name
HAVING SUM(CASE WHEN il.invoice_line_id IS NOT NULL THEN 1 ELSE 0 END) = 0
ORDER BY ar.name;


-- ============================================================
-- Q5: Average track price per genre
-- ============================================================

SELECT
    g.name                                      AS genre,
    COUNT(t.track_id)                           AS total_tracks,
    ROUND(AVG(t.unit_price), 2)                 AS avg_price,
    ROUND(MIN(t.unit_price), 2)                 AS min_price,
    ROUND(MAX(t.unit_price), 2)                 AS max_price
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
GROUP BY g.genre_id, g.name
ORDER BY avg_price DESC;


-- ============================================================
-- Q6: Track count per genre vs actual sales
--     (does having more tracks = more sales?)
-- ============================================================

SELECT
    g.name                                      AS genre,
    COUNT(DISTINCT t.track_id)                  AS tracks_in_catalog,
    COALESCE(SUM(il.quantity), 0)               AS units_sold,
    ROUND(COALESCE(SUM(il.unit_price * il.quantity), 0), 2) AS revenue,
    ROUND(COALESCE(SUM(il.quantity), 0) /
        COUNT(DISTINCT t.track_id), 2)          AS sales_per_track
FROM genre g
LEFT JOIN track t        ON g.genre_id  = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY revenue DESC;


-- ============================================================
-- Q7: Most purchased playlists
--     (how many tracks from each playlist were sold?)
-- ============================================================

SELECT
    p.name                                      AS playlist,
    COUNT(DISTINCT pt.track_id)                 AS tracks_in_playlist,
    COUNT(il.invoice_line_id)                   AS times_tracks_purchased,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS revenue_from_playlist_tracks
FROM playlist p
JOIN playlist_track pt  ON p.playlist_id  = pt.playlist_id
LEFT JOIN invoice_line il ON pt.track_id  = il.track_id
GROUP BY p.playlist_id, p.name
ORDER BY times_tracks_purchased DESC;


-- ============================================================
-- Q8: Revenue by media type trend (is AAC growing vs MPEG?)
-- ============================================================

SELECT
    YEAR(i.invoice_date)                        AS year,
    mt.name                                     AS media_type,
    SUM(il.quantity)                            AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2)  AS revenue
FROM invoice i
JOIN invoice_line il ON i.invoice_id      = il.invoice_id
JOIN track t         ON il.track_id       = t.track_id
JOIN media_type mt   ON t.media_type_id   = mt.media_type_id
GROUP BY YEAR(i.invoice_date), mt.media_type_id, mt.name
ORDER BY year, revenue DESC;


-- ============================================================
-- Q9: Track purchase frequency distribution
--     (how many tracks were bought 1x, 2x, 3x+ ?)
-- ============================================================

SELECT
    times_purchased,
    COUNT(*)                                    AS track_count
FROM (
    SELECT
        t.track_id,
        COALESCE(SUM(il.quantity), 0)           AS times_purchased
    FROM track t
    LEFT JOIN invoice_line il ON t.track_id = il.track_id
    GROUP BY t.track_id
) AS track_sales
GROUP BY times_purchased
ORDER BY times_purchased;


-- ============================================================
-- Q10: Top 10 most purchased track combinations
--      (tracks frequently bought in the same invoice)
-- ============================================================

SELECT
    t1.name                                     AS track_1,
    t2.name                                     AS track_2,
    COUNT(*)                                    AS times_bought_together
FROM invoice_line il1
JOIN invoice_line il2 ON il1.invoice_id  = il2.invoice_id
                      AND il1.track_id   < il2.track_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
GROUP BY t1.name, t2.name
ORDER BY times_bought_together DESC
LIMIT 10;
