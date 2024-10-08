
 #Cleaning Data
	#Customer Orders Table
drop table if exists cust_ord_cl;
Create table cust_ord_cl
SELECT order_id, customer_id, pizza_id, 
CASE
	WHEN exclusions like '' or exclusions LIKE '%null%' THEN null 
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras like '' or extras LIKE '%null%' THEN null
	ELSE extras
	END AS extras,
	order_time
FROM customer_orders;

	#Runner Orders Table
drop table if exists run_ord_cl;
create table run_ord_cl 
SELECT order_id, runner_id,  
CASE
	WHEN pickup_time LIKE '%null%' THEN null
	ELSE pickup_time
	END AS pickup_time,
CASE
	WHEN distance LIKE '%null%' THEN null
	WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	ELSE distance
	END AS distance,
CASE
	WHEN duration LIKE '%null%' THEN null
	WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	ELSE duration
	END AS duration,
CASE
	WHEN cancellation like '' or cancellation LIKE '%null%' or cancellation LIKE '%NaN%'THEN null
	ELSE cancellation
	END AS cancellation
FROM runner_orders;

ALTER TABLE run_ord_cl
modify pickup_time DATETIME,
modify COLUMN distance FLOAT,
modify COLUMN duration INTEGER;
  
 
 #Case Study Questions
		#A.Pizza Metrics

#01.How many pizzas were ordered?
select count(order_id) as order_count
from cust_ord_cl;

#02.How many unique customer orders were made?
select count(distinct(order_id)) as unique_order_count
from cust_ord_cl;

#03.How many successful orders were delivered by each runner?
select runner_id,count(order_id) as order_count
from run_ord_cl
where cancellation is null
group by runner_id
order by runner_id;

#04.How many of each type of pizza was delivered?
select co.pizza_id,count(co.order_id) as pizza_count
from cust_ord_cl co, run_ord_cl ro
where co.order_id = ro.order_id 
and ro.cancellation is null
group by co.pizza_id;

#05.How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers_count,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian_count
FROM cust_ord_cl
GROUP BY customer_id
ORDER BY customer_id;

#06.What was the maximum number of pizzas delivered in a single order?
select co.order_id,count(co.pizza_id) as pizza_count
from cust_ord_cl co,run_ord_cl ro
where co.order_id = ro.order_id
and ro.cancellation is null
group by order_id
order by pizza_count desc
limit 1;

#07.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select co.customer_id,
 SUM(CASE WHEN co.exclusions is not null or co.extras is not null THEN 1 ELSE 0 END) AS Changes_count,
 SUM(CASE WHEN co.exclusions is null and co.extras is null THEN 1 ELSE 0 END) AS No_Changes_count
from cust_ord_cl co,run_ord_cl ro
where co.order_id = ro.order_id
group by co.customer_id;

#08.How many pizzas were delivered that had both exclusions and extras?
select
SUM(CASE WHEN co.exclusions is not null and co.extras is not null THEN 1 ELSE 0 END) AS pizza_count
from cust_ord_cl co,run_ord_cl ro
where co.order_id = ro.order_id 
and ro.cancellation is null;

#09.What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS hr, COUNT(order_id) AS order_count
FROM cust_ord_cl
GROUP BY 1
order by 1;

#10.What was the volume of orders for each day of the week?
SELECT		
    CASE 
	WHEN WEEKDAY(order_time) = 0 THEN 'Monday'
	WHEN WEEKDAY(order_time) = 1 THEN 'Tuesday'
	WHEN WEEKDAY(order_time) = 2 THEN 'Wednesday'
	WHEN WEEKDAY(order_time) = 3 THEN 'Thursday'
	WHEN WEEKDAY(order_time) = 4 THEN 'Friday'
	WHEN WEEKDAY(order_time) = 5 THEN 'Saturday'
	WHEN WEEKDAY(order_time) = 6 THEN 'Sunday'
   END AS Day_Week,
   COUNT(order_id) AS order_count
FROM cust_ord_cl
group by Day_Week
order by WEEKDAY(order_time);

		#B. Runner and Customer Experience
#01.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select week(registration_date,"2021-01-01")+1 as wk,count(runner_id) as runner_count
from runners
group by wk;

#02.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select ro.runner_id,avg(minute(timediff(co.order_time,ro.pickup_time))) as avg_time
from cust_ord_cl co,run_ord_cl ro
where co.order_id = ro.order_id
and ro.pickup_time is not null
group by ro.runner_id;

#03.Is there any relationship between the number of pizzas and how long the order takes to prepare?
with rlt_cte as
(
select co.order_id,count(co.pizza_id) as pizza_count,
avg(minute(timediff(co.order_time,ro.pickup_time))) as tm
from cust_ord_cl co,run_ord_cl ro
where co.order_id = ro.order_id
and ro.pickup_time is not null
group by co.order_id
)
select pizza_count,round(avg(tm)) as avg_time
from rlt_cte
group by pizza_count;

#04.What was the average distance travelled for each customer?
select co.customer_id,Round(avg(ro.distance),2) as avg_distance
from cust_ord_cl co,run_ord_cl ro
where co.order_id = ro.order_id
and ro.distance is not null
group by co.customer_id;

#05.What was the difference between the longest and shortest delivery times for all orders?
select max(duration) - min(duration) as deliver_time_diff
from run_ord_cl;

#06.What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id,order_id,round((60*distance/duration),2) as speed
from run_ord_cl
where distance is not null
group by runner_id,order_id
order by runner_id,order_id;

#07.What is the successful delivery percentage for each runner?
select runner_id,Round(100*(count(distance)/count(*)),2) as Success_rate
from run_ord_cl
group by runner_id;

	#C. Ingredient Optimisation
# Pizza Recipe Table Cleaning
DROP TABLE IF EXISTS piz_rec_cl;
CREATE TABLE piz_rec_cl (
	pizza_id int,
	toppings int
);
INSERT INTO piz_rec_cl
(pizza_id, toppings)
VALUES
('1', '1'),
('1', '2'),
('1', '3'),
('1', '4'),
('1', '5'),
('1', '6'),
('1', '8'),
('1', '10'),
('2', '4'),
('2', '6'),
('2', '7'),
('2', '9'),
('2', '11'),
('2', '12');


SELECT pizza_name, group_concat(topping_name) AS toppings
FROM pizza_names n
INNER JOIN piz_rec_cl r
ON r.pizza_id = n.pizza_id
INNER JOIN pizza_toppings t
ON r.toppings = t.topping_id
GROUP BY pizza_name;
