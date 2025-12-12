CREATE view customer_rfm_analysis AS
SELECT 
u.user_id,
u.city,
u.age,
u.gender,
u.gold_member,
datediff(CURDATE(), MAX(STR_TO_DATE(o.order_time, '%Y-%m-%d %H:%i:%s'))) as recency,
COUNT(o.order_id) as frequency,
SUM(o.total_price) AS monetary,
AVG(o.total_price) as avg_order_value
FROM users u
JOIN app_sessions a
ON u.user_id = a.user_id
JOIN orders o
ON o.app_session_id = a.app_session_id
GROUP BY u.user_id, u.city, u.age,u.gender,u.gold_member;


# --- RFM Scoring Scale:
CREATE VIEW rfm_analysis_score AS
SELECT *,
CASE
	WHEN recency BETWEEN 155 AND 228 THEN 5
    WHEN recency BETWEEN 229 AND 302 THEN 4
    WHEN recency BETWEEN 303 AND 376 THEN 3
    WHEN recency BETWEEN 377 AND 450 THEN 2
    ELSE 1
END AS recency_score,
CASE
	WHEN frequency <= 10 THEN 5
    WHEN frequency <= 7 THEN 4
    WHEN frequency <= 5 THEN 3
    WHEN frequency <= 3 THEN 2
    ELSE 1
END AS frequency_score,
CASE
	WHEN monetary BETWEEN 104 AND 1590 THEN 1
    WHEN monetary BETWEEN 1591 AND 3076 THEN 2
	WHEN monetary BETWEEN 3077 AND 4562 THEN 3
    WHEN monetary BETWEEN 4563 AND 6048 THEN 4
    ELSE 5
END AS monetary_score
FROM customer_rfm_analysis;

select *
from rfm_analysis_score;