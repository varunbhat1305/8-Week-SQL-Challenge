 
  # Data Analysis Questions 
#01. How many customers has Foodie-Fi ever had?
select count( distinct customer_id) as customer_count
from subscriptions;

#02. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select DATE_FORMAT(s.start_date, '%Y-%m-01') AS transformed_date, count( distinct customer_id) as customer_count
from plans p, subscriptions s
where p.plan_id = s.plan_id
and p.plan_name='trial'
group by transformed_date
order by transformed_date;

#03. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select p.plan_name, count(*) as count
from plans p, subscriptions s
where p.plan_id = s.plan_id
and s.start_date > '2020-12-31'
group by p.plan_name;

#04. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select count(distinct s.customer_id) AS customer_count,
    ROUND(SUM(CASE WHEN p.plan_name = 'churn' THEN 1 ELSE 0 END) / COUNT(DISTINCT s.customer_id) * 100, 1) AS churn_percentage
from plans p, subscriptions s
where p.plan_id=s.plan_id;

#05. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?


#06. What is the number and percentage of customer plans after their initial free trial?

#07.What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

#08. How many customers have upgraded to an annual plan in 2020?

#09. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

#10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

#11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020


# Challenge Payment Question
# Creating Payments_table

