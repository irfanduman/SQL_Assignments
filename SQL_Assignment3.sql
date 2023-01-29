-- RDB&SQL Assignment-3 (DS 13/22 EU)

-- Discount Effects
-- Generate a report including product IDs and discount effects on whether the increase in the discount rate positively impacts the number of orders for the products.
-- In this assignment, you are expected to generate a solution using SQL with a logical approach. 
USE SampleRetail


--Logical Approach
--Step1: Group by product ID and order by the discount amount in ascending order.
--Step2: Calculate the difference in the number of orders (new number of orders - previus number of orders) after each discount
--Step3: Add the differences for each product_ID: 
        --If the total is posite then the effect is 'positive'
        --If the total is negatie then the effect is 'negative'
        --If the total is zero then there is 'no effect'
        --If the total is NULL then there has been only one discount amount, So the effect is 'Unknown'

WITH T1 AS(
    SELECT product_id, discount, SUM(quantity) total_sale
    FROM sale.order_item
    GROUP BY product_id, discount
    --ORDER BY product_id, discount
),
T2 AS(
    SELECT 
        *,
        T1.total_sale - LAG(T1.total_sale) OVER(partition by T1.product_id order by T1.discount) effect
    FROM T1
)
SELECT 
    T2.product_id,
    CASE 
        WHEN SUM(T2.effect) > 0 THEN 'Positive'
        WHEN SUM(T2.effect) < 0 THEN 'Negative'
        WHEN SUM(T2.effect) = 0 THEN 'No Effect'
        ELSE 'Unknown'
    END Discount_Effect
FROM T2
GROUP BY T2.product_id
