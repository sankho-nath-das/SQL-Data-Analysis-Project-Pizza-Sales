-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS TOTAL_ORDER
FROM
    orders;
    

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price)) AS TOTAL_SALES
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
    
-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price AS HIGHEST_PRICED
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS MOST_COMMON_SIZE
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY MOST_COMMON_SIZE DESC;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS QUANTITY_ORDER
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY QUANTITY_ORDER DESC
LIMIT 5;





-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS QUANTITY_ORDER
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY QUANTITY_ORDER DESC;


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.time) AS HOUR,
    COUNT(orders.order_id) AS ORDER_COUNT
FROM
    orders
GROUP BY HOUR(orders.time);


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category AS CATEGORY, COUNT(name) AS PIZZA
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(QUANTITY)) AS AVERAGE_ORDER_PER_DAY
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS QUANTITY
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS daily_orders;
    
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS REVENUE
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY REVENUE DESC
LIMIT 3;





-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category as CATEGORY,
    ROUND(
        SUM(order_details.quantity * pizzas.price) 
        / 
        (SELECT SUM(order_details.quantity * pizzas.price)
         FROM order_details
         JOIN pizzas 
             ON order_details.pizza_id = pizzas.pizza_id
        ) 
        * 100,
    2) AS CONTRIBUTION
FROM pizza_types
JOIN pizzas 
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY CONTRIBUTION DESC;


-- Analyze the cumulative revenue generated over time.

SELECT 
    SALES.date,
    SUM(SALES.REVENUE) OVER (ORDER BY SALES.date) AS CUMULATIVE_REVENUE
FROM (
    SELECT 
        orders.date,
        SUM(order_details.quantity * pizzas.price) AS REVENUE
    FROM order_details
    JOIN pizzas 
        ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders 
        ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS SALES;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    CATEGORY,
    NAME,
    REVENUE
FROM (
    SELECT 
        CATEGORY,
        NAME,
        REVENUE,
        RANK() OVER (
            PARTITION BY CATEGORY 
            ORDER BY REVENUE DESC
        ) AS RN
    FROM (
        SELECT 
            pizza_types.category AS CATEGORY,
            pizza_types.name AS NAME,
            SUM(order_details.quantity * pizzas.price) AS REVENUE
        FROM pizza_types
        JOIN pizzas 
            ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details 
            ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY 
            pizza_types.category, 
            pizza_types.name
    ) AS A
) AS B
WHERE RN <= 3;



















