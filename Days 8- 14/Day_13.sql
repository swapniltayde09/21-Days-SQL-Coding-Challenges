-- ==================================================
-- Day 13: Window Functions + Advanced Data Cleaning 
-- ==================================================
Use sakila;

-- 1. Backup key tables
CREATE TABLE IF NOT EXISTS payment_safety AS SELECT * FROM payment;
CREATE TABLE IF NOT EXISTS customer_safety AS SELECT * FROM customer;
CREATE TABLE IF NOT EXISTS film_safety AS SELECT * FROM film;
CREATE TABLE IF NOT EXISTS rental_safety AS SELECT * FROM rental;

-- =================================
-- Window Functions (ROW_NUMBER(), RANK(), DENSE_RANK(), SUM(), AVG())
-- =================================
-- Syntax:
-- SELECT 
--  RANK() / DENSE_RANK() / ROW_NUMBER() OVER ( -- Compulsory expression
--    PARTITION BY partitioning_expression -- Optional expression
--    ORDER BY order_expression) -- Compulsory expression
-- FROM table_name;

-- 1. Rank actors based on the length of their last_name in descending order using ROW_NUMBER().
Select
	first_name,
	last_name,
    length(last_name),
    Row_Number() Over (
				 Order By length(last_name) Desc
					) as lastname_length		
From actor;

-- 2. Calculate total revenue per film and rank films within each rating category using RANK() with PARTITION BY rating.
Select
	f.film_id,
    f.title,
    f.rating,
    Sum(p.amount) as Total_Revenue,
    Rank() Over (
		Partition By f.rating
        Order By Sum(p.amount) Desc
				) as Revenue_Rank
From film f
Join inventory i On f.film_id = i. film_id
Join rental r On i.inventory_id = r.inventory_id
Join payment p On r.rental_id = p.rental_id
Group By f.film_id, f.title, f.rating;
    
-- 3. Calculate total spend per customer
Select
	customer_id,
    total_spend,
    Row_Number() Over (Order By total_spend Desc) as Row_Rank_revenue, 
    Dense_Rank() Over (Order By total_spend Desc) As Dense_Rank_revenue
From (
	Select 
		customer_id,
        Sum(amount) as total_spend
	From payment
    Group By customer_id
    ) t;

-- 4. Rentals per day RANK() (DATE(rental_date) PARTITION BY).
Select
	rental_day,
    daily_rentals,
    Rank() Over (Order By daily_rentals Desc) as rental_rank
From (
	Select
		Date(rental_date) as rental_day,
        Count(*) as daily_rentals
	From rental
    Group By Date(rental_date)
	) t;
    
-- 5. Staff revenue running total (SUM(amount) OVER ORDER BY payment_date).
Select
	staff_id,    
	Sum(amount) Over (order By payment_date) as RunningTotal
From rental;

-- 6. Customer consecutive rentals streak (LAG(rental_date) detect gaps).
Select 
	customer_id,
    Lag(rental_date) Over (Partition By customer_id Order By rental_date) as lagged_date
From rental;

-- 7. Films rented most (COUNT(rental) ROW_NUMBER() OVER ORDER BY).
Select 
	inventory_id,
    Count(rental_date),
    Row_Number() Over (Partition By Date(rental_date) Order By Count(rental_date) Desc) as rented_ranked
From rental;

-- 8. Payment amounts percentile (NTILE(4) OVER ORDER BY amount).
Select
	customer_id,
    amount,
    NTILE(4) OVER (ORDER BY amount) as amount_quartile
From payment;

-- 9. Actor name length running AVG.
Select
	actor_id,
    Length(Concat(first_name, ' ', last_name)) as name_length,
    Avg(Length(Concat(first_name, ' ', last_name)))
		Over (order By actor_id) as running_avg_length
	From actor;

-- 10. Top 3 categories by revenue (RANK() OVER ORDER BY revenue).
Select *
	From (
		Select 
			c.name as Categor_Name,
            Sum(p.amount) as Total_Revenue,
            Rank() Over (
					Order By Sum(p.amount) Desc
			) as Revenue_Rank
		From category c
		Join film_category fc On c.category_id = fc.category_id
        Join inventory i On fc.film_id = i.film_id
        Join rental r On i.inventory_id = r.inventory_id
        Join payment p On r.rental_id = p.rental_id
        Group By c.name
) t
Where Revenue_Rank <= 3;

-- =======================================
-- Data Cleaning Mastery
-- =======================================
-- 11. Fix payments with missing staff assignment.
-- Question: Update payments where staff_id is NULL and assign them to staff_id = 1.
Update payment_safety
Set staff_id = 1
Where staff_id Is Null;

-- 12. Remove duplicate customers by email.
-- Question: Delete duplicate customers having the same email. Keep the lowest customer_id.
Delete c1
From customer_safety c1
Join customer_safety c2
On c1.email = c2.email
And  c1.customer_id > c2.customer_id;

-- 13. Replace NULL film descriptions
-- Question: Replace NULL descriptions with 'No description'.
Update film_safety
Set description = 'No Description'
Where description Is Null;
------------------- OR ----------------------
Select 
	title,
    Coalesce(description, 'No Desctription') As cleaned_description
From film_safety;

-- 14. Standardize invalid ratings
-- Question: Update films with rating 'X' or 'NC-17' to 'R'
Update film_safety
Set rating = 'R'
Where rating In ('X', 'NC-17');

-- 15. Check duplicate rental IDs
-- Question: Identify rental_id values that appear more than once.
Select 
	rental_id,
    Count(*) as duplicate_count
From rental
Group By rental_id
Having Count(*) > 1;
-- rental_id is primary key in Sakila — this will return as zero rows.

-- 16. Fix missing payment dates.
-- Question: Update payments with NULL payment_date to current timestamp.
Update payment_safety
Set payment_date = ( 
	Select mode_date From (
		Select payment_date as mode_date
        From payment
        Where payment_date Is Not Null
        Group By payment_date
        Order By Count(*) Desc
        Limit 1
	) t
)
Where payment_date Is Null;

-- 17. Reactivate loyal customers.
-- Question: Customers marked inactive (active = 0) but having more than 10 rentals should be updated to active = 1.
Update customer_safety c
Join (
	Select customer_id
    From rental_safety
    Group By customer_Id
    Having Count(*) > 10
) r
On c.customer_id = r.customer_id
Set c.active = 1
Where c.active = 0;

-- 18. Bulk insert 5 test payments
-- Question: Insert 5 payments for customer_id = 599.
Insert Into payment_safety
(payment_id, customer_id, staff_id, rental_id, amount, payment_date, last_update)
Values
((Select Max(payment_id)+1 From payment), 599, 1, 2001, 4.99, Now(), Now()),
((Select Max(payment_id)+2 From payment), 599, 1, 2002, 4.99, Now(), Now()),
((Select Max(payment_id)+3 From payment), 599, 1, 2003, 4.99, Now(), Now()),
((Select Max(payment_id)+4 From payment), 599, 1, 2004, 4.99, Now(), Now()),
((Select Max(payment_id)+5 From payment), 599, 1, 2005, 4.99, Now(), Now());

-- 19. Delete zero-amount payments
-- Question: Remove payments where amount = 0.00.
Delete From payment_safety
Where amount = 0.00;

Select Row_count();

-- 20. Data audit — Count NULLs per column
-- Question: Count NULL values per important columns.
Select 
	Sum(staff_id Is Null) as null_staff,
    Sum(payment_date Is Null) as null_payment_date,
    Sum(amount Is Null) as null_payment
From payment;

Select
	Sum(email Is Null) as null_email,
    Sum(address_id Is Null) as null_address,
    Sum(active Is Null) as null_active
From customer;

