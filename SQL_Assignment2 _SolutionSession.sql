



---Assignment-2 Solution ----- Lab-4

--1. Product Sales


'2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'

SELECT DISTINCT A.*,
		CASE WHEN B.first_name IS NOT NULL THEN 'Yes' ELSE 'No' END IsOrder_SecondProduct
FROM
	(
	SELECT	 D.customer_id, D.first_name, D.last_name
	FROM	product.product A
			INNER JOIN
			sale.order_item B ON A.product_id = B.product_id
			INNER JOIN
			sale.orders C ON B.order_id = C.order_id
			INNER JOIN 
			sale.customer D ON C.customer_id = D.customer_id
	WHERE	
			A.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
	) A
	LEFT JOIN
	(
	SELECT	 D.customer_id, D.first_name, D.last_name
	FROM	product.product A
			INNER JOIN
			sale.order_item B ON A.product_id = B.product_id
			INNER JOIN
			sale.orders C ON B.order_id = C.order_id
			INNER JOIN 
			sale.customer D ON C.customer_id = D.customer_id
	WHERE	
			A.product_name = 'Polk Audio - 50 W Woofer - Black' 
	) B
	ON A.customer_id = B.customer_id
ORDER BY
	4 DESC




----------//////////////////////---------------


--2. Conversion Rate



CREATE TABLE ECommerce (
Visitor_ID INT IDENTITY (1, 1) PRIMARY KEY,	
Adv_Type VARCHAR (255) NOT NULL,	
Action1 VARCHAR (255) NOT NULL);

INSERT INTO ECommerce (Adv_Type, Action1)
VALUES 
('A', 'Left'),
('A', 'Order'),
('B', 'Left'),
('A', 'Order'),
('A', 'Review'),
('A', 'Left'),
('B', 'Left'),
('B', 'Order'),
('B', 'Review'),
('A', 'Review');





SELECT *
FROM ECommerce




WITH T1 AS (
			SELECT	Adv_Type, COUNT(*) Total_action, 
					COUNT (CASE WHEN Action1 = 'Order' THEN 1 END) Order_action
			FROM	ecommerce
			GROUP BY	
					Adv_Type
)
SELECT	Adv_Type, CAST(1.0*Order_action/Total_action AS DECIMAL(3,2)) AS Conversion_Rate
FROM	T1


-------------


















