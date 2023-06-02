-- Questions 

-- Que 1. Which product has the highest price? Only return a single row.

SELECT 
    product_name, price
FROM
    products
ORDER BY price DESC
LIMIT 1; 

-- Que.2 -Which customer has made the most orders?

SELECT 
    concat(first_name, ' ', last_name) AS full_name,
    count(o.order_id) AS Number_of_orders
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY 1 
HAVING number_of_orders > 1;

-- Que 3. - What’s the total revenue per product?

SELECT 
	p.product_id,
    p.product_name,
    p.price,
    SUM(ot.quantity) AS Total_Qty,
    SUM(ot.quantity * p.price) AS Total_Revenue
FROM
    products p
        JOIN
    order_items ot ON ot.product_id = p.product_id
 GROUP BY 1
 ORDER BY Total_Revenue DESC;
 
 -- Que. 4 - Find the day with the highest revenue.
 
SELECT 
    distinct o.order_date,
    p.product_name,
    p.price,
    SUM(oi.quantity) AS Total_QTY,
    SUM(p.price * oi.quantity) AS Total_Revenue
FROM
    order_items oi
        JOIN
    products p ON p.product_id = oi.product_id
        JOIN
    orders o ON o.order_id = oi.order_id
GROUP BY 1
ORDER BY Total_Revenue DESC
LIMIT 3;

-- Que. 5 - Find the first order (by date) for each customer.

WITH ranking_order AS 
	(
		SELECT 
			c.customer_id,
            concat(first_name, ' ', last_name) AS full_name,
            o.order_date,
			dense_rank() over(partition by c.customer_id order by o.order_date ASC) AS ranking
        FROM 
			customers c 
        JOIN 
			orders o 
            ON c.customer_id = o.customer_id 
       )
       SELECT 
			*
       FROM 
			ranking_order
       WHERE ranking = 1;   
       
-- Que. 6 - Find the top 3 customers who have ordered the most distinct products.

SELECT 
    c.customer_id,
    CONCAT(first_name, ' ', last_name) AS Full_name,
    COUNT(DISTINCT oi.product_id) AS distinct_product
FROM
    customers c
        JOIN
    orders o ON o.customer_id = c.customer_id
        JOIN
    order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id , Full_name
ORDER BY distinct_product DESC
LIMIT 4;      

-- Que. 7 -Which product has been bought the least in terms of quantity?

SELECT 
    product_id, SUM(quantity) AS product_quantity
FROM
    order_items
GROUP BY product_id
ORDER BY 2
LIMIT 4;   

-- Que. 8 - What is the median order total?

WITH order_total AS 
	( 
		SELECT 
			o.order_id,
            SUM(oi.quantity * p.price) AS Total_Revenue
        FROM 
			order_items oi
        JOIN 	
			products p ON p.product_id = oi.product_id
        JOIN 
			orders o ON o.order_id = oi.order_id
        GROUP BY 
			o.order_id)
      SELECT 
		AVG(Total_Revenue) AS Median_Total_Revenue
      FROM  (
			SELECT 
				Total_Revenue,
                NTILE(2) OVER (ORDER BY Total_Revenue) AS Quartile 
             FROM 
				order_total
            ) median_query 
       WHERE 
			Quartile = 1 OR Quartile = 2;
		
                
-- Que 9.  For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

WITH total_rev AS  
		(
		SELECT 
			p.product_name,
			SUM(oi.quantity * p.price) AS Total_Revenue
		FROM
			products p
				JOIN
			order_items oi ON oi.product_id = p.product_id
		GROUP BY p.product_name
        )
 SELECT 
	product_name, Total_Revenue,
    CASE WHEN Total_Revenue > 300 THEN "Expensive"
		 WHEN Total_Revenue > 100 THEN "Affordable"
         ELSE "Cheap"
    END AS price_range     
 FROM 
	Total_rev 
 ORDER BY 
	Total_Revenue DESC;
    
    
-- Que. 10 - Find customers who have ordered the product with the highest price.

WITH ordered_product_price AS 
(
 SELECT 
	concat(first_name, ' ' , last_name) AS Full_name,
    p.product_name,
    p.price,
    SUM(oi.quantity * p.price) AS Total_Revenue,
    dense_rank() OVER( ORDER BY price DESC) AS rnk
 FROM 
	customers c 
 JOIN 	
	orders o
    ON c.customer_id = o.customer_id
 JOIN 
	order_items oi
    ON o.order_id = oi.order_id
 JOIN 
	products p 
    ON p.product_id = oi.product_id
 GROUP BY 1 
 ORDER by 3 DESC)
 
 SELECT 
	* 
 FROM 
	ordered_product_price
 WHERE rnk =1;   
    