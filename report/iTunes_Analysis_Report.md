# 🎵 Apple iTunes Music Store — Data Analysis Report

**Analyst:** Kalpana Naidu  
**Tool:** MySQL, Power BI  
**Dataset:** iTunes Relational Database (11 Tables)  
**Date:** May 2026

---

## 📋 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Database Setup & Schema](#3-database-setup--schema)
4. [Customer Analytics](#4-customer-analytics)
5. [Sales & Revenue Analysis](#5-sales--revenue-analysis)
6. [Product & Content Analysis](#6-product--content-analysis)
7. [Artist & Genre Performance](#7-artist--genre-performance)
8. [Employee & Geographic Analysis](#8-employee--geographic-analysis)
9. [Recommendations](#9-recommendations)
10. [Conclusion](#10-conclusion)

---

## 1. Executive Summary

This report presents a comprehensive analysis of the Apple iTunes Music Store database. The analysis covers customer behavior, sales performance, music content, artist and genre popularity, and employee efficiency across a dataset spanning 4 years (2017–2020).

**Key Highlights:**
- Total revenue of **$4,709.43** generated from **614 invoices** across **59 customers**
- **Rock** is the dominant genre accounting for the largest share of units sold
- **AC/DC** is the highest-grossing artist in the store
- **USA** leads in customer count and total revenue
- **Prague** is the highest-revenue city — ideal for a promotional music festival
- Over **1,500 tracks** have never been purchased — representing a major catalog optimization opportunity
- **100% of customers** are repeat purchasers — indicating strong customer loyalty

---

## 2. Problem Statement

Apple iTunes maintains a large digital music store with millions of tracks, thousands of customers worldwide, and a network of employees managing sales operations. As the business expands, the leadership team requires deeper insights into:

- Customer purchasing behavior and lifetime value
- Music content performance and dead stock identification
- Sales trends across time and geographies
- Employee efficiency and regional performance

As a Data Analyst, the objective was to build a complete SQL-based analytical pipeline and Power BI dashboard to answer key business questions and provide actionable recommendations.

---

## 3. Database Setup & Schema

### 3.1 Tables & Row Counts

| Table | Rows | Description |
|---|---|---|
| customer | 59 | Customer details |
| employee | 8 | Employee hierarchy |
| invoice | 412 | Purchase transactions |
| invoice_line | 2,240 | Individual track purchases |
| track | 3,503 | Music tracks |
| album | 347 | Albums |
| artist | 275 | Artists |
| genre | 25 | Music genres |
| media_type | 5 | Media formats |
| playlist | 18 | Store playlists |
| playlist_track | 8,715 | Tracks within playlists |

### 3.2 Data Coverage

- **Earliest Invoice:** January 2017
- **Latest Invoice:** December 2020
- **Total Period:** 4 years (48 months)

### 3.3 Entity Relationship Overview

The database follows a star-schema like structure where:
- `invoice_line` is the central fact table
- It connects to `invoice`, `track`, and through track to `album`, `artist`, `genre`, and `media_type`
- `invoice` connects to `customer` which connects to `employee`

---

## 4. Customer Analytics

### 4.1 Top Customers by Spend

The top 5 highest-spending customers are:

| Customer | Country | Total Spent | Purchases |
|---|---|---|---|
| František Wichterlová | Czech Republic | $144.54 | 7 |
| Helena Holý | Czech Republic | $128.70 | 7 |
| Richard Cunningham | USA | $114.84 | 7 |
| Luis Rojas | Chile | $108.90 | 7 |
| Ladislav Kovács | Hungary | $98.01 | 7 |

**Insight:** Czech Republic customers dominate the top spenders list despite the country not having the most customers — indicating high-value customers in this region.

### 4.2 Customer Lifetime Value

| Metric | Value |
|---|---|
| Average CLV | $39.35 |
| Minimum CLV | $3.96 |
| Maximum CLV | $144.54 |

**Insight:** There is a significant gap between the lowest and highest spending customers, suggesting an opportunity to upsell lower-spending customers through personalized recommendations.

### 4.3 Repeat vs One-Time Purchasers

| Purchase Type | Count | Percentage |
|---|---|---|
| Repeat Purchaser | 59 | 100% |
| One-time Purchaser | 0 | 0% |

**Insight:** Every single customer has made more than one purchase — this is an excellent indicator of customer satisfaction and platform stickiness.

### 4.4 Revenue Per Country

| Country | Customers | Total Revenue | Revenue Per Customer |
|---|---|---|---|
| Czech Republic | 2 | $273.24 | $136.62 |
| India | 2 | $183.15 | $91.58 |
| Portugal | 2 | $185.13 | $92.57 |
| USA | 13 | $523.06 | $40.24 |
| Canada | 8 | $303.96 | $37.99 |

**Insight:** Czech Republic, India, and Portugal generate significantly higher revenue per customer than larger markets like USA and Canada — these are high-value markets worth investing in.

### 4.5 Inactive Customers

Several customers have not made a purchase in the last 6 months of the dataset. These customers represent a re-engagement opportunity through targeted email campaigns and promotional offers.

### 4.6 Genre Diversity

The vast majority of customers purchase tracks from **multiple genres** — showing diverse music tastes across the customer base. This supports a broad catalog strategy rather than focusing on a single genre.

---

## 5. Sales & Revenue Analysis

### 5.1 Overall Revenue Stats

| Metric | Value |
|---|---|
| Total Revenue | $4,709.43 |
| Total Invoices | 614 |
| Average Invoice Value | $7.67 |
| Minimum Invoice | $0.99 |
| Maximum Invoice | $23.76 |

### 5.2 Monthly Revenue Trend

Revenue is fairly stable throughout the year ranging between **$350–$500 per month**. There is a slight dip around **July** and a recovery towards the end of the year. Unlike physical retail, digital music sales do not show strong seasonal patterns.

### 5.3 Annual Revenue

| Year | Revenue |
|---|---|
| 2017 | $1,150.37 |
| 2018 | $1,177.26 |
| 2019 | $1,177.26 |
| 2020 | $1,204.54 |

**Insight:** Revenue shows a slow but steady upward trend year over year — a positive sign for business growth.

### 5.4 Invoice Value Distribution

| Bucket | Invoice Count |
|---|---|
| Under $2 | 94 |
| $2 – $4.99 | 192 |
| $5 – $9.99 | 214 |
| $10 – $14.99 | 58 |
| $15 and above | 56 |

**Insight:** Most customers make small purchases in the $2–$10 range. Very few make large purchases — suggesting an opportunity to encourage bundle purchases or subscriptions.

### 5.5 Sales Representative Performance

| Sales Rep | Customers | Revenue | Share |
|---|---|---|---|
| Jane Peacock | 21 | $1,731.51 | 36.8% |
| Margaret Park | 20 | $1,584.00 | 33.6% |
| Steve Johnson | 18 | $1,393.92 | 29.6% |

**Insight:** Revenue is fairly evenly distributed among the 3 sales reps. Jane leads slightly due to managing the most customers. All three are performing at a similar level.

---

## 6. Product & Content Analysis

### 6.1 Top Tracks by Revenue

The best performing tracks include:
- **Balls to the Wall** — highest revenue track
- **Put The Finger On You** — most units sold
- **Inject The Venom** — consistently high performer

**Insight:** Rock tracks dominate the top sellers list — aligning with genre popularity data.

### 6.2 Dead Stock — Unpurchased Tracks

| Metric | Value |
|---|---|
| Total Tracks in Catalog | 3,503 |
| Tracks Never Purchased | ~1,519 |
| Dead Stock Percentage | ~43% |

**Insight:** Nearly half the catalog has never been purchased. This is a critical finding — iTunes should either promote these tracks more aggressively or consider removing them to streamline the catalog.

### 6.3 Unpurchased Albums

Several complete albums have zero sales. These could be candidates for:
- Featured promotions
- Discounted bundle offers
- Catalog removal

### 6.4 Media Type Performance

| Media Type | Revenue Share |
|---|---|
| MPEG audio file | ~75% |
| AAC audio file | ~20% |
| Protected AAC | ~4% |
| Other | ~1% |

**Insight:** MPEG remains the dominant format. Protected formats are declining — reflecting broader industry trends away from DRM-protected content.

### 6.5 Average Track Price by Genre

All genres have a **uniform average price of $0.99 per track**. This reflects iTunes' standardized pricing model. However some premium tracks are priced at **$1.99** — primarily in classical and orchestral genres.

---

## 7. Artist & Genre Performance

### 7.1 Top 5 Highest-Grossing Artists

| Artist | Albums | Tracks | Revenue |
|---|---|---|---|
| AC/DC | 2 | 18 | $149.73 |
| Aerosmith | 1 | 15 | $123.75 |
| Alanis Morissette | 1 | 13 | $107.07 |
| Black Sabbath | 2 | 12 | $98.01 |
| Alice In Chains | 1 | 12 | $98.01 |

**Insight:** AC/DC is the clear market leader. All top grossing artists are Rock bands — reinforcing Rock's dominance in the iTunes catalog.

### 7.2 Genre Performance

| Genre | Units Sold | Revenue | Market Share |
|---|---|---|---|
| Rock | 835 | $826.65 | 17.6% |
| Metal | 264 | $261.36 | 5.6% |
| Alternative & Punk | 244 | $241.56 | 5.1% |
| Latin | 386 | $382.14 | 8.1% |
| Blues | 61 | $60.39 | 1.3% |

**Insight:** Rock dominates sales but Latin has a surprisingly strong showing in terms of units sold despite having fewer tracks in the catalog — indicating high demand per track for Latin music.

### 7.3 Genre Popularity by Country

- **Rock** is the top genre in most English-speaking countries (USA, UK, Canada, Australia)
- **Latin** music ranks higher in Brazil, Argentina, and Mexico
- **Metal** performs particularly well in Scandinavian countries

**Insight:** Genre preferences vary significantly by region — supporting the case for localized marketing campaigns.

### 7.4 Artists with Zero Sales

A number of artists in the catalog have never had a single track purchased. These artists represent dead weight in the catalog and should be reviewed for possible removal or promotion.

---

## 8. Employee & Geographic Analysis

### 8.1 Employee Hierarchy

| Employee | Title | Hire Date |
|---|---|---|
| Mohan Madan | Senior General Manager | Jan 2016 |
| Nancy Edwards | Sales Manager | May 2016 |
| Andrew Adams | General Manager | Aug 2016 |
| Michael Mitchell | IT Manager | Oct 2016 |
| Robert King | IT Staff | Jan 2017 |
| Laura Callahan | IT Staff | Mar 2017 |
| Jane Peacock | Sales Support Agent | Apr 2017 |
| Margaret Park | Sales Support Agent | May 2017 |
| Steve Johnson | Sales Support Agent | Oct 2017 |

**Insight:** Mohan Madan is the most senior employee. All 3 sales support agents were hired within a 6-month window in 2017.

### 8.2 Geographic Revenue Distribution

| Country | Customers | Revenue |
|---|---|---|
| USA | 13 | $523.06 |
| Canada | 8 | $303.96 |
| Brazil | 5 | $190.10 |
| France | 5 | $195.10 |
| Germany | 4 | $156.48 |

**Insight:** USA and Canada together account for nearly 35% of total revenue. However European markets show strong revenue per customer ratios.

### 8.3 Top Cities by Revenue

| City | Revenue |
|---|---|
| Prague | $273.24 |
| Mountain View | $169.29 |
| London | $166.32 |
| Berlin | $163.35 |
| Paris | $160.38 |

**Insight:** Prague is the top revenue-generating city making it the ideal location for a promotional music festival event.

### 8.4 Underserved Regions

Countries with customers but below-average spending per customer include several Eastern European and Asian markets. These regions could benefit from localized promotions, regional pricing, or language-specific content curation.

---

## 9. Recommendations

### 9.1 For the Marketing Team

| Recommendation | Rationale |
|---|---|
| Focus campaigns on Rock and Metal genres | These genres drive the most revenue and units sold |
| Host a music festival in Prague | Prague has the highest city-level revenue |
| Launch re-engagement campaigns for inactive customers | Several customers haven't purchased in 6+ months |
| Create localized campaigns for Latin America | Latin music shows high demand per track in these regions |
| Target Czech Republic, India, and Portugal for premium campaigns | These markets generate the highest revenue per customer |
| Promote multi-genre bundles | Most customers already buy across genres — bundle deals could increase average invoice value |

### 9.2 For the Product Team

| Recommendation | Rationale |
|---|---|
| Audit and promote 1,500+ never-purchased tracks | 43% of the catalog has zero sales — a major waste of catalog space |
| Remove or archive artists with zero sales | Streamlining the catalog improves user experience |
| Introduce premium pricing for high-demand tracks | Currently all tracks are priced at $0.99 — premium tracks could command $1.99–$2.99 |
| Build a recommendation engine | Customers who buy Rock also tend to buy Metal — cross-genre recommendations could boost sales |
| Expand Latin music catalog | High demand per track suggests supply is not meeting demand |
| Phase out Protected AAC format | Usage is declining — focus on MPEG and standard AAC |

### 9.3 For the Operations Team

| Recommendation | Rationale |
|---|---|
| Balance customer load across sales reps | Jane manages 21 customers vs Steve's 18 — rebalancing could improve service quality |
| Set revenue targets per sales rep | Currently no rep is significantly outperforming — targets could drive growth |
| Invest in underserved geographic markets | Eastern European and Asian markets have customers but low average spend |
| Consider regional pricing strategies | Uniform $0.99 pricing may not be optimal across all markets |
| Monitor media type trends annually | MPEG dominates but AAC adoption is growing — infrastructure planning needed |

---

## 10. Conclusion

This analysis of the Apple iTunes Music Store database has revealed several important insights:

**Strengths:**
- Strong customer loyalty with 100% repeat purchase rate
- Stable and slowly growing revenue year over year
- Clear genre leaders (Rock, Metal, Latin) providing focus areas for marketing

**Weaknesses:**
- Nearly 43% of the catalog has never been purchased — a major inefficiency
- Invoice values are small ($7.67 average) — suggesting customers are not being encouraged to make larger purchases
- Only 3 sales reps managing all 59 customers — limited capacity for growth

**Opportunities:**
- High-value markets in Czech Republic, India, and Portugal
- Untapped potential in Latin American markets
- Music festival opportunity in Prague
- Bundle and subscription pricing models

**Threats:**
- Declining use of protected media formats
- Large dead stock catalog could affect platform credibility
- Flat revenue growth if no new customer acquisition strategy is implemented

Overall, iTunes has a solid foundation with loyal customers and strong genre performers. By optimizing the catalog, investing in high-value markets, and implementing smarter pricing strategies, iTunes can significantly grow its revenue and market presence.

---

*Report prepared by Kalpana Naidu | Apple iTunes Music Store Analysis Project | May 2026*
