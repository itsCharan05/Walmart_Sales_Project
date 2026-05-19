select * from walmart;

-- 
select count(*) from walmart;

select payment_method, count(*)
from walmart
group by payment_method;

select 
	count(distinct Branch)
    branch
from walmart;

select min(quantity) from walmart;

-- Buisness Problems

/* Q1. Find different payment method and number of 
transaction, number of qty sold */

SELECT 
	payment_method,
    COUNT(*) as no_payments,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

/* Q2. Identify the highest-rated category in each branch
, displaying the branch, category, AVG_RATING */

WITH RankedCategories AS (
	SELECT 
		branch,
        category,
        AVG(rating) as avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rnk
	FROM walmart
    GROUP BY branch, category
)
SELECT 
	branch,
    category,
    avg_rating
FROM RankedCategories
WHERE rnk = 1;

/* Q3. Identify the busiest day for each branch based on
the number of transactions */
SELECT * FROM walmart;

WITH BusyDays AS (
	SELECT 
		branch,
		DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
		COUNT(*) AS total_transactions,
		RANK() OVER (
			PARTITION BY branch
			ORDER BY COUNT(*) DESC
		) AS rnk
	FROM walmart
	GROUP BY branch, day_name
)

SELECT 
	branch,
    day_name,
    total_transactions
FROM BusyDays
WHERE rnk = 1;

/* Q4. Calculate the total quantity of items sold per payment
method. List payment_method and total_quantity.*/

SELECT 
	payment_method,
    -- COUNT(*) as no_payments,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

/* Q5. Determine the average, minimum, and maximum rating
of category for each city. List the city, average_rating,
min_rating, and max_rating.*/

SELECT 
	city,
    category,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating,
    AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2;

/* Calculate the total profit for each category by 
considering total_profit as 
(unit_price * quantity * profit_margin)*/

SELECT * FROM walmart;

SELECT 
	category,
    SUM(total) as total_revenue,
    SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1; 

-- Q7. 
-- Determine the most common payment method for each Branch.
-- Display Branch and the preferred_payment_method.

WITH cte as 
(
	SELECT 
		branch,
		payment_method,
		COUNT(*) AS total_trans,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rnk
	FROM walmart
	GROUP BY 1,2
)
SELECT * from cte
where rnk = 1;

-- Q8.
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices.

SELECT 
	CASE 
		WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END AS shift,
    
    COUNT(*) AS total_invoices
FROM walmart
GROUP BY shift
ORDER BY total_invoices DESC;

-- Q9.
-- Identify 5 branch with the highest decrease ratio in
-- revenue compare to last year(current year 2023 and last year 2022)

-- rdr == (last_rev-cr_rev/ls_rev) * 100

-- 2022 sales
WITH revenue_2022 AS
(
	SELECT 
		branch,
		SUM(total) as last_revenue
	FROM walmart
	WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
	GROUP BY branch
),

revenue_2023 AS 
(
	SELECT 
		branch,
        SUM(total) AS current_revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)

SELECT 
	r22.branch,
    r22.last_revenue,
    r23.current_revenue,
    
    ROUND(
		((r22.last_revenue - r23.current_revenue)
        / r22.last_revenue) * 100,
        2
    ) as decrease_ratio
FROM revenue_2022 r22
JOIN revenue_2023 r23
ON r22.branch = r23.branch

WHERE r23.current_revenue < r22.last_revenue
ORDER BY decrease_ratio DESC
LIMIT 5;
