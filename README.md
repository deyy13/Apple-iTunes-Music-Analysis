# 🎵 Apple iTunes Music Store Analysis

A complete end-to-end data analysis project on the Apple iTunes music store database using **MySQL** and **Power BI**.

---

## 📌 Project Overview

Apple iTunes maintains a large digital music store with millions of tracks, thousands of customers worldwide, and a network of employees managing sales operations. This project analyzes the iTunes relational database to generate actionable insights that help improve product offerings, customer targeting, and operational efficiency.

---

## 🎯 Business Goals

1. Understand customer behavior and purchasing trends
2. Identify the most and least popular music genres, tracks, and artists
3. Evaluate sales performance by employees and customer regions
4. Analyze revenue trends across time and product types
5. Uncover growth opportunities by identifying underutilized content or inactive customers

---

## 🗂️ Project Structure

```
Apple-iTunes-Music-Analysis/
│
├── data/                          # Raw CSV datasets
│   ├── album.csv
│   ├── artist.csv
│   ├── customer.csv
│   ├── employee.csv
│   ├── genre.csv
│   ├── invoice.csv
│   ├── invoice_line.csv
│   ├── media_type.csv
│   ├── playlist.csv
│   ├── playlist_track.csv
│   └── track.csv
│
├── sql/                           # SQL analysis files
│   ├── 01_exploratory_analysis.sql
│   ├── 02_customer_analytics.sql
│   ├── 03_sales_revenue_analysis.sql
│   ├── 04_product_content_analysis.sql
│   ├── 05_artist_genre_performance.sql
│   └── 06_employee_geographic_analysis.sql
│
├── dashboard/                     # Power BI dashboard
│   └── iTunes_Apple_Music_Analysis.pbix
│
├── report/                        # Final report
│   └── iTunes_Analysis_Report.pdf
│
└── README.md
```

---

## 🗄️ Database Schema

The database consists of 11 tables with the following relationships:

| Table | Description |
|---|---|
| `customer` | Customer details including country and support rep |
| `employee` | Employee hierarchy and roles |
| `invoice` | Purchase invoices per customer |
| `invoice_line` | Individual track purchases per invoice |
| `track` | Track details including price and media type |
| `album` | Albums linked to artists |
| `artist` | Artist names |
| `genre` | Music genres |
| `media_type` | Media formats (MPEG, AAC, etc.) |
| `playlist` | Playlists available in the store |
| `playlist_track` | Tracks within each playlist |

**Key Relationships:**
- `invoice.customer_id` → `customer.customer_id`
- `invoice_line.invoice_id` → `invoice.invoice_id`
- `invoice_line.track_id` → `track.track_id`
- `track.album_id` → `album.album_id`
- `album.artist_id` → `artist.artist_id`
- `track.genre_id` → `genre.genre_id`

---

## 🔍 SQL Analysis

### File 1 — Exploratory Analysis
- Row count validation across all 11 tables
- Date range of the dataset
- Revenue overview by country and year
- Music catalog overview by genre and media type
- Top customers and best-selling tracks

### File 2 — Customer Analytics
- Top customers by total spend
- Average customer lifetime value
- Repeat vs one-time purchaser segmentation
- Revenue per country
- Inactive customer identification
- Genre diversity per customer

### File 3 — Sales & Revenue Analysis
- Monthly and quarterly revenue trends
- Year-over-year growth using `LAG()` window function
- Revenue by sales representative
- Invoice value distribution
- Cumulative revenue using running `SUM()`

### File 4 — Product & Content Analysis
- Top 20 tracks and albums by revenue
- Dead stock — tracks never purchased (1500+ tracks)
- Playlist purchase analysis
- Media type revenue trends
- Track purchase combinations (market basket analysis)

### File 5 — Artist & Genre Performance
- Top 10 highest-grossing artists
- Genre market share by units sold and revenue
- Top genre per country using `RANK()` and CTEs
- Artists with zero sales
- Genre revenue trends by year

### File 6 — Employee & Geographic Analysis
- Full employee hierarchy
- Revenue and customer count per sales rep
- Sales rep performance ranking
- Revenue by country and city
- Underserved geographic regions

---

## 📊 Power BI Dashboard

The dashboard has **4 pages:**

### Page 1 — Overview
- Total Revenue, Customers, Invoices, Avg Invoice Value (KPI cards)
- Monthly Revenue Trend
- Top 10 Customers by Revenue
- Top Genres by Sales
- Revenue by Country

### Page 2 — Customer Analytics
- Top 3 Invoice Values
- Top 5 Cities by Revenue
- Countries by Invoice Count

### Page 3 — Artist & Genre
- Top 10 Most Popular Songs
- Top 10 Rock Bands by Track Count
- Top 5 Artists by Revenue
- Average Track Price by Genre

### Page 4 — Employee & Geography
- Revenue by Sales Representative
- Top Countries by Customer Count
- Employee Hierarchy by Seniority

---

## 💡 Key Findings

1. **Total Revenue:** $4,709.43 across 614 invoices from 59 customers
2. **Top Artist:** AC/DC leads in both track count and total revenue
3. **Top Genre:** Rock dominates with nearly 400 units sold
4. **Top Country:** USA generates the most revenue and has the most customers (13)
5. **Best City:** Prague has the highest city-level revenue — ideal for a music festival
6. **Dead Stock:** Over 1,500 tracks have never been purchased
7. **Top Sales Rep:** Jane Peacock generates the highest revenue ($1,731)
8. **Most Senior Employee:** Mohan Madan — Senior General Manager (hired Jan 2016)
9. **Customer Retention:** 100% of customers are repeat purchasers
10. **Pricing:** All genres have a uniform average track price of $0.99

---

## ✅ Recommendations

| Area | Recommendation |
|---|---|
| Marketing | Focus promotions on Rock and Metal genres |
| Events | Host a music festival in Prague |
| Retention | Re-engage inactive customers with targeted campaigns |
| Catalog | Audit and promote 1,500+ never-purchased tracks |
| Geographic | Replicate Czech Republic's high revenue-per-customer strategy in other European markets |
| Pricing | Explore premium pricing for high-demand genres |

---

## 🛠️ Tools & Technologies

- **MySQL** — Database setup and SQL analysis
- **Power BI** — Interactive dashboard
- **Python** — Data cleaning (encoding fixes)
- **GitHub** — Project documentation

---

## 👩‍💻 Author

**Kalpana Naidu**  
Data Analyst | MySQL | Power BI
