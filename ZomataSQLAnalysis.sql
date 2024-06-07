drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup
(
userid integer,
gold_signup_date date
); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users
(
userid integer,
signup_date date
); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),(2,'01-15-2015'),(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales
(
userid integer,
created_date date,
product_id integer
); 

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
CREATE TABLE product
(
product_id integer,
product_name text,
price integer
); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),	
(3,'p3',330);

-------------------------------------------------------------------------

SELECT * FROM goldusers_signup;
SELECT * FROM users;
SELECT * FROM sales;
SELECT * FROM product;


-----------------------Questions------------------------------------------

---1. What is total amount each customer spent on zomato ?

with sum_of_amount as
(SELECT s.userid,s.created_date,s.product_id,p.product_name,price FROM sales s
INNER JOIN product p 
on s.product_id = p.product_id)

SELECT userid,
sum(price) as total_amount
FROM sum_of_amount
group by userid;


---------------------------------------------------------------------------
---2. How many days has each customer visited zomato?

SELECT userid, count(distinct created_date) as no_of_days 
FROM sales 
group by userid
ORDER BY userid;


----------------------------------------------------------------------------
---3. What was the first product purchased by each customer?

select * from sales;


with first_rank as
(select *
,ROW_NUMBER() over(partition by userid order by userid,created_date) as rn
from sales)

select userid,created_date,product_id from first_rank where rn = 1;


------------------------------------------------------------------------------
---4. What is most purchased item on menu & how many times was it purchased by all customers ?


with count_of_purchased_item as
(select * from sales 
where product_id = (select top 1 product_id from sales 
group by product_id 
order by count(product_id) desc))

select userid, count(1) as count_of_items
from count_of_purchased_item
group by userid;




---------------------------------------------------------------------------------
---5. Which item was most popular for each customer?

with cte as(
select userid, product_id, 
count(product_id) over(partition by userid, product_id) as cnt 
from sales
),
cte1 as(
select * , 
ROW_NUMBER() over(partition by userid order by cnt desc) as rn1 
from cte
)
select * from cte1 where rn1 = 1;


---------------------------------------------------------------------------------
---6. Which item was purchased first by customer after they become a member ?


with member_join as
(select u.userid, s.product_id,u.signup_date,s.created_date 
from sales s 
inner join users u 
on s.userid = u.userid 
and s.created_date >= u.signup_date
), member_join2 as
(select *,
ROW_NUMBER() over(partition by userid order by userid,created_date) as rn
from member_join)

select userid , product_id, signup_date, created_date  
from member_join2 
where rn = 1;



---------------------------------------------------------------------------------
---7. Which item was purchased just before the customer became a member?


with member_join as
(select u.userid, s.product_id,u.signup_date,s.created_date 
from sales s 
inner join users u 
on s.userid = u.userid 
and s.created_date <= u.signup_date
), member_join2 as
(select *,
ROW_NUMBER() over(partition by userid order by userid,created_date) as rn
from member_join)

select userid , product_id, signup_date, created_date  
from member_join2 
where rn = 1;



---------------------------------------------------------------------------------






