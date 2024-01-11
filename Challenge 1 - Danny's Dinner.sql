# Database Creation & Data Insertion
	# Creating Schema
CREATE SCHEMA IF NOT EXISTS c1_dannys_dinner;
USE c1_dannys_dinner;

	#Creating Sales Table
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
  );
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11' , '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
	#Creating Menu Table
DROP TABLE IF EXISTS menu;
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER 
  );
INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
	#Creating Members Table
DROP TABLE IF EXISTS members;
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
 
 
					# Case Study Questions
# 01. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) as Total_Spent
from sales s,menu m
where s.product_id=m.product_id
group by s.customer_id;

#02.How many days has each customer visited the restaurant?
select customer_id, COUNT(DISTINCT(order_date)) as No_of_Days_visited
from sales
group by customer_id;

#03.What was the first item from the menu purchased by each customer?
WITH first_item_cte AS
(
 SELECT customer_id, product_name,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rnk
 FROM sales s, menu m
where s.product_id = m.product_id
)
SELECT customer_id, product_name as First_Item
FROM first_item_cte
WHERE rnk = 1
GROUP BY customer_id,product_name;

#04.What is the most purchased item on the menu and how many times was it purchased by all customers?
Select m.product_name, count(s.product_id) as purchase_count
from sales s, menu m
where s.product_id=m.product_id
group by m.product_name
order by purchase_count desc
limit 1;

#05.Which item was the most popular for each customer?
WITH popular_item_cte AS
(
 SELECT s.customer_id, m.product_name, 
  COUNT(m.product_id) AS order_count,
  DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY COUNT(s.customer_id) DESC) AS rnk
FROM menu m, sales s
where m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM popular_item_cte 
WHERE rnk = 1;

#06.Which item was purchased first by the customer after they became a member?
WITH after_member_cte AS 
(
 SELECT s.customer_id,s.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rnk
     FROM sales s, members ms
  where s.customer_id = ms.customer_id
 and s.order_date >= ms.join_date
)
SELECT amc.customer_id, m.product_name 
FROM after_member_cte amc,menu m
where amc.product_id = m.product_id
and rnk = 1
order by amc.customer_id;

#07.Which item was purchased just before the customer became a member?
WITH before_member_cte AS 
(
 SELECT s.customer_id, s.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id
         ORDER BY s.order_date DESC) AS rnk
 FROM sales s,members ms
  where s.customer_id = ms.customer_id
 and s.order_date < ms.join_date
)
SELECT bmc.customer_id, m.product_name 
FROM before_member_cte bmc,menu m
 where bmc.product_id = m.product_id
and rnk = 1
order by bmc.customer_id;

#08.What is the total items and amount spent for each member before they became a member?
Select s.customer_id,count(s.product_id) as item_count, sum(m.price) as amount_spent
from sales s,menu m, members ms
where s.customer_id = ms.customer_id
and s.product_id=m.product_id
and s.order_date < ms.join_date
group by s.customer_id
order by s.customer_id;

#09.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
Select s.customer_id, 
SUM(case when m.product_name='sushi' then 20*m.price else 10*m.price End) as Loyalty_points
from sales s,menu m
where s.product_id=m.product_id
group by s.customer_id;

#10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
Select s.customer_id, 
SUM(case when m.product_name='sushi' then 20*m.price
when (Extract(Day from s.order_date) -Extract(Day from ms.join_date)) between 0 and 6 then 20*m.price
 else 10*m.price End) as Loyalty_points
from sales s,menu m, members ms
where s.product_id=m.product_id
and s.customer_id =ms.customer_id
and extract(Month from s.order_date) =1
group by s.customer_id
order by s.customer_id;


#BONUS Questions
  #Join All the Things
create view JoinAll as
select s.customer_id,s.order_date,m.product_name,m.price,
CASE
 WHEN s.order_date < ms.join_date THEN 'N'
 WHEN s.order_date >= ms.join_date THEN 'Y'
 ELSE 'N'
 END AS member
FROM sales s 
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members ms ON s.customer_id = ms.customer_id;
select * from JoinAll;
	
#Rank All Things
create view RankAll as
SELECT *,
 CASE
 WHEN member = 'N' then NULL
 ELSE
  dense_rank () OVER(PARTITION BY customer_id,member
  ORDER BY order_date) END AS ranking
FROM JoinAll;
select * from RankAll;
