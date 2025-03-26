CREATE TABLE list_of_orders (
Order_ID TEXT PRIMARY KEY,
Order_date DATE,
Customer_name TEXT,
State TEXT,
City TEXT
);

CREATE TABLE order_details (
Order_ID TEXT,
Amount NUMERIC,
Profit NUMERIC,
Quantity INT,
Category TEXT,
Sub_category TEXT
);

CREATE TABLE sales_target (
Date_of_order DATE,
Category TEXT,
Target NUMERIC
);

SELECT *
FROM list_of_orders

SELECT *
FROM order_details

SELECT *
FROM sales_target

SELECT DISTINCT(order_details.sub_category)
FROM order_details
ORDER BY sub_category

CREATE TABLE orders AS
SELECT lo.*, od.amount, od.profit, od.quantity, od.category, od.sub_category
FROM list_of_orders AS lo
JOIN order_details AS od
ON lo.order_id = od.order_id

ALTER TABLE orders
RENAME COLUMN amount TO price

ALTER TABLE orders
ADD COLUMN subcat_cost NUMERIC,
ADD COLUMN subcat_revenue NUMERIC,
ADD COLUMN cost_per_unit NUMERIC

UPDATE orders
SET cost_per_unit = price - (profit/quantity)

UPDATE orders
SET cost_per_unit = ROUND(cost_per_unit,2)

UPDATE orders
SET subcat_cost = cost_per_unit * quantity

UPDATE orders
SET subcat_revenue = price*quantity

UPDATE orders
SET state = 'Telangana'
WHERE city = 'Hyderabad'
