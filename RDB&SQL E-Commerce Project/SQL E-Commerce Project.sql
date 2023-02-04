-- RDB&SQL E-Commerce Project

USE ecommerce


--INTRODUCTION

-- Get rid of the the letters in front of the first four ID columns to make them numeric
UPDATE e_commerce
SET 
    Ord_ID = SUBSTRING(Ord_ID, 5, 9),
    Cust_ID = SUBSTRING(Cust_ID, 6, 9),
    Prod_ID = SUBSTRING(Prod_ID, 6, 9),
    Ship_ID = SUBSTRING(Ship_ID, 5, 9);


-- Change the data type of the first four ID columns to 'INT'
ALTER TABLE [e_commerce] ALTER COLUMN Ord_ID int NOT NULL
ALTER TABLE [e_commerce] ALTER COLUMN Cust_ID int NOT NULL
ALTER TABLE [e_commerce] ALTER COLUMN Prod_ID int NOT NULL
ALTER TABLE [e_commerce] ALTER COLUMN Ship_ID int NOT NULL


-- Check the datatype of the columns
SELECT 
--TABLE_CATALOG,
--TABLE_SCHEMA,
TABLE_NAME, 
COLUMN_NAME, 
DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
--where TABLE_NAME = 'e_commerce' 


-- Set Ord_ID and Prod_ID as composte key (Primary Keys)
ALTER TABLE e_commerce
ADD CONSTRAINT pk_myConstraint PRIMARY KEY (Ord_ID,Prod_ID)
GO




---------------------------------------------------------------------------------------------------------------------------------------------------------
--ANALYZE THE DATA BY FINDING THE ANSWERS TO THE QUESTIONS BELOW: 
---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Find the top 3 customers who have the maximum count of orders. 
SELECT TOP 3 Customer_Name, COUNT(Ord_ID) no_of_orders
FROM e_commerce
GROUP BY Customer_Name
ORDER BY no_of_orders DESC;


-- 2.	Find the customer whose order took the maximum time to get shipping.   
SELECT TOP 1 Customer_Name, DaysTakenForShipping 
FROM e_commerce
ORDER BY DaysTakenForShipping DESC;


--SELECT TOP 1 Customer_Name, DATEDIFF(DAY, Order_Date, Ship_Date) Ship_Time 
--FROM e_commerce
--ORDER BY Ship_Time DESC


-- 3. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011 
-- (a) Total number of unique customers in January 2011
SELECT COUNT(DISTINCT Cust_ID) no_of_unique_cust_in_Jan2011
FROM e_commerce
WHERE YEAR(Order_Date) = 2011 and MONTH(Order_Date) = 1;


-- (b) Customers who ordered every month over the entire year in 2011
WITH CTE AS (
    select DISTINCT Cust_ID, MONTH(Order_Date) order_month
    from e_commerce
    where 
        Cust_ID IN (
            SELECT DISTINCT Cust_ID
            FROM e_commerce
            WHERE YEAR(Order_Date) = 2011 and MONTH(Order_Date) = 1
        )
        and YEAR(Order_Date) =2011
)
SELECT Cust_ID, COUNT(Cust_ID) no_of_diff_months
FROM CTE
GROUP BY Cust_ID
    HAVING COUNT(Cust_ID) = 12;


-- 4. Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID. 

WITH T1 AS(
    select 
        Cust_ID, 
        Order_Date,
        LEAD(Order_Date, 2) OVER (PARTITION BY Cust_ID ORDER BY Order_Date) third_purchase,
        ROW_NUMBER() OVER (PARTITION BY Cust_ID ORDER BY Order_Date) row_number
    FROM e_commerce
)
SELECT 
    Cust_ID, 
    DATEDIFF(DAY, Order_Date, third_purchase) time_elapsed_between_1st_3rd
FROM T1
WHERE row_number=1 and DATEDIFF(DAY, Order_Date, third_purchase) > 0
ORDER BY Cust_ID;



-- 5. Write a query that returns customers who purchased both product 11 and product 14, as well as the ratio of these products to the total number of products purchased by the customer. 
WITH CTE AS(
    SELECT 
        Cust_ID, 
        Customer_Name, 
        Prod_ID, 
        Order_Quantity,
        SUM(CASE when Prod_ID = 11 then Order_Quantity else 0 END) OVER (PARTITION BY Cust_ID) product11,
        SUM(CASE when Prod_ID = 14 then Order_Quantity else 0 END) OVER (PARTITION BY Cust_ID) product14,
        SUM(Order_Quantity) OVER (PARTITION BY Cust_ID) total_product_purchased
    FROM e_commerce  
)
SELECT DISTINCT 
    Cust_ID, 
    Customer_Name, 
    product11, 
    product14, 
    total_product_purchased,
    CAST(1.0*(product11+product14)/total_product_purchased as numeric(36,2)) AS ratio_to_total_purchased
FROM CTE
where product11>0 and product14>0;


---------------------------------------------------------------------------------------------------------------------------------------------------------
-- CUSTOMER SEGMENTATION 
---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Categorize customers based on their frequency of visits. The following steps will guide you. If you want, you can track your own way. 
    
-- 1.	Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month) 
CREATE OR ALTER VIEW vw_visit_logs
AS
SELECT
    Cust_ID,
    YEAR(Order_Date) order_year,
    MONTH(Order_Date) order_month
FROM e_commerce;


 
-- 2.	Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning business) 
CREATE OR ALTER VIEW vw_monthly_visit
AS
SELECT
    Cust_ID,
    order_year,
    order_month,
    COUNT(order_month) monthly_visit
FROM vw_visit_logs
GROUP BY Cust_ID, order_year, order_month;


    
-- 3.	For each visit of customers, create the next month of the visit as a separate column. 
select 
    *,
    LEAD(order_year) OVER(PARTITION BY Cust_ID ORDER BY order_year, order_month) next_visit_year,
    LEAD(order_month) OVER(PARTITION BY Cust_ID ORDER BY order_year, order_month) next_visit_month
from vw_monthly_visit;


-- 4.	Calculate the monthly time gap between two consecutive visits by each customer. 
CREATE OR ALTER VIEW vw_monthly_avg_gap
AS
WITH T1 AS(
    select 
        *,
        LEAD(order_year) OVER(PARTITION BY Cust_ID ORDER BY order_year, order_month) next_visit_year,
        LEAD(order_month) OVER(PARTITION BY Cust_ID ORDER BY order_year, order_month) next_visit_month
    from vw_monthly_visit 
)
SELECT
    Cust_ID, 
    AVG(12*(next_visit_year - order_year)+(next_visit_month - order_month)) monthly_gap
From T1
GROUP BY Cust_ID;



  
-- 5.	Categorise customers using average time gaps. Choose the most fitted labeling model for you. 
            -- For example: 
            -- o Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase. 
            -- o Labeled as regular if the customer has made a purchase every month. Etc. 

SELECT 
    *,
    CASE 
        when monthly_gap < 3  then 'Regular'
        when monthly_gap < 5  then 'Occasional'
        when monthly_gap < 12  then 'Irregular'
        when monthly_gap >= 12  then 'Rare'
        else 'Churn'
    END AS customer_category
FROM vw_monthly_avg_gap;



---------------------------------------------------------------------------------------------------------------------------------------------------------
-- MONTH-WISE RETENTION RATE
---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Find month-by-month customer retention rate since the start of the business. 
-- There are many different variations in the calculation of Retention Rate. But we will try to calculate the month-wise retention rate in this project. 
-- So, we will be interested in how many of the customers in the previous month could be retained in the next month. 
-- Proceed step by step by creating “views”. You can use the view you got at the end of the Customer Segmentation section as a source. 
   

-- 1. Find the number of customers retained month-wise. (You can use time gaps) 

--(First Step): Create a view to see monthly gaps for each customer
CREATE OR ALTER VIEW vw_monthly_gaps
AS
WITH T1 AS(
    select 
        *,
        LEAD(order_year) OVER(PARTITION BY Cust_ID ORDER BY order_year, order_month) next_visit_year,
        LEAD(order_month) OVER(PARTITION BY Cust_ID ORDER BY order_year, order_month) next_visit_month,
        COUNT(Cust_ID) OVER (PARTITION BY order_year, order_month) total_monthly_customer
    from vw_monthly_visit 
)
SELECT
    Cust_ID,
    order_year,
    order_month,
    next_visit_year,
    next_visit_month,
    total_monthly_customer,
    12*(next_visit_year - order_year)+(next_visit_month - order_month) monthly_gap
From T1;



--(Second Step:) Check the next purchase month for each customer and filter where the gap is 1 (to see who was retained)
            -- Count them to see the total number of customers retained for the month
SELECT next_visit_year, next_visit_month, COUNT(Cust_ID) customer_retained
FROM vw_monthly_gaps
WHERE monthly_gap = 1
GROUP BY next_visit_year, next_visit_month
ORDER BY next_visit_year, next_visit_month;



-- 2. Calculate the month-wise retention rate. 
    -- Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month 
WITh T1 AS(
    SELECT next_visit_year, next_visit_month, COUNT(Cust_ID) customer_retained
    FROM vw_monthly_gaps
    WHERE monthly_gap = 1
    GROUP BY next_visit_year, next_visit_month
),
T2 AS(
    SELECT DISTINCT order_year,order_month,total_monthly_customer
    FROM vw_monthly_gaps
)
SELECT 
    order_year,
    order_month,
    customer_retained,
    total_monthly_customer,
    CAST(1.0 * customer_retained / total_monthly_customer as numeric(36,2)) AS Retantion_Rate
FROM T2,T1
WHERE T2.order_year=T1.next_visit_year AND T2.order_month=T1.next_visit_month;