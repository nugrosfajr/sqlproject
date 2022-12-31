
/*
CREATE DATABASE the_look_ecommerce ;

SELECT * FROM order_items ;
SELECT * FROM orders ;
SELECT * FROM products ;
SELECT * FROM users ;
*/

/*
Assignment Lesson 2
Question 1:
Selecting 5 products with the highest sales revenue to advertise

-- products table: (id, name)
-- order_items table: (id, sale_price, product_id)
*/

-- Answer 1:
SELECT
  b.name,
  SUM(sale_price) AS omset_penjualan
FROM
  order_items a
INNER JOIN
  products b
ON
  a.product_id = b.id
WHERE
  Status = 'Complete'
GROUP BY
  b.name
ORDER BY
  omset_penjualan DESC
LIMIT
  5;

-- OR
SELECT
  a.name,
  SUM(sale_price) AS omset_penjualan
FROM
  products a
INNER JOIN
  order_items b
ON
  a.id = b.product_id
WHERE
  Status = 'Complete'
GROUP BY
  a.name
ORDER BY
  omset_penjualan DESC
LIMIT
  5;

-- OR
SELECT
  b.name,
  SUM(sale_price) AS omset_penjualan
FROM
  order_items a,
  products b
WHERE
  a.product_id = b.id
  AND Status = 'Complete'
GROUP BY
  b.name
ORDER BY
  omset_penjualan DESC
LIMIT
  5;

/* 
Question 2:
Selecting the appropriate country to target advertising based on the sales of the top 5 products from question 1

order_items table: (user_id)
users table: (id, country)
*/

-- Answer 2:
SELECT
  u.country,
  SUM(oi.sale_price) AS omset_penjualan
FROM
  users u
INNER JOIN
  order_items oi
ON
  u.id = oi.user_id
INNER JOIN
  products p
ON
  oi.product_id = p.id
WHERE
  name IN (
  SELECT
    nm.name
  FROM (
    SELECT
      p.name,
      SUM(oi.sale_price) AS omset_penjualan
    FROM
      order_items oi
    INNER JOIN
      products p
    ON
      oi.product_id = p.id
    WHERE
      Status = 'Complete'
    GROUP BY
      p.name
    ORDER BY
      omset_penjualan DESC
    LIMIT
      5 ) AS nm )
  AND oi.status = 'Complete'
GROUP BY
  u.country
ORDER BY
  SUM(oi.sale_price) DESC
LIMIT
  5 ;


/* 
Assignment Lesson 3
Product name writing rules:
1. Cannot exceed 30 letters
2. The first letter cannot be a number
*/

-- Answer --
SELECT
  DISTINCT name,
  CASE
    WHEN CHAR_LENGTH(REPLACE(name, ' ','')) > 30
		THEN 'Nama produk tidak sesuai aturan'
    WHEN name ~~* ANY(ARRAY
	['0%',
    '1%',
    '2%',
    '3%',
    '4%',
    '5%',
    '6%',
    '7%',
    '8%',
    '9%'])
		THEN 'Nama produk tidak sesuai aturan'
  ELSE
  'OK'
END
  status
FROM
  products ;
/*
ORDER BY
  2 ;
*/

/*
Assignment Lesson 4
Shipping of the last shopping data of consumers who shopped no more than 90 days ago

Users Table: id, first_name, email,
Products Table: id, category
Order_Items Table: user_id, product_id, created_at
*/

SELECT
  oi.user_id as ID_user,
  CONCAT(u.first_name, ' ', u.last_name) AS Name,
  u.email,
  p.category,
  o.created_at AS last_order_date,
  EXTRACT( day FROM (CURRENT_DATE - o.created_at)) AS days_last_order
FROM
  order_items oi
INNER JOIN
  users u
ON oi.user_id = u.id
INNER JOIN
  products p
ON oi.product_id = p.id
INNER JOIN
  orders o
ON oi.id = o.order_id
WHERE
  EXTRACT( day FROM (CURRENT_DATE - o.created_at)) <= 90 ;


/*
Assignment Lesson 5
1. Making recommendations for key results to be used for the next quarter based on:
a. Sales/revenue generated each month exceeding USD 200,000
b. Average time from order creation to item shipment not exceeding 12 hours. Average shipping time is reviewed each month

2. Assessing team performance over the past 3 months and providing feedback to the relevant division
*/

-- 1. Key Result Answer A.

SELECT
  to_char(created_at,
    'YYYY-MM') AS months_transaction,
  SUM(sale_price) AS total_transactions_per_month
FROM
  order_items
WHERE
  status = 'Complete'
GROUP BY
  months_transaction
ORDER BY
  1 ;

-- To see the performance of the last 3 months
SELECT
  to_char(created_at,
    'YYYY-MM') AS months_transaction,
  SUM(sale_price) AS total_transactions_per_month
FROM
  order_items
WHERE
  status = 'Complete'
GROUP BY
  months_transaction
ORDER BY
  1 DESC
LIMIT 3;

/*
Conclusion:
In the last 3 months, only August 2022 met the key result of sales of $278716. This needs to be noted, especially in September 2022, which saw a significant decrease in sales of $129557. Therefore, it can be said that the target has not yet been met. The marketing team needs to reevaluate in order to improve performance through promotion, cross selling, or other marketing strategies.*/

-- Jawaban Key Result B

SELECT
  to_char(created_at,
    'YYYY-MM') AS months_transaction,
  AVG(EXTRACT(epoch
    FROM (shipped_at - created_at))/3600) AS avg_hours_process_time
FROM
  order_items
GROUP BY
  months_transaction
ORDER BY
  1 ;

--To see the performance of the last 3 months
SELECT
  to_char(created_at,
    'YYYY-MM') AS months_transaction,
  AVG(EXTRACT(epoch
    FROM (shipped_at - created_at))/3600) AS avg_hours_process_time
FROM
  order_items
GROUP BY
  months_transaction
ORDER BY
  1 DESC
LIMIT 3;

/*
Conclusion:
In the last 3 months, only September 2022 met the key result with an average shipping process of 8.3 hours compared to the previous 2 months, which reached an average of 13 hours. It can be said that the Operations team has not yet reached the target and needs to reevaluate by checking facilities, time and location, accommodation, and so on.*/


/*
Final Assignment:
"What is the sales development in Asian countries (Japan, South Korea, and China)?"
"Which country has the most stable development?"
"Which country do you think is the most potential?"
*/

SELECT
  u.country,
  to_char(oi.created_at,
    'yyyy-mm') AS periode,
  SUM(oi.sale_price) AS total_omset,
/* 
	LAG(SUM(oi.sale_price)) OVER (PARTITION BY u.country ORDER BY to_char(oi.created_at, 'yyyy-mm')) AS total_from_prev_month,
*/
  (SUM(oi.sale_price) - (LAG(SUM(oi.sale_price)) OVER (PARTITION BY u.country ORDER BY to_char(oi.created_at, 'yyyy-mm')))) AS profit_from_prev_month,
  ((SUM(oi.sale_price) - (LAG(SUM(oi.sale_price)) OVER (PARTITION BY u.country ORDER BY to_char(oi.created_at, 'yyyy-mm')))) / SUM(oi.sale_price) *100) AS percent_increment
FROM
  order_items oi
INNER JOIN
  users u
ON
  oi.user_id = u.id
WHERE
  u.country IN ('China',
    'Japan',
    'South Korea')
  AND to_char(oi.created_at,
    'yyyy-mm') BETWEEN '2021-09'
  AND '2022-10'
GROUP BY
  u.country,
  periode;
  

-- to see what most category product sales in China
SELECT
  p.category,
  COUNT(p.category) AS total_sales,
  u.country
FROM
  products p
INNER JOIN
  order_items oi
ON
  p.id = oi.product_id
INNER JOIN
  users u
ON
  oi.user_id = u.id
WHERE
  u.country = 'China'
  AND oi.status = 'Complete'
GROUP BY
  p.category,
  u.country
ORDER BY
  total_sales DESC ;