-- =================================
-- Day 3: WHERE + LIMIT + CASE 
-- =================================

Use sakila;

-- ========================================
-- Advanced WHERE
-- ========================================
-- 1. From payment, amounts > $4 AND staff_id = 1; show payment_id, amount
Select 
	payment_id,
    customer_id,
    amount
    staff_id
From payment
Where amount > 4 AND staff_id = 1;

-- 2. From rental, May 2005 OR customer_id < 10; count matching rentals.
Select COUNT(*) AS Rentals_May2005
From rental
Where (MONTH(rental_date) = 5 AND YEAR(rental_date) = 2005) OR customer_id < 10; 

-- 3. From customer, store_id = 1 AND active = 1; show first 5.
Select
	customer_id,
    first_name,
    last_name
From customer
Where store_id = 1 AND active = 1
Limit 5;

-- ==============================
-- LIKE + Patterns
-- ==============================
-- 4. From film, titles starting with vowel (A,E,I,O,U); show title.
Select 
	film_id,
	title 
From film
Where 
	title LIKE 'A%' 
OR	title LIKE 'E%' 
OR 	title LIKE 'I%' 
OR	title LIKE 'O%' 
OR title LIKE 'U%';

-- 5. From actor, last_name containing 'SON'; show first_name, last_name.
Select 
	actor_id,
    first_name,
    last_name
From actor
Where last_name LIKE '%SON';

-- 6. From staff, email ending with 'store1.com'`; show all columns.
Select *
From staff
Where email LIKE '%store1.com';

-- =================================
-- LIMIT + OFFSET
-- =================================
-- 7. Top 5 highest payments (amount DESC); show amount.
Select 
	payment_id,
    amount
From payment
ORDER BY amount DESC
LIMIT 5;

-- 8. Payments #6-10 highest
Select
	payment_id,
    amount
From payment
LIMIT 5 OFFSET 5;

-- 9. First 3 rentals of 2006
Select
	rental_id,
    rental_date
From rental
Where YEAR(rental_date) = 2006
LIMIT 3;

-- =========================
-- CASE Intro
-- =========================
-- 10. Payments tier: < $2='Low', $2-$5='Med', >$5='High'; show tier, count each
SELECT 
  CASE 
    WHEN amount < 2 THEN 'Low'
    WHEN amount <= 5 THEN 'Med'
    ELSE 'High' 
  END AS tier,
  COUNT(*) 
FROM payment 
GROUP BY 
  CASE 
    WHEN amount < 2 THEN 'Low'
    WHEN amount <= 5 THEN 'Med'
    ELSE 'High' 
  END;



-- 11. Customers active=1='Active'; show first_name, status
SELECT 
	customer_id, 
    first_name,
    CASE active 
    WHEN 1 THEN 'Active' 
    ELSE 'Inactive' 
    END AS status
FROM customer 
LIMIT 5;

-- 12. Films rating='G'='Family'; count them
SELECT COUNT(*) AS family_films
FROM film 
WHERE rating = 'G';

-- ===========================================
-- Date + Business
-- ===========================================
-- 13. Payments Q1 2007 (Jan-Mar); count them
Select COUNT(*) AS Q1_2007_payments
From payment
Where YEAR(payment_date) = 2007 AND MONTH(payment_date) IN (1,2,3);

-- 14. Rentals same day as first rental ever; show rental_date
SELECT COUNT(*) AS first_day_rentals
FROM rental 
WHERE rental_date = (SELECT MIN(rental_date) FROM rental);

-- 15. High-value customers (total spend > $100); count them
Select COUNT(DISTINCT customer_id) AS high_value_customers
From payment
Group By customer_id
Having SUM(amount) > 100;





























