#Checking Zomato Data #
#Users
Select count(*) AS Total_Users from orders;
Select count(DISTINCT user_id) AS Unique_Users From users;
# 15000 orders total comin from 5000 unique users as per data

# No Duplicates
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

Update orders
set order_day = day(order_time);

update orders
set order_month = month(order_time);

update orders
set order_year = year(order_time);


update orders
set min_time_delivery = timestampdiff(MINUTE,order_time, delivery_time);



