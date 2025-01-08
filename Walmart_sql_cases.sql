-- Business cases
-- 1. Find different payment method and number of transactions, number of qty sold

select payment_method, count(*) as Num_of_payments , sum(quantity) as Num_of_qty_sold
from walmart
group by payment_method;


-- 2. Identify the highest rated category in each branch, displaying the branch and category

WITH cte AS (
    SELECT 
        branch, 
        category, 
        AVG(rating) AS rate,
		row_number() over (partition by branch order by AVG(rating)  desc) as num
    FROM walmart
    GROUP BY branch, category
    
)
SELECT branch, category 
FROM cte
where num=1;

-- 3. Identify the busiest day for each branch based on number of transactions

Select branch, weekday from
(select branch,
dayname(date) as weekday,
 count(*)  as num_of_tsn,
 dense_rank() over (partition by branch order by count(*) desc) as num
 from walmart
group by branch, weekday
) as sub
where num =1;

-- 4. Calculate the total quantity of items sold per payment method
SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q6: Calculate the total profit for each category
SELECT 
    category,
    SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;


-- Q7. Determine the most common payment method for each branch

select branch, payment_method from 
(
select branch,payment_method, count(payment_method),
DENSE_RANK() over (PARTITION BY branch ORDER BY count(payment_method) desc) as num
from walmart
group by branch,payment_method) as sub
where num =1;

-- Q8. Categorize sales into 3 group Morning, Afternoon, Evening : find out for each shift number of invoices

select branch,
case when extract(hour from time) <12 then 'Morning'
when extract(hour from time) between 12 AND 17 then 'Afternoon'
Else 'Evening'
End as 'Shift', count(*)
from walmart
group by branch, Shift
order by branch, count(*) desc

-- Q9. Identify 5 branch with highest decrese ratio in revenue compare to last year (current year 2023)

-- Revenue decrese ratio= (last year rev - current year rev )/ last year rev  * 100

with revenue_2022 as (
select branch, sum(total) as revenue
from walmart
where year(date)='2022'
group by branch),

revenue_2023 as (select branch, sum(total) as revenue
from walmart
where year(date)='2023'
group by branch)

select 
ls.branch, ls.revenue as last_year_rev, cs.revenue as current_year_rev,
round((ls.revenue-cs.revenue) / ls.revenue * 100 ,2)as ratio
from revenue_2022 ls join revenue_2023 cs on ls.branch=cs.branch
where ls.revenue > cs.revenue
order by ratio desc
limit 5;




