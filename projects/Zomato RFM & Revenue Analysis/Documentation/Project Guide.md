
# 🍽️ Zomato End-to-End SQL Analytics Workflow

An end-to-end **SQL analytics case study** built on Zomato-style transactional data.  
This project demonstrates how a data analyst approaches **raw data validation, funnel analysis, revenue drivers, geographic performance, and customer segmentation** using MySQL.

---

## Problem Statement

Food delivery platforms generate high-volume transactional and behavioral data, but business decisions require:
- Clean and reliable data
- Clear visibility into user drop-offs
- Identification of high-performing channels, cities, and customers
- Actionable segmentation for retention and monetization

This project answers:
- Where do users drop in the app journey?
- Which channels and devices drive the most value?
- Which cities are mature vs growth markets?
- Who are the most valuable customers, and who is at risk of churn?

---

## Key Assumptions

- Data represents a single historical snapshot
- All monetary values are in INR (₹)
- Platform commission assumed at 30% of order value
- One `app_session_id` equals one continuous session
- Orders may be completed or cancelled with refunds at item level
- Funnel analysis is session-based, not user-based
- RFM scores are relative to this dataset

---

## 🗂️ Dataset Overview

| Table | Description |
|------|------------|
| users | User demographics and membership |
| app_sessions | Traffic source and device |
| app_pageviews | Page-level navigation |
| orders | Order-level transactions |
| order_items | Item-level details |
| order_items_cancelled | Refund data |
| restaurants | City mapping |
| menu | Food catalog |

---

## 🧩 PART 1: Database Setup & Data Cleaning

### Objective
Validate data integrity before analysis.

```sql
CREATE DATABASE zomato;
USE zomato;
```
#Checking Zomato Data #
#Users
Select count(*) AS Total_Users from orders;
Select count(DISTINCT user_id) AS Unique_Users From users;
# 15000 orders total comin from 5000 unique users as per data

# De-Duplicates
select count(*) AS Total_orders,
count(distinct order_id) AS distinct_orders,
count(*) - count(distinct order_id)
from orders;

#### --- Data Cleaning --- ###
select *
from app_sessions;

# NULL UTM Handling
update app_sessions
set utm_source = "Direct"
where utm_source IS NULL;
 
## Fixing Date Values:

## 1) Changing Orders Date
Alter table orders
modify column order_time DATETIME; 
Alter table orders
modify column delivery_time DATETIME;

#2) Changing signup_dates
Alter table users
modify column signup_date DATETIME;

# 3) Changing Created AT Order Date
alter table order_items_cancelled
modify column created_at DATETIME;
# 4) Changing App session dates
Alter table app_sessions
modify column created_at DATETIME;

## Adding flag for free deliveries
alter table orders
add column delivery_flag varchar(50);

update orders
set delivery_flag = CASE
WHEN delivery_fee_paid = 0 Then "Complimentary"
ELSE "Paid"
END;

ALTER table orders
add column order_day INT, 
add column order_month INT, 
add column order_year INT,
add column min_time_delivery INT;

ALTER table orders
add column order_hour INT;

Update orders
set order_day = day(order_time);

update orders
set order_month = month(order_time);

update orders
set order_year = year(order_time);

update orders
set order_hour = hour(order_time);

update orders
set min_time_delivery = timestampdiff(MINUTE,order_time, delivery_time);

select *
from orders;

#Check for duplicates:
SELECT COUNT(*), COUNT(order_id)
FROM orders
HAVING COUNT(order_id) > 1;
---

## 🧭 PART 2: UX Funnel Analysis

### Objective
Identify drop-offs from homepage to order completion.

```sql
CREATE TEMPORARY TABLE pageviews_per_session AS
SELECT
    app_session_id,
    MAX(CASE WHEN pageview_url = '/home-page' THEN 1 ELSE 0 END) AS homepage,
    MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart
FROM app_pageviews
GROUP BY app_session_id;
```

**Insight:** Cart stage is the primary funnel bottleneck.

---

## 📊 PART 3: Channel & Device Performance

```sql
CREATE VIEW vw_channel_performance AS
SELECT
    s.utm_source,
    s.device_type,
    COUNT(o.order_id) AS orders,
    SUM(o.total_price) AS GMV
FROM app_sessions s
LEFT JOIN orders o
ON s.app_session_id = o.app_session_id
GROUP BY s.utm_source, s.device_type;
```

---

## 🌍 PART 4: City-Wise Analysis

```sql
SELECT
    r.city,
    COUNT(o.order_id) AS orders,
    SUM(o.total_price) AS GMV
FROM orders o
JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.city;
```

---

## 👥 PART 5: RFM Segmentation

```sql
SELECT
    u.user_id,
    DATEDIFF(CURDATE(), MAX(o.order_time)) AS recency,
    COUNT(o.order_id) AS frequency,
    SUM(o.total_price) AS monetary
FROM users u
JOIN app_sessions s ON u.user_id = s.user_id
JOIN orders o ON s.app_session_id = o.app_session_id
GROUP BY u.user_id;
```

---

## 🚀 Key Takeaways

- Cart abandonment is the main UX issue
- Direct & mobile channels perform best
- City strategies vary by maturity
- RFM enables targeted retention

---

## ▶️ How to Use

1. Load CSVs into MySQL
2. Run queries sequentially
3. Export results for dashboards

---

## 📌 Author Note

This project emphasizes **business insight with SQL**, not just query writing.
