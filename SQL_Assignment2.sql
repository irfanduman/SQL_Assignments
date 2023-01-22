-- RDB&SQL Assignment-2 (DS 13/22 EU)

/* 
1. Product Sales
You need to create a report on whether customers who purchased the product named '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' buy the product below or not.

1. 'Polk Audio - 50 W Woofer - Black' -- (other_product)
    To generate this report, you are required to use the appropriate SQL Server Built-in functions or 
    expressions as well as basic SQL knowledge.*/


WITH T1 AS(
SELECT DISTINCT c.customer_id, c.first_name, c.last_name, p.product_name
                FROM sale.customer c 
                JOIN sale.orders o ON c.customer_id = o.customer_id
                JOIN sale.order_item oi ON o.order_id = oi.order_id
                JOIN product.product p ON oi.product_id = p.product_id
                WHERE p.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
),
T2 AS(
SELECT DISTINCT c.customer_id, c.first_name, c.last_name, p.product_name
                FROM sale.customer c 
                JOIN sale.orders o ON c.customer_id = o.customer_id
                JOIN sale.order_item oi ON o.order_id = oi.order_id
                JOIN product.product p ON oi.product_id = p.product_id
                WHERE p.product_name = 'Polk Audio - 50 W Woofer - Black'
)
SELECT 
    T1.customer_id, 
    T1.first_name, 
    T1.last_name, 
    CASE WHEN T2.product_name IS NULL THEN 'No' ELSE 'Yes' END AS Other_Product
FROM T1
LEFT JOIN T2 ON T1.customer_id = T2.customer_id;
  



/* 2. Conversion Rate
    Below you see a table of the actions of customers visiting the website by clicking on two different types of advertisements 
    given by an E-Commerce company. Write a query to return the conversion rate for each Advertisement type.*/

-- a. Create above table (Actions) and insert values,
CREATE TABLE Actions (
    Visitor_ID int,
    Adv_Type varchar(255),
    Action varchar(255)
);

INSERT INTO Actions
VALUES
    (1,'A', 'Left'),
    (2,'A', 'Order'),
    (3,'B', 'Left'),
    (4,'A', 'Order'),
    (5,'A', 'Review'),
    (6,'A', 'Left'),
    (7,'B', 'Left'),
    (8,'B', 'Order'),
    (9,'B', 'Review'),
    (10,'A', 'Review');


-- b. Retrieve count of total Actions and Orders for each Advertisement Type,
SELECT Adv_Type, [Action], COUNT(Action) as count_of_action
FROM Actions
GROUP By Adv_Type, [Action]
ORDER BY Adv_Type, [Action];



-- c. Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions casting as float by multiplying by 1.0.
WITH 
T1 AS(
    SELECT Adv_Type, COUNT(Adv_Type) as total_visit
    FROM Actions
    GROUP By Adv_Type
),
T2 AS(
    SELECT Adv_Type, COUNT(Action) as count_of_action
    FROM Actions
    WHERE [Action]='Order'
    GROUP By Adv_Type, [Action]
)
Select T1.Adv_Type, CAST(1.0 * T2.count_of_action/T1.total_visit as numeric(36,2)) as Conversion_Rate
from T1
join T2 on T1.Adv_Type=T2.Adv_Type;


-- Extra: Drop the 'Actions' table created for this assignment
DROP TABLE Actions;