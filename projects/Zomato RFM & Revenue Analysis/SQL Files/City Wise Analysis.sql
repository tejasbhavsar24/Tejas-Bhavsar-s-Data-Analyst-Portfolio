CREATE TEMPORARY TABLE city_performance1
SELECT r.city,
COUNT(o.order_id) AS total_orders,
COUNT(oc.order_id) AS cancelled_orders,
ROUND((COUNT(oc.order_id)*100) / COUNT(o.order_id), 2) AS cancellation_rate,
-- Revenue metrics:
ROUND(SUM(o.total_price), 2)  AS GMV,
ROUND(SUM(o.total_price) / COUNT(o.order_id),2) AS AOV,
SUM(o.delivery_fee_paid) AS total_delivery_fee,
-- Gross Revenue Zomato Gets
ROUND(SUM((0.30*o.total_price) + o.delivery_fee_paid), 2) AS zomato_gross_revenue,
-- Loss from cancellation and refunds
ROUND(SUM(COALESCE(oc.amount_of_refund, 0)),2) AS refund_loss,
-- Net Revenue earned considering cancellation or not
SUM(CASE
WHEN oc.order_id IS NULL THEN (0.30*o.total_price + o.delivery_fee_paid)
ELSE (0.30*o.total_price + o.delivery_fee_paid - oc.amount_of_refund)
END) AS zomato_net_revenue,
ROUND(SUM((0.30*o.total_price) + o.delivery_fee_paid) / COUNT(DISTINCT s.app_session_id), 2) AS ARPS,
AVG(TIMESTAMPDIFF(MINUTE, o.order_time, o.delivery_time)) AS avg_delivery_time,
AVG(o.delivery_fee_paid) AS avg_delivery_fee

FROM orders o
LEFT JOIN order_items_cancelled oc
ON o.order_id = oc.order_id
LEFT JOIN restaurants r
ON o.restaurant_id = r.restaurant_id
LEFT JOIN app_sessions s
ON o.app_session_id = s.app_session_id
GROUP BY r.city
ORDER BY zomato_net_revenue;
 
SELECT *, 
ROUND((city_performance1.zomato_net_revenue * 100 / city_performance1.GMV),2) AS margin_pct
FROM city_performance1;

#CITY WISE REVENUE METRICS

SELECT city,
  ROUND(AVG(o.total_price), 2) AS avg_order_value,
  ROUND(AVG(o.delivery_fee_paid), 2) AS avg_delivery_fee,
  ROUND(SUM(o.total_price), 2) AS total_gmv,
  COUNT(o.order_id) AS total_orders
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY city;

# CITY WISE Most ordered food items Top 4
WITH food_city_zomato AS(
SELECT
r.city,
TRIM(LOWER(m.fooditem_name)) AS foodname, sum(oi.quantity) AS total_orders,
DENSE_RANK() OVER(PARTITION BY r.city ORDER BY SUM(oi.quantity) DESC) AS most_ordered_food
FROM order_items oi
JOIN menu m
ON oi.food_item_id = m.food_item_id
JOIN restaurants r
ON r.restaurant_id = m.restaurant_id
GROUP BY r.city, TRIM(LOWER(m.fooditem_name))
)
SELECT city, foodname,  total_orders
FROM food_city_zomato
WHERE most_ordered_food <= 4
ORDER BY city, total_orders DESC;