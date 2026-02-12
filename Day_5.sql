-- ====================================================
-- Day 5: GROUP BY + HAVING + Aggregate Mastery
-- ====================================================
Use sakila;

-- ====================================================
-- Basic GROUP BY
-- ====================================================
-- 1. From payment, total payments by staff_id
Select
	staff_id,
    COUNT(*)
From payment
Group By staff_id;

-- 2. From rental, rentals per customer (customer_id); top 5 by count DESC
Select 
	customer_id,
    COUNT(rental_id) AS total_rented
From rental
Group By customer_id DESC
Limit 5;

-- 3. From film, films by rating; show rating, COUNT(*)
Select
	rating,
    Count(*) As total_movies
From film
Group By rating;

-- ============================
-- HAVING Filters
-- ============================
-- 4. From payment, staff with >1,000 payments; show staff_id, COUNT(*).
Select 
	staff_id,
    Count(*) As payment_count
From payment
Group By staff_id
Having count(*) > 1000;

-- 5. From rental, customers with >50 rentals; count them
Select
	customer_id,
    count(rental_id) AS total_rented
From rental
Group By customer_id
Having count(rental_id) > 50;

-- 6. From film, ratings with >100 films; show rating, COUNT(*)
Select
	rating,
    Count(title)
From film
Group By rating
Having Count(title) > 100;

-- =======================================
-- Multiple Aggregates
-- =======================================
-- 7. From payment, avg + total amount by staff_id; show all
Select
	staff_id,
	Avg(amount) AS Average_Amount,
    Sum(amount) AS Total_Amount
From payment
Group By staff_id;

-- 8. From customer, customers per store (store_id); show store_id, COUNT(*).
Select 
	store_id,
    Count(*) AS Total_Customers
From customer
Group By(store_id);

-- 9. From inventory, copies per film (film_id); avg copies
Select
	film_id,
    COUNT(inventory_id) AS Avg_copies
From inventory
Group By film_id;

-- ======================================
-- Aggregate Business
-- ======================================
-- 10. From payment, total revenue; then staff revenue % of total
Select Sum(amount) AS Total_Revenue From payment;

Select
	staff_id,
    Round(Sum(amount) / (Select Sum(amount) From payment) * 100, 2) as Percent_Total
From payment
Group By staff_id;

-- 11. From rental, avg rentals per customer; show single number
Select
	customer_id,
	Any_value(rental_id) AS rental_id, 			# rating is a non-aggregated column
	Count(*) as Total_Rented
From rental
Group By customer_id;
	
-- 12. From film, most common rating; show rating
Select
	rating,
	Count(*)
From film
Group By rating 
Order By rating DESC;

-- ============================================
-- HAVING Complex
-- ============================================
-- 13. From payment, staff with avg payment > $5; show staff_id, AVG(amount).
Select 
	staff_id,
    AVG(amount) AS Avg_Amount
From payment 
Group By staff_id
Having Avg_Amount > 5;

-- 14. From rental, months with >1,000 rentals (YEAR(rental_date), MONTH(rental_date))
Select
	Year(rental_date) AS Year,
    Month(rental_date) AS Month,
	Count(*) as rental_count
From rental
Group By Year(rental_date), Month(rental_date)
Having Count(*) > 1000
Order By Year, Month;

-- 15. Business: Customers spending > avg customer spend; count them
Select Count(Distinct customer_id) As high_spenders
From payment p
Where p.customer_id IN (
	Select customer_id
    From payment 
    Group By customer_id
    Having Sum(amount) > (Select Avg(total_spend) From (Select Sum(amount) total_spend From payment
							Group By customer_id) t)
						);

