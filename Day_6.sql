-- ====================================
-- Day 6: JOIN Mastery (All Types)
-- ====================================

-- INNER JOIN (Matching Only)
-- 1. Total spend per customer; top 5 DESC
Select
	c.customer_id,
    c.first_name,
    Sum(Coalesce(p.amount, 0)) as Total_Spent
From customer c
Join payment p On c.customer_id = p.customer_id
Group By
	c.customer_id,
    c.first_name
Order By Sum(Coalesce(p.amount, 0))
Limit 5;

-- 2. Rentals per staff; show first_name, COUNT(*)
Select
	s.first_name,
    Count(r.rental_id) as Rental_Count
From staff s
Inner Join rental r On s.staff_id = r.staff_id
Group By s.staff_id, s.first_name	
Order By Rental_Count Desc;

-- ================================
-- LEFT JOIN (All Left + Matches)
-- ================================
-- 3. All customer, their payment total (0 if none); avg spend

Select
	c. customer_id,
    Avg(Coalesce(Sum(p.amount), 0)) as Avg_Spend
From customer c
Left Join payment p 
On c.customer_id = p.customer_id
Group By c.customer_id;

-- 4. All film + inventory count (0 if none); films with 0 copies
Select 
	f.film_id,
    f.title,
    Count(i.inventory_id) As Inventory_Count
From film f
Left Join inventory i On f.film_id = i.film_id
Group By f.film_id, f.title
Having Count(i.inventory_id) = 0;

-- 5. All staff + payment total earned; show first_name, revenue
Select
	s.staff_id,
    s.first_name,
    Sum(p.amount) Total_Earned
From staff s
Left Join payment p On s.staff_id = p.staff_id
Group By staff_id;

-- =================================================
-- RIGHT JOIN (All Right + Matches)
-- =================================================
-- 6. All payment + staff first_name (NULL if orphan); count orphans
Select Count(*) as orphan_payments
From payment p
Left Join staff s On p.staff_id = s.staff_id	-- Left simulates Right
Where s.staff_id Is Null;

-- 7. All inventory + film title (NULL if orphan film); count NULL titles 
Select Count(f.title) as Null_Count
From inventory i
Right Join film f On i.film_id = f.film_id
Where i.inventory_id Is Null;

-- ===========================================================
-- FULL OUTER (All Both - Simulation)
-- ===========================================================
-- 8. All customer + payment total (0 if none); total customers 
Select Count(Distinct c.customer_id) as total_customers
From customer c
Left Join payment p 
On c.customer_id = p.customer_id
Union
Select Count(Distinct p.customer_id)
From payment p
Right Join customer c 
On p.customer_id = c.customer_id;

-- 9. All film + rental count (0 if unrented); unrented films
Select 
	f.title,
    count(r.rental_id) as rentals
From film f
Left Join inventory i on f.film_id = i.film_id
Left Join rental r on i.inventory_id = r.inventory_id	
Group By f.film_id, f.title
Having count(r.rental_id) = 0
Order By f.title;

-- ============================================
-- Multiple + Aggregate JOINs
-- ============================================
-- 10. rentals + spend per customer; top 3
Select
	c.customer_id,
    Count(r.rental_id),
    Sum(p.amount)
From customer c
Join rental r on c.customer_id = r.customer_id
Join payment p On c.customer_id = p.customer_id
Group By c.customer_id
Order By Sum(p.amount) Desc
Limit 3;

-- 11. All store + staff count; stores with 0 staff.
Select 
	s1.store_id,
    Count(s2.staff_id) As staff_count
From store s1
Left Join staff s2 On s1.store_id = s2.store_id
Group By s1.store_id
Having Count(s2.staff_id) = 0;
	
-- 12. Customers with > $200 spend AND >20 rentals.
Select 
	c.customer_id,
	Sum(p.amount) as Total_Spent,
    Count(r.rental_id) as Total_Rented
From customer c
Join payment p On c.customer_id = p.customer_id
Join rental r On p.customer_id = r.customer_id
Group By c.customer_id
Having Sum(p.amount) > 200 AND Count(r.rental_id) > 20;

-- =================================
-- Anti-Joins (Missing Matches)
-- =================================
-- 13. Customers with no payments
Select Count(*) as No_Payments
From customer c
Left Join payment p On c.customer_id = p.customer_id
Where p.customer_id Is Null;

-- 14. Payments with no matching customer (orphans).
Select Count(*) as orphan_payments
From payment p
Right Join customer c On c.customer_id = p.customer_id
Where c.customer_id is null;

-- 15. Business (LEFT + HAVING): Films with inventory but 0 rentals; list titles.
Select f.title
From film f
Join inventory i On f.film_id = i.film_id
Left Join rental r On i.inventory_id = r.inventory_id
Group By f.film_id, f.title
Having Count(r.rental_id) = 0;
    
	







    


