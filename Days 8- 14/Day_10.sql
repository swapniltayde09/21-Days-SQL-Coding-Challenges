-- ===========================================
-- Day 10: Data Modifications + CASE + NULL Handling
-- ===========================================

Use sakila;

-- ===========================================
-- CASE + NULLs 
-- ===========================================
-- 1. Categorize payments by amount: amount <2 'Low', 2-5 'Med', >5 'High', count each
Select
	Case
		When amount < 2 Then 'Low'
        When amount Between 2 and 5 Then 'Medium'
        Else 'High'
	End As Payment_Category,
		Count(payment_id)
From payment
Group By Payment_Category;

-- 2. Customer activity per store: active=1 'Active', 0 'Inactive'
Select
	store_id,
    Case
		When active = 1 Then 'Active'
        Else 'Inactive'
	End as Customer_Status,
    Count(*) as Customer_Count
From customer
Group By store_id, Customer_Status;

-- 3. Classify and count films based on rating: 'G' → 'Family', 'PG' → 'Kids', ELSE 'Adult'.
Select
	Case
		When rating = 'G' Then 'Family'
        When rating = 'PG' Then 'Kids'
        Else 'Adult'
	End as Movie_Category,
    Count(film_id)
From film
Group By Movie_Category;

-- 4. Staff labels by store: store_id=1 'Store A', 2 'Store B' show names.
Select
	Case
		When store_id = 1 Then 'Store A'
        Else 'Store B'
	End as Store_Name,
    first_name
From staff;
    
-- 5. Rental return status: returndate NULL 'Overdue', ELSE 'Returned' count overdue.
Select
	Case
		When return_date IS NULL Then 'Overdue'
        Else 'Returned'
	End as Return_Status,
	Count(*) as Rental_Count
From rental
Group By Return_Status;

-- 6. Actor last name length category: LENGTH(last_name) >5 'Long', ELSE 'Short' count each category.
Select
	Case
		When Length(last_name) > 5 Then 'Long'
        Else 'Short'
	End as Last_Name_Length,
    Count(*) as Lastname_Count
From actor
Group By Last_Name_Length;

-- 7. Payments missing staff assignment
Select Count(*) as Missing_Staff_Payment
From staff
Where staff_id Is Null;

-- ===========================================
-- DML Basics
-- ===========================================

CREATE TABLE actor_backup AS SELECT * FROM actor;

-- 9. INSERT new actor: first_name='John', last_name='Doe'.
Insert Into actor_backup (first_name, last_name) Values
	('John', 'Doe');

-- 10. UPDATE actor SET first_name='Jane' WHERE actor_id=1 (1 row).
Update actor_backup
Set first_name = 'Jane' 
Where actor_id=1;

Select * From actor_backup 
Where actor_id = 1;

-- 11. DELETE an actor safely
Delete From actor_backup
Where actor_id = 1000;

Select * From actor_backup 
Where actor_id = 1000;

-- 12. INSERT payment data
CREATE TABLE payment_backup AS SELECT * FROM payment;

INSERT INTO payment_backup 
(payment_id, customer_id, staff_id, rental_id, amount, payment_date, last_update)
VALUES (
    (SELECT MAX(payment_id) + 1 FROM payment_backup),
    1,
    1,
    1,
    5.99,
    NOW(),
    NOW()
);


-- 13. UPDATE payment SET amount=6.99 WHERE payment_id=1.
Update payment_backup
Set amount = 6.99
Where payment_id = 1;

-- 14. Customers with zero rentals.
Select
	c.customer_id,
    c.first_name,
    c.last_name
From customer c
Left Join rental r On c.customer_id = r.customer_id
Where r.rental_id Is Null;

SELECT
    c.customer_id,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r 
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id
HAVING COUNT(r.rental_id) = 0;

-- 15. Films never rented.
Select
	f.film_id,
    f.title
From film f
Left Join inventory i On f.film_id = i.film_id
Left Join rental r On i.inventory_id = r.inventory_id
Where r.rental_id Is Null;

