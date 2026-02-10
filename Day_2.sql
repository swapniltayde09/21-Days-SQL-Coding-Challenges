-- =======================================================================
-- 21-Day SQL Challenge: Day 2 - Advanced WHERE + Date Filters + IN/NOT IN
-- =======================================================================

use sakila;
show tables;

-- ========================================
-- Complex WHERE
-- ========================================
-- 1. From payment, find payments > $5.00 AND < $8.00; show payment_id, customer_id, amount
Select
	customer_id, 
	payment_id,
	amount
From payment
Where amount BETWEEN 5 AND 8;

-- 2. From film, find unreleased films (release_year IS NULL); show title, release_year.
Select 
	film_id,
    title,
    release_year
From film
Where release_year IS NULL;

-- 3. From customer, find inactive customers (active = 0); show customer_id, first_name, last_name.
Select 
	customer_id,
    first_name,
    last_name,
    active
From customer
Where active = 0;

-- 4. From staff, find staff NOT in store 1 (store_id != 1); show all columns.
Select * 
From staff
Where store_id != 1;

-- 5. From payment, find payments from store_id 1 OR 2 (IN (1,2)); count them
Select *
From payment
Where 

-- ========================================
-- LIKE + Pattern Matching
-- ========================================
-- 6. From category, find categories starting with 'A' or 'C' (LIKE 'A%' OR LIKE 'C%'); show name.
Select name
From category
Where name LIKE 'A%' OR LIKE 'C%';

-- 7. From film, find titles containing 'ACE' (case-insensitive); show title.
Select
	film_id,
    title
From film
Where title LIKE '%ACE%';

-- 8. From actor, find actors whose first_name ends with 'O' (LIKE '%O'); show first_name, last_name.
Select 
	actor_id,
    first_name,
    last_name
From actor
Where first_name LIKE '%O';

-- ========================================
-- Date Functions (Sakila uses DATE/DATETIME)
-- ========================================
-- 9. From rental, rentals in 2006 (YEAR(rental_date) = 2006); count them.
SELECT COUNT(*) AS rentals_2006
FROM rental
WHERE YEAR(rental_date) = 2006;

-- 10. From payment, payments last 30 days from May 24, 2007 (payment_date >= DATE_SUB('2007-05-24', INTERVAL 30 DAY)); show payment_date, amount.
Select
	payment_id,
    payment_date,
    amount
From payment
Where payment_date >= DATE_SUB('2007-05-24', INTERVAL 30 DAY);

-- 11. From rental, rentals May 2005 (MONTH(rental_date) = 5 AND YEAR(rental_date) = 2005); show rental_date.
Select 
	rental_id,
    rental_date
From rental
Where MONTH(rental_date) = 5 AND YEAR(rental_date) = 2005;

-- =============================
-- IN/NOT IN + NOT EXISTS
-- =============================
-- 12. From customer, customers NOT from store 1 (store_id NOT IN (1)); count them.
SELECT COUNT(*) AS non_store1_customers
FROM customer
WHERE store_id NOT IN (1);

-- 13. From film_category, categories NOT linked to any films (NOT EXISTS (SELECT 1 FROM film_category fc2 WHERE fc2.category_id = fc.category_id)—wait, use LEFT JOIN); show category_id.
SELECT c.category_id, c.name
FROM category c
LEFT JOIN film_category fc ON c.category_id = fc.category_id
WHERE fc.category_id IS NULL;

-- 14. From payment, payments NOT made by customer #1 (customer_id NOT IN (1)); show first 5.
Select 
	payment_id, 
    customer_id, 
    amount
From payment
Where customer_id NOT IN (1)
LIMIT 5; 

-- ====================================
-- Mixed Business Logic
-- ====================================
-- 15. From payment, high-value payments (> $6 OR from staff_id = 2); show payment_id, customer_id, amount, staff_id.
Select
	payment_id,
    customer_id,
    amount,
    staff_id
From payment
Where amount > 6 OR staff_id = 2;
    

























