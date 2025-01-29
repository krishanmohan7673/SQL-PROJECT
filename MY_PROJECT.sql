
--(1) Retrieve the total number of orders placed.

select count(order_id) as total_orders from order_details

-- (2) Calculate the total revenue generated from pizza sales.

SELECT SUM(CAST(order_details.quantity AS numeric) * pizzas.price) AS total_sum
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id

-- (3) Identify the highest-priced pizza.

SELECT pizza_types.pizza_name, pizzas.price
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1

-- (4) Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as common_pizza from pizzas 
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizzas.size
order by common_pizza desc

-- (5) List the top 5 most ordered pizza types along with their quantities.

select pizza_types.pizza_name, SUM(CAST(order_details.quantity AS numeric)) as quantity  from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
Group by pizza_types.pizza_name
order by quantity desc limit 5

-- (6) Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, SUM(CAST(order_details.quantity AS numeric)) as quantity  from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
Group by pizza_types.category
order by quantity desc

-- (7) Determine the distribution of orders by hour of the day.

select EXTRACT(hour from time) as hours, count(order_id) as order_count from orders
group by hours

-- (8) Join relevant tables to find the category-wise distribution of pizzas.

select category, count(pizza_name) from pizza_types
group by category


-- (9) Group the orders by date and calculate the average number of pizzas ordered per day.

 select round(avg(quantity),0) from
(select orders.date,  SUM(CAST(order_details.quantity AS numeric)) as quantity
from orders join order_details on order_details.order_id = orders.order_id
group by orders.date)

-- (10) Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.pizza_name,SUM(CAST(order_details.quantity AS numeric) * pizzas.price) AS revenue
from pizza_types 
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.pizza_name
order by revenue desc limit 3

-- (11) Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.pizza_name,(SUM(CAST(order_details.quantity AS numeric) * pizzas.price)/(SELECT SUM(CAST(order_details.quantity AS numeric) * pizzas.price) AS total_sum
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100 AS revenue
from pizza_types 
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.pizza_name
order by revenue

-- (12) Analyze the cumulative revenue generated over time.

select date, SUM(revenue) over(order by date) as cum_revenue from
(select orders.date, SUM(CAST(order_details.quantity AS numeric) * pizzas.price) AS revenue
from order_details JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
join orders on order_details.order_id = orders.order_id
group by orders.date)

--(13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.


select pizza_name, revenue from
(select pizza_name, category, revenue,
rank() over(partition by category order by revenue desc) as rn from
(SELECT pizza_types.pizza_name, pizza_types.category, 
SUM(CAST(order_details.quantity AS numeric) * pizzas.price) AS revenue
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.pizza_name, pizza_types.category) as a) as b
where rn <= 3;




























