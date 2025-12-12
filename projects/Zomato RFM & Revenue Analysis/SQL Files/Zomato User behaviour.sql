WITH member_items_ordered AS
(SELECT order_id,
SUM(sales_quantity) AS total_items_ordered
FROM netorders
GROUP BY order_id)

SELECT 
CASE 
	WHEN u.gold_member = 'Yes' THEN 'GOLD MEMBER'
	ELSE 'NON GOLD MEMBER'
END AS Membership_status,
COUNT(DISTINCT CASE WHEN n.order_status = 'COMPLETED' THEN n.order_id ELSE NULL END) AS no_of_completed_orders,
ROUND(SUM(CASE WHEN n.order_status = 'COMPLETED' THEN m.total_items_ordered ELSE NULL END) / COUNT(DISTINCT CASE WHEN n.order_status = 'COMPLETED' THEN n.order_id ELSE NULL END),2) AS no_of_items_per_order,
ROUND(SUM(DISTINCT CASE WHEN n.order_status in ('CANCELLED','Food Rescue Availed') THEN n.order_id ELSE NULL END) * 100 /
	COUNT(DISTINCT n.order_id),2) AS cancellation_rate,
ROUND(SUM(DISTINCT CASE WHEN n.order_status in ('CANCELLED','Food Rescue Availed') THEN m.total_items_ordered ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN n.order_status = 'COMPLETED' THEN n.order_id ELSE NULL END),2) AS orderitems_per_cancelled_order
FROM member_items_ordered m
LEFT JOIN netorders n
ON m.order_id = n.order_id
LEFT JOIN app_sessions a
ON a.app_session_id = n.app_session_id
LEFT JOIN users u
ON u.user_id = a.user_id
GROUP BY Membership_status;