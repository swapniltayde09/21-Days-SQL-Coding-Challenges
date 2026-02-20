-- ==============================================
-- Day 11: UPDATE/DELETE 
-- ==============================================

Use sakila;

CREATE TABLE payment_backup AS SELECT * FROM payment;

-- ==============================================
-- Advanced CASE 
-- ==============================================
-- 1. Count the payments tiered by seasons: Q1 'Winter', Q2/Q3 'Spring/Summer', Q4 'Fall'
Select
	Case 
		When Month(payment_date) In (1, 2, 3) Then 'Winter'
        When Month(payment_date) in (4, 5, 6) Then 'Spring'
        When Month(payment_date) in (7, 8, 9) Then 'Summer'
        When Month(payment_date) in (10, 11, 12) Then 'Fall'
	End as seasons,
    Count(*) as payment_count
From payment
Group By seasons
ORDER BY payment_count DESC;

-- 2. Customers lifetime value: total_spend >200 'VIP', 100-200 'Regular', <100 'New'.
Select
	customer_id,
    Sum(amount) as total_spend,
	Case
		When Sum(amount) < 100 Then 'New'
        When Sum(amount) Between 100 And 200 Then 'Regular'
        When Sum(amount) > 200 Then 'VIP'
	End as customer_status
From payment
Group by customer_id;

-- 3. Films by length: <60 'Short', 60-120 'Feature', >120 'Epic' AVG rental_rate.
Select
	Case
		When length < 60 Then 'Short'
        When length  between 60 and 120 Then 'Feature'
        When length > 120 Then 'Epic'
	End as film_type,
    AVG(rental_rate) AS avg_rental_rate
From film
Group By film_type;

-- 4. Actors by name length: Count of Full name > 15 then 'Long Name'
Select
	Case
		When Length(Concat(first_name, ' ', last_name)) > 15 Then 'Long Name'
        Else 'Normal Length'
	End as name_length,
    Count(*)
From actor
Group By name_length;
        

-- 5. Weekend vs Weekday Rentals
Select 
	Case 
		When Dayofweek(rental_date) in (1, 7) Then 'Weekend'
        Else 'Weekday'
	End as 'rental_type',
    Count(*) as rental_count
From rental
Group By rental_type;

-- 6. Staff performance: revenue >15000 'Top', <10000 'Needs Training.
Select
	staff_id,
    Sum(amount) as total_revenue,
    Case
		When Sum(amount) > 15000 Then 'Top'
        When Sum(amount) Between 10000 And 15000 Then 'Safe'
        Else 'Needs Training'
	End as performance_status
    From payment
    Group By staff_id;

-- 7. Film Maturity Classification: Films PG-13 or R 'Mature', others 'Family' per category count.
Select
	Case
		When rating like 'PG-13' OR rating like 'R' Then 'Mature'
        Else 'Family'
	End as film_category,
    Count(*) as total_count
From film
Group By film_category;

-- 8. Payments Tax Calculation
Select
	payment_id,
    amount as original_amount,
    Round(amount * 1.08, 2) as taxed_amount
From payment;

-- ====================================================
-- UPDATE/DELETE 
-- ====================================================
-- 9. UPDATE actor last names to uppercase where last name strarts with an A.
Update actor
Set last_name = Upper(last_name)
Where first_name like 'A%';

Select * From actor Where first_name like 'A%';

-- 10. UPDATE film ratings to 'PG' where the lenght of title is less than 15.
Update film 
Set rating='PG' 
Where LENGTH(title) < 50;

Select * from film Where LENGTH(title) < 50;			-- Run this query before and afer 

-- 11. Delete payments less than $1.00.
Delete From payment_backup
Where amount < 1.00;

Select row_count();

-- 12.Update customer active flag.
Create Table customer_backup AS
Select * from customer;

Select * from customer_backup Where store_id = 2 and customer_id < 100; 

Update customer_backup
Set active = 0 
WHERE store_id=2 AND customer_id < 100;

-- 13. CASE UPDATE rentals: overdue (returndate NULL) flag new col (ALTER + UPDATE).
Alter Table rental
Add Column status_flag varchar(255);

Update rental
Set status_flag = 
	Case
		When return_date is Null Then 'Overdue'
        Else 'Returned'
	End;

-- 14.DELETE duplicate actors (keep lowest actor_id).
Create Table actor_backup AS 
Select * 
From actor;

Delete a1
From actor_backup a1
Join actor_backup a2 				-- self-join delete keeping lowest `actor_id`
	On a1.first_name = a2.first_name
    And a1.last_name = a2.last_name
    And a1.actor_id > a2.actor_id;

-- 15. Bulk INSERT 3 payments for customer_id=1 (rental_id 1001-1003, amount=4.99).
Insert Into payment_backup
(customer_id, staff_id, rental_id, amount, payment_date, last_update)
Values
(1, 1, 1001, 4.99, NOW(), NOW()),
(1, 1, 1002, 4.99, NOW(), NOW()),
(1, 1, 1003, 4.99, NOW(), NOW());

