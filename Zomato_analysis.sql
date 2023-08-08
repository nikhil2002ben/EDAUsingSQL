drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- What is the total amount each customer spent on zomato ?

with t1 as
(select s.userid, s.created_date, p.product_id, p.price
 from sales s
 join product p
 on s.product_id = p.product_id
)
select userid, sum(price) as total_amount_spent
from t1
group by userid ;

-- How many days each costumer visited zomato?

select userid , count(distinct created_date) as visited
from sales
group by userid;

-- What was the first product purchased by each of the customers?

with t1 as
(select userid , min(created_date) as first_time
from sales
group by userid
)
select s.userid , s.product_id , t1.first_time
from sales s
join t1
on s.created_date = t1.first_time

-- What is the most purchased item on the menu and how many times was it purchased by the customers?

with t1 as 
(select product_id, count(*) as most_purchased
from sales
group by product_id
order by most_purchased desc
limit 1)
select s.userid , count(*) as count
from sales s
join t1
on s.product_id = t1.product_id
group by s.userid;

-- Which item was the most popular for each of the customers?

with t1 as 
(select userid, product_id, count(*) as freq
from sales
group by userid, product_id),
t2 as
(select userid, product_id, freq,
rank() over(partition by userid order by freq desc) rnk
from t1)
select * 
from t2
where rnk  = 1;

-- Which was the first product purchased by the customer after they became a member?

with t1 as
(select s.userid, s.created_date, s.product_id, g.gold_signup_date,
rank() over(partition by s.userid order by s.created_date) as rnk
from sales s
join goldusers_signup g
on s.userid = g.userid
where created_date >= gold_signup_date
)
select * 
from t1
where rnk = 1;

-- Which item was purchased just before the customer became a member ?

with t1 as
(select s.userid, s.created_date, s.product_id, g.gold_signup_date,
rank() over(partition by s.userid order by s.created_date desc) as rnk
from sales s
join goldusers_signup g
on s.userid = g.userid
where created_date < gold_signup_date
)
select * 
from t1
where rnk = 1;

-- What is the total orders and amount spent for each member before they became a member?

select s.userid, count(*) as total_orders, sum(p.price) as total_amount
from 
sales s
join goldusers_signup g
on s.userid = g.userid
join product p
on s.product_id = p.product_id
where s.created_date < g.gold_signup_date
group by s.userid;

-- If buying each product generates points for eg.5 Rs is equal to 2 zomato points and each product has different purchasing points
-- for eg. for p1 5rs  = 1 zomato points for p2 10rs = 5 zomato points and p3 5rs = 1 zomato points
-- Calculate points collected by each user 

with t1 as
(select s.userid, p.product_id, sum(p.price) as total_amount,
case
	when p.product_id = '1' then sum(p.price) / 5
	when p.product_id = '2' then sum(p.price) / 2
	when p.product_id = '3' then sum(p.price) / 5
end as points
from
sales s
join product p
on s.product_id = p.product_id
group by s.userid, p.product_id
order by s.userid, p.product_id)
select userid , sum(points) as total_points
from t1
group by userid;

-- For which product most points have been given till now.

select  p.product_id, sum(p.price) as total_amount,
case
	when p.product_id = '1' then sum(p.price) / 5
	when p.product_id = '2' then sum(p.price) / 2
	when p.product_id = '3' then sum(p.price) / 5
end as points
from
sales s
join product p
on s.product_id = p.product_id
group by p.product_id
order by points desc
limit 1;

-- In the 1st one year after a customer joins the gold program including their join date irrespective of the customer has purchased 
-- they earn 5 zomato points for every 10rs spent who earned more 1 or 3 and what was their points earning in their first year ?

select s.userid, sum(p.price)/2 as points
from sales s
join goldusers_signup g
on s.userid = g.userid
join product p
on s.product_id = p.product_id
where s.created_date < g.gold_signup_date + 365 and s.created_date >= g.gold_signup_date
group by s.userid
order by points desc


-- Rank all the transactions of customers

select *, rank() over(partition by userid order by created_date) as rnk
from
sales;




