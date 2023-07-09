use northwind;

-- 1. Write an sql query that the CompanyName and total number of orders by customer 
-- renamed as number of orders since Decemeber 31, 1994. Show number of Orders greater than 5.
select c.company, count(o.id) as 'number of orders' from orders o
inner join customers c on o.customer_id=c.id
where o.order_date>'1994-12-31'
group by customer_id
having count(o.id)>5;

-- 2. Write an sql query that shows the OrderID ContactName, UnitPrice, Quantity, 
-- Discount from the order details, orders and customers table with discount given on every purchase
select  od.order_id, c.first_name, od.unit_price, od.quantity, od.discount from orders o 
inner join order_details od on o.id=od.order_id
left join customers c on o.customer_id=c.id
where od.discount <> '0';

-- 3. Write an sql query to find the top 10 exprensive products
select distinct id,product_name,unit_price from 
(select p.id, p.product_name, p.product_code, unit_price, 
dense_rank() over(order by unit_price desc) as top_ten 
from products p 
inner join order_details od 
on p.id=od.product_id) t
where top_ten<=10;

-- 4. List the Company Name of all U.S.-based customers who are NOT located in the same state 
-- as any of the employees. Order the results by Company Name.
select company from customers where country_region='USA' and 
state_province <> all(select state_province from employees)
order by company;

-- 5. What was the yearly sales of each category product wise.
select year(o.order_date) as year,p.product_name,
round(sum((unit_price*quantity)*(1-discount)/100)*100,2) as sales from products p
inner join  order_details od on p.id=od.product_id
left join orders o on od.order_id=o.id
group by year(o.order_date),category,p.product_name
order by sales desc;

-- 6. Which products have been ordered by the most customers?
select distinct p.id,p.product_name,count(c.id) as customer_count from customers c
inner join orders o on c.id=o.customer_id
inner join order_details od on o.id=od.order_id
right join products p on od.product_id=p.id
group by p.id,p.product_name
order by count desc
limit 2;

-- 7. Find the customers with the order amount higher than the average order amounts, 
-- along with their respective order counts and total order amounts.

with cte as(
select c.id,c.company,count(o.id) as order_count, sum(od.unit_price*od.quantity) as order_amount from orders o
inner join order_details od 
on o.id=od.order_id
inner join customers c
on o.customer_id=c.id
group by c.id),
cte1 as(
select avg(order_amount) over() as avg_amount
from cte)
select distinct cte.id,cte.company,cte.order_count,cte.order_amount,cte1.avg_amount from cte,cte1
where cte.order_amount>cte1.avg_amount
order by cte.order_amount desc;

-- 8. Write an sql query that shows CompanyName and total number of orders 
-- by customer renamed as number of orders. Show number of Orders greater than 5.
select c.id,c.company,count(o.id) as number_of_orders from customers c
inner join orders o 
on c.id=o.customer_id
group by c.id
having number_of_orders>5;

-- 9. Write an sql query to find the shipping company who shipped the most orders
select distinct s.id,s.company,count(o.id) over(partition by s.id) as order_count 
from shippers s
left join orders o 
on s.id=o.shipper_id
order by order_count desc
limit 1;

-- 10. Write an sql query to find the customers who are employees
select distinct concat_ws(" ", e.first_name,e.last_name) as 'Names' from employees e
inner join orders o 
on e.id=o.employee_id
right join customers c
on o.customer_id=c.id
where c.id=e.id;

-- 11. Write an sql query to list all suppliers who have not 
-- received any purchase orders from employees.
select s.id,s.company,s.first_name, count(po.id) as purchase_orders from employees e
inner join purchase_orders po
on e.id=po.created_by
right join suppliers s
on po.supplier_id=s.id
group by s.id
having purchase_orders=0;

-- 12. Write an sql query to identify customers who have placed orders 
-- for products that are not from their own state.
select c.id,c.first_name,c.last_name from customers c
inner join orders o on c.id=o.customer_id
where c.city<>o.ship_city;

-- 13. Write an sql query to find the customers who ordered 
-- dairy products and display their order_count
select c.id,c.first_name,c.last_name,count(od.order_id) over(partition by c.id) as order_count from customers c
inner join orders o on c.id=o.customer_id
left join order_details od on o.id=od.order_id
left join products p on od.product_id=p.id
where p.category='Dairy products';











