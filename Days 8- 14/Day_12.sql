-- ==============================================================
-- Day 12: Data Cleaning (NULLs, duplicates, data quality)
-- ==============================================================

Use sakila;

-- ===============================================
-- NULL Handling 
-- ===============================================
-- 1. Count payments with missing staff
Select Count(*)
From payment
Where staff_id is null;

-- 2. Replace missing film ratings with 'Unknown'.
Select
	film_id,
    title,
    Coalesce(rating, 'Unknown') as updated_rating
From film;

-- 3. Count of customers without any rentals (rental_id IS NULL).
Select
	c.customer_id,
    c.first_name,
    Count(*) as rental_count
From customer c
Left Join rental r on c.customer_id = r.customer_id
Group By c.customer_id, c.first_name
Having Count(r.rental_id) = 0;

-- 4. Films without inventory (LEFT JOIN inventory WHERE inventory_id IS NULL).
Select
	f.film_id,
	Count(i.inventory_id) as zero_inventory
From film f
Left Join inventory i On f.film_id = i.film_id
Group By f.film_id
HAVING Count(i.inventory_id) = 0;

-- If need only the count of movies with zero inventory

Select Count(*)
From (
	Select
		f.film_id,
		Count(i.inventory_id) as zero_inventory
	From film f
	Left Join inventory i On f.film_id = i.film_id
	Group By f.film_id
	HAVING Count(i.inventory_id) = 0
    ) as sub;

-- 5. Staff with NULL picture (IS NULL) show names
Select 
	staff_id,
    first_name
From staff
Where picture is null;

-- ==================================================
-- Duplicates & Cleaning
-- ==================================================
-- 6. Find duplicate actor names (GROUP BY first_name, last_name HAVING COUNT >1).
Select
	first_name,
    last_name,
    Count(*) as Total_Duplicates
From actor
Group By first_name, last_name
Having Count(*) > 1;

-- 7. Dedupe actor_backup (your self-join DELETE pattern, keep lowest actor_id).
-- Here need a self-join DELETE
-- Backup first!
CREATE TABLE actor_backup AS SELECT * FROM actor;

-- Always verify first
SELECT a1.*
FROM actor_backup a1
JOIN actor_backup a2
  ON a1.first_name = a2.first_name
 AND a1.last_name = a2.last_name
 AND a1.actor_id > a2.actor_id;
 
Delete a1
From actor_backup a1
Join actor_backup a2
	On a1.first_name = a2.first_name
    And a1.last_name = a2.last_name
    And a1.actor_id > a2.actor_id;

-- 8. Duplicate payments? (GROUP BY customer_id, amount, payment_date HAVING COUNT >1).
Select
	customer_id, 
    amount, 
    payment_date,
	Count(*) as duplicate_count
From payment
Group By customer_id, amount, payment_date
Having Count(*)> 1;

-- 9. Fix invalid emails: NOT LIKE '%@%.com' → 'invalid@example.com' (UPDATE CASE).
Update customer_backup
Set email = Case 
				When email Not Like '%@%.com' 
                Then 'invalid@example.com'
                Else email
			End;
-- --------------------OR ----------------------------------                    
UPDATE customer_backup
SET email = 'invalid@example.com'
WHERE email NOT LIKE '%@%.com';

-- 10. Customers with same email (GROUP BY email HAVING COUNT >1).
Select 
	email,
    Count(*) as email_count
From customer
Group By email
Having Count(*) > 1;
-- --------------------OR ----------------------------------                    
Select c.*
From customer c
Join (
		Select email
        From customer
        Group By email
        Having Count(*) > 1
	) d
    On c.email = d.email;

-- ==========================================
-- Data Quality DML 
-- ==========================================
-- 11. UPDATE films SET rating=COALESCE(rating, 'PG') WHERE rating IS NULL.
Create Table film_backup As
Select * from film;

Update film_backup 
Set rating = Coalesce(rating, 'PG')
Where rating Is Null;

-- 12. DELETE payments WHERE amount <0.01 (low value)
Delete From payment_backup 
Where amount < 0.01;
Select row_count(); 		-- To verify

-- 13. INSERT missing store_id=3 customer (customer_id=600, name='Test').
Insert Into customer_backup
(customer_id, store_id, first_name, last_name, email, address_id, active, create_date, last_update)
Values
(600, 3, 'Test', 'User', 'test@example.com', 1, 1, NOW(), NOW());

-- 14. Bulk UPDATE overdue rentals (return_date NULL) SET late_fee=2.00.
Create Table rental_backup as
Select * from rental;

Select * From rental_backup;

Alter Table rental_backup
Add Column late_fee Decimal(5, 2);

Update rental_backup
Set late_fee = 2.00
Where return_date Is Null;
-- -------------OR-----------------------
ALTER TABLE rental_backup
ADD COLUMN status_flag VARCHAR(20);

UPDATE rental_backup
SET status_flag =
    CASE
        WHEN return_date IS NULL THEN 'Overdue'
        ELSE 'Returned'
    END;
    
-- 15. Cleanup: DROP unused backup tables (actor_backup, etc.).
Drop Table If Exists actor_backup;
Drop Table If Exists payment_backup;
Drop Table If Exists customer_backup;
Drop Table If Exists film_backup;
Drop Table If Exists rental_backup;









