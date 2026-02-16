-- =============================================================
-- Day 4: Limit Mastery + Subquery Filters + Prep for Aggregates
-- ==============================================================
Use sakila;
-- ========================
-- Advanced Limit + OFFSET
-- ========================
-- 1. From payment, top 10 highest amounts; show payment_id, amount
Select
	payment_id,
    amount
From payment
Order By amount DESC
Limit 10;

-- 2. From payment, #11-20 highest
Select
	payment_id,
    amount
From payment
Order By amount DESC
Limit 10 Offset 10;

-- 3. From rental, first 5 rentals of each store
SET @row = 0;
Select rental_id, rental_date, staff_id
From (
  Select rental_id, rental_date, staff_id,
    (@row := @row + 1) / (Select Count(distInct staff_id) From rental) AS grp
  From rental, (Select @row := 0) r
  Where staff_id In (1,2)
  Order By staff_id, rental_date
) ranked
Where @row <= 10;  -- 5 per store

-- Store 1
Select * 
From rental 
Where staff_id = 1 
Order By rental_date 
Limit 5;

-- Store 2  
Select * 
From rental 
Where staff_id = 2 
Order By rental_date 
Limit 5;

-- 4. From film, last 5 alphabetically
Select
	film_id,
    title
From film
Order By title DESC Limit 5;

-- ====================================
-- Subquery Where (Key Pattern)
-- ====================================
-- 5. From payment, amounts > average payment; show amount
Select
	customer_id, 
    amount
From payment
Where amount > (Select AVG(amount) From payment);

-- 6. From rental, customers who rented more than average rentals (subquery Count)
Select r.*
From rental r
Where r.customer_id In (
  Select customer_id 
  From rental 
  Group By customer_id 
  Having Count(*) > (Select AVG(c) From (Select Count(*) c From rental Group By customer_id) t)
);

-- 7. From film, rental_rate > avg rental_rate; show title
Select
	film_id,
    title
From film
Where rental_rate > AVG(rental_rate);

-- 8. From customer, store_id with most customers
Select * From customer 
Where store_id = (
  Select store_id From (
    Select store_id, Count(*) AS c 
    From customer 
    Group By store_id 
    Order By c DESC Limit 1
  ) t
);

-- ===========================================
-- NULL + ISNULL Patterns
-- ===========================================
-- 9. From staff, rows Where picture Is Null; show first_name
Select 
	staff_id,
    first_name
From staff
Where picture = 0;
    
-- 10. From film, special_features IS Not NULL; Count them.
Select Count(*)
From film
Where special_features Is Null;

-- 11. From payment, replace NULL last_update with '2006-02-15' (Coalesce)
Select 
	payment_id, 
	Coalesce(last_update, '2006-02-15') AS last_update
From payment;

-- ================================
-- In/Not In Subqueries
-- ================================
-- 12. From payment, Not by top 3 customers (subquery).
Select * 
From payment p
Where p.customer_id Not In (
  Select customer_id From (
    Select customer_id, Count(*) AS c
    From payment 
    Group By customer_id 
    Order By c DESC Limit 3
  ) t
);

-- 13. From rental, customer_id In (active customers only)
Select * 
From rental
Where customer_id In (Select customer_id From customer Where active = 1);

-- 14. From Inventory, film_id Not In (G-rated films)
Select * From Inventory
Where film_id Not In (Select film_id From film Where ratIng = 'G');

-- =================================================
-- BusIness Pre-Aggregate
-- =================================================
-- 15. From payment, customer_id with > 50 payments; show customer_id, Count
Select customer_id, Count(*) AS payment_Count
From payment
Group By customer_id
Having Count(*) > 50;



    
 

	

	
