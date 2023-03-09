# Creating Schema
CREATE SCHEMA IF NOT EXISTS dannys_dinner;

#Creating Sales Table
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
#01. What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price) as Total_Spent
from sales s,menu m
where s.product_id=m.product_id
group by s.customer_id;

#02.How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date)) as No_of_Visits
from sales
group by customer_id;

#03.What was the first item from the menu purchased by each customer?
Select s.customer_id, m.product_name ,s.order_date
from sales s,menu m
where s.product_id=m.product_id
group by s.customer_id
having s.order_date=min(s.order_date); 


#04.What is the most purchased item on the menu and how many times was it purchased by all customers?
Select m.product_name, count(s.product_id) as count
from sales s, menu m
where s.product_id=m.product_id
group by m.product_name
order by count desc
limit 1;

05.Which item was the most popular for each customer?
Select s.customer_id,count(s.product_id)
from sales s,menu m
group by s.customer_id,s.product_id

06.Which item was purchased first by the customer after they became a member?
Select s.customer_id,m.product_name
from sales s,menu m, members ms
where s.customer_id = ms.customer_id
and s.product_id=m.product_id
and ms.join_date <= s.order_date
group by s.customer_id;

07.Which item was purchased just before the customer became a member?
Select s.customer_id,m.product_name
from sales s,menu m, members ms
where s.customer_id = ms.customer_id
and s.product_id=m.product_id
and ms.join_date > s.order_date;

#08.What is the total items and amount spent for each member before they became a member?
Select s.customer_id,count(s.product_id) as count, sum(m.price) as spent
from sales s,menu m, members ms
where s.customer_id = ms.customer_id
and s.product_id=m.product_id
and s.order_date < ms.join_date
group by s.customer_id;

#09.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
Select s.customer_id, 
SUM(case when m.product_name='sushi' then 20*m.price else 10*m.price End) as Loyalty
from sales s,menu m
where s.product_id=m.product_id
group by s.customer_id;

#10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
Select s.customer_id, 
SUM(case when (Extract(Day from s.order_date) -Extract(Day from ms.join_date))<=7  then 20*m.price
 when (Extract(Day from s.order_date) -Extract(Day from ms.join_date))>7 and m.product_name='sushi' then 20*m.price
 else 10*m.price End) as Loyalty
from sales s,menu m, members ms
where s.product_id=m.product_id
and s.customer_id =ms.customer_id
and ms.join_date <= s.order_date
and extract(Month from s.order_date) =1
group by s.customer_id;


#BONUS Questions
  #Creating a Table for Bonus Challenges
  CREATE TABLE orders (
   customer_id VARCHAR(10),
   order_date DATE,
   product_name VARCHAR(50),
   price INT,
   member VARCHAR(1)
);

INSERT INTO orders (customer_id, order_date, product_name, price, member) 
VALUES 
('A', '2021-01-01', 'curry', 15, 'N'),
('A', '2021-01-01', 'sushi', 10, 'N'),
('A', '2021-01-07', 'curry', 15, 'Y'),
('A', '2021-01-10', 'ramen', 12, 'Y'),
('A', '2021-01-11', 'ramen', 12, 'Y'),
('A', '2021-01-11', 'ramen', 12, 'Y'),
('B', '2021-01-01', 'curry', 15, 'N'),
('B', '2021-01-02', 'curry', 15, 'N'),
('B', '2021-01-04', 'sushi', 10, 'N'),
('B', '2021-01-11', 'sushi', 10, 'Y'),
('B', '2021-01-16', 'ramen', 12, 'Y'),
('B', '2021-02-01', 'ramen', 12, 'Y'),
('C', '2021-01-01', 'ramen', 12, 'N'),
('C', '2021-01-01', 'ramen', 12, 'N'),
('C', '2021-01-07', 'ramen', 12, 'N');
