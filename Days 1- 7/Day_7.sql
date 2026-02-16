-- ==================================================
-- Day 7: JOIN + GROUP BY + HAVING (Combo Mastery)
-- ==================================================
Use sakila;

-- INNER JOIN + Basic Aggregates
-- 1. Total revenue per staff member
Select
	s.staff_id,
    s.first_name,
    Sum(p.amount) as Total_Revenue
From staff s
Join payment p On s.staff_id = p.staff_id
Group By s.staff_id
Order By Sum(p.amount) Desc;

-- 2. Calculate to total number of rentals per store
Select
	st.store_id,
    Count(r.rental_id) as rentals,
    Avg(Count(r.rental_id)) Over() as store_avg
From store st
JOIN customer c On st.store_id = c.store_id
JOIN rental r On c.customer_id = r.customer_id
GROUP BY st.store_id;

-- 3. Number of films per category
Select
    c.name,
	Count(fc.film_id) as film_count
From category c
Join film_category fc
	On c.category_id = fc.category_id
Join film f
	On fc.film_id = f.film_id
Group By c.name;

-- ========================================
-- LEFT JOIN + Aggregates (Zeros Included)
-- =========================================
-- 4. Categories with 0 Films
Select
	c.category_id,
    c.name,
    Count(fc.film_id) As film_count
From category c
Left Join film_category fc On c.category_id = fc.category_id
Left Join film f On fc.film_id = f.film_id
Group By c.category_id, c.name
Having film_count = 0;

-- 5. Customer Payment Count + Average
Select
	c.customer_id,
    Count(p.payment_id) As payment_count
From customer c
Left Join payment p On c.customer_id = p.customer_id
Group By c.customer_id;

-- Overall Average
Select Avg(payment_count) as Avg_payment_per_customer
From (
	Select
		c.customer_id,
		Count(p.payment_id) As payment_count
	From customer c
	Left Join payment p On c.customer_id = p.customer_id
	Group By c.customer_id
    ) As Customer_Payments;

-- 6. Staff Rental Count (Zero Included)
Select 
	s.staff_id,
	Count(r.rental_id) As Rental_Count
From staff as s
Left Join rental r 
	On s.staff_id = r.staff_id
Group By s.staff_id
Having Count(r.rental_id) = 0;

-- =================================================
-- HAVING Post-JOIN
-- =================================================
-- 7. Staff with revenue more than $20,000
Select
	s.staff_id,
    Sum(p.amount) as Total_Revenue
From staff s
Join payment p 
	On s.staff_id = p.staff_id
Group By s.staff_id
Having Total_Revenue > 20000;

-- 8. Enlist Categories with more than 50 Films in them
Select
	c.category_id,
    c.name,
    Count(fc.film_id) As film_count
From category c
Left Join film_category fc On c.category_id = fc.category_id
Left Join film f On fc.film_id = f.film_id
Group By c.category_id, c.name
Having Count(fc.film_id) > 50;

-- 9. Customers who spent more than $150 and have rented more than 15 times.
Select
	c.customer_id,
    Sum(p.amount) as Total_revenue,
    Count(r.rental_id) as Total_Rented
From customer c
Join payment p On c.customer_id = p.customer_id
Join rental r On c.customer_id = r.customer_id
Group By c.customer_id
Having Sum(p.amount) > 150 And Count(Distinct r.rental_id) > 15;

-- ==================================================
-- Multiple Aggregates + JOIN
-- ==================================================
-- 10. Payment Stats per Store
Select
	s.store_id,
    Min(p.amount) As Min_Paid,
    Max(p.amount) As Max_Paid,
    Avg(p.amount) As Avg_Paid
From store s
Join customer c On s.store_id = c.store_id
Join payment p On c.customer_id = p.customer_id
Group By s.store_id;

-- 11. LEFT JOIN: All film + inventory avg** (AVG(inventory_id) per film_category)
Select
	c.name as category,
    Avg(i.inventory_id) as avg_inventory_per_film,
    Count(i.inventory_id) as Total_Inventory
From film_category fc
Join category c  on fc.category_id = c.category_id
Join film f ON fc.film_id = f.film_id
Left Join inventory i on f.film_id = i.film_id 
Group By fc.category_id, c.name
Order By avg_inventory_per_film Desc
Limit 10;

-- ==========================
-- Business Aggregate JOINs
-- ==========================
-- 12. Revenue per Rental Day; top 3 days
Select
	Date(r.rental_date) as rental_day,
	Sum(p.amount) as Daily_Revenue
From rental r
Join payment p On r.rental_id = p.rental_id
Group By Date(r.rental_date)
Order By Daily_Revenue Desc
Limit 3;	

-- 13. Films in inventory but never rented
Select 
	f.title,
    f.film_id
From film f
Join inventory i On f.film_id = i.film_id
Left Join rental r On i.inventory_id = r.inventory_id
Where r.rental_id Is Null;

-- 14. Staff member/s who did transactions of more than $10 at Store 1
Select
	p.payment_id,
    p.amount,
    s.first_name
From payment p
Join staff s on p.staff_id = s.staff_id
Where s.store_id = 1 and p.amount >= 10;

-- 15. Top 3 Categories by Revenue
Select
	c.name as category,
    Sum(p.amount) as category_revenue
From payment p
Join rental r on p.rental_id = r.rental_id
Join inventory i on r.inventory_id = i.inventory_id
Join film f on i.film_id = f.film_id
Join film_category fc on f.film_id = fc.film_id
Join category c on fc.category_id = c.category_id
Group By c.category_id, c.name
Order By category_revenue Desc
Limit 5;





    
	
	



