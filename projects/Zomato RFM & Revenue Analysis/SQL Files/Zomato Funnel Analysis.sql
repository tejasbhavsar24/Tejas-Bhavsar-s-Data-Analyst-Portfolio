## For doing Funnel Analysis properly firstly i want net revenue columns that only show Zomato revenue and losses properly, net of delivery fee
CREATE TEMPORARY TABLE cancelled_orders AS
SELECT
	order_id,
    SUM(amount_of_refund) AS total_refunds,
    MAX(created_at) as cancelled_at
FROM order_items_cancelled
GROUP BY order_id;

CREATE TEMPORARY TABLE net_GMV_orders AS
SELECT
    o.order_id,
    o.app_session_id,
    o.restaurant_id,
    o.order_time,
    COALESCE(o.delivery_time, c.cancelled_at) AS final_time,
    o.delivery_fee_paid,
    o.total_price,
    c.total_refunds,
    CASE 
        WHEN c.order_id IS NOT NULL THEN 'Cancelled'
        ELSE 'Completed'
    END AS order_status,
    CASE 
        WHEN c.order_id IS NOT NULL THEN -c.total_refunds
        ELSE o.total_price - o.delivery_fee_paid
    END AS net_revenue
FROM orders o
LEFT JOIN cancelled_orders c
    ON o.order_id = c.order_id;
    
CREATE TEMPORARY Table pageviews_per_session AS
SELECT 
app_session_id,
	MAX(CASE WHEN pageview_url = '/home-page' THEN 1 ELSE 0 END) AS homepage_views,
	MAX(CASE WHEN pageview_url = '/search' THEN 1 ELSE 0 END) AS search_views,
	MAX(CASE WHEN pageview_url = '/restaurants' THEN 1 ELSE 0 END) AS restaurants_views,
	MAX(CASE WHEN pageview_url = '/menu' THEN 1 ELSE 0 END) AS menu_views,
	MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_views
FROM app_pageviews
GROUP BY app_session_id;

CREATE TEMPORARY Table orders_per_sessions AS
SELECT 
	app_session_id,
    COUNT(DISTINCT CASE WHEN order_status = 'Completed' THEN order_id END) AS completed_orders,
    COUNT(DISTINCT CASE WHEN order_status = 'Cancelled' THEN order_id END) AS cancelled_orders,
    SUM(CASE WHEN order_status = 'Completed' THEN net_revenue ELSE 0 END) AS net_revenue_completed_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN net_revenue ELSE 0 END) AS net_revenue_cancelled_orders,
    SUM(net_revenue) AS net_revenue_all_orders
    FROM net_GMV_orders
    GROUP BY app_session_id;
    
    
SELECT
	SUM(s.homepage_views) AS homepage_sessions,
    SUM(s.search_views) AS search_sessions,
    ROUND(sum(s.search_views) * 100 / NULLIF(sum(s.homepage_views), 0),2) AS pct_home_to_search_sessions,
    
    SUM(s.restaurants_views) AS restaurants_sessions,
    ROUND(sum(s.restaurants_views) * 100 / NULLIF(sum(s.search_views), 0),2) AS pct_search_to_restaurants_sessions,
    
    SUM(s.menu_views) AS menu_sessions,
    ROUND(sum(s.menu_views) * 100 / NULLIF(sum(s.restaurants_views), 0),2) AS pct_restaurants_to_menu_sessions,
    
    SUM(s.cart_views) AS cart_sessions,
    ROUND(sum(s.cart_views) * 100 / NULLIF(sum(s.menu_views), 0),2) AS pct_menu_to_cart_sessions,
    
    SUM(o.completed_orders) AS placed_orders,
    ROUND(sum(o.completed_orders) * 100 / NULLIF(sum(s.cart_views), 0),2) AS pct_cart_to_order_sessions,
    ROUND(100 - (sum(o.completed_orders) * 100 / NULLIF(sum(s.cart_views), 0)), 2) AS cart_abandonment_rate,
    
    SUM(o.net_revenue_completed_orders) AS total_revenue,
	(-1 * SUM(o.net_revenue_cancelled_orders)) AS total_refunds,
    SUM(o.net_revenue_all_orders) AS net_revenue_all_orders,
    avg(o.net_revenue_all_orders) AS net_revenue_per_order

FROM  pageviews_per_session as s
LEFT JOIN orders_per_sessions as o
ON s.app_session_id = o.app_session_id;
    
#For UX Funnel and Channel Sales

##Question: Management requires an Summary of revenue, sessions, conversion and potential of each source/channel,
	# Channel and Device Wise Performance Summary
    
create view vw_channel_performance AS
SELECT s.utm_source,s.device_type,
count(o.order_id) AS total_orders,
COUNT(DISTINCT s.app_session_id) AS unique_sessions,
COUNT(DISTINCT s.user_id) AS unique_users,
SUM(o.total_price) AS GMV,
ROUND(count(o.order_id) * 100 / count(DISTINCT s.app_session_id),2) AS conversion_rate,
AVG(o.total_price) AS AOV
from app_sessions s
left join orders o
on s.app_session_id = o.app_session_id
group by s.utm_source, s.device_type
order by GMV DESC;
 
SELECT * FROM zomato.vw_channel_performance;

## Sales, Sessions, Unique Users, Conversions and AOV by Channel - UTM Source
SELECT s.utm_source,
count(o.order_id) AS total_orders,
COUNT(DISTINCT s.app_session_id) AS unique_sessions,
COUNT(DISTINCT s.user_id) AS unique_users,
SUM(o.total_price) AS GMV,
ROUND(count(o.order_id) * 100 / count(DISTINCT s.app_session_id),2) AS conversion_rate,
AVG(o.total_price) AS AOV
from app_sessions s
left join orders o
on s.app_session_id = o.app_session_id
group by s.utm_source
order by GMV DESC;

## Sales, Sessions, Unique Users, Conversions and AOV by Device Type:
CREATE TEMPORARY TABLE net_order_sessions AS
SELECT
    o.order_id,
    o.app_session_id,
    o.restaurant_id,
    o.order_time,
    COALESCE(o.delivery_time, c.cancelled_at) AS final_time,
    o.delivery_fee_paid,
    o.total_price,
    c.total_refunds,
    CASE 
        WHEN c.order_id IS NOT NULL THEN 'Cancelled'
        ELSE 'Completed'
    END AS order_status,
    CASE 
        WHEN c.order_id IS NOT NULL THEN -c.total_refunds
        ELSE o.total_price - o.delivery_fee_paid
    END AS net_revenue
FROM orders o
LEFT JOIN cancelled_orders c
    ON o.order_id = c.order_id;
    
SELECT s.device_type,
count(n.order_id) AS total_orders,
COUNT(DISTINCT s.app_session_id) AS unique_sessions,
COUNT(DISTINCT s.user_id) AS unique_users,
SUM(n.total_price) AS GMV,
ROUND(count(n.order_id) * 100 / count(DISTINCT s.app_session_id),2) AS Conversion_Rate,
ROUND(COALESCE(sum(n.net_revenue) / count(DISTINCT s.app_session_id)),2) AS Average_Revenue_Per_Session
from app_sessions s
left join net_order_sessions n
on s.app_session_id = n.app_session_id
group by s.device_type
order by GMV DESC;
