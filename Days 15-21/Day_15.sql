-- ===============================================
-- Day 15: CTEs + Subqueries + Window combinations
-- ===============================================
Use sakila;

-- ===================================
-- CTE BASICS
-- ===================================
-- 1. High-spend customers: Identify customers whose total spend exceeds 150 and count them.
With customer_spend as (
	Select 
		customer_id, 
        Sum(amount) as total_spend
    From payment
    Group By customer_id
)
Select Count(*) as high_spend_count
From customer_spend
Where total_spend > 150;

-- 2. Top 3 films by rentals: Find the top 3 most rented films.
With film_rentals as (
	Select 
		f.film_id,
        f.title,
        Count(r.rental_id) as rental_count
	From film f
    Join inventory i on f.film_id = i.film_id
    Join rental r on i.inventory_id = r.inventory_id
    Group by f.film_id, f.title
)
Select *
From film_rentals
Order by rental_count Desc
Limit 3;

-- 3. Rental → Payment → Customer chain: Display rental_id, payment_id, and customer details.
With rental_chain as (
	Select
		r.rental_id,
        p.payment_id,
        p.customer_id
	From rental r
    Join payment p on r.rental_id = p.rental_id
)
Select 
	rc.*,
	c.first_name,
    c.last_name
From rental_chain rc
Join customer c On rc.customer_id = c.customer_id;

-- 4. Monthly revenue and average monthly revenue: Compute monthly revenue, then calculate the average monthly revenue.
With monthly_revenue as (
	Select 
		Date_Format(payment_date, '%Y-%m') as revenue_month,
		Sum(amount) as total_revenue
	From payment
    Group by Date_Format(payment_date, '%Y-%m')
)
Select 
	Avg(total_revenue) as avg_monthly_revenue
From monthly_revenue;
    
-- 5. Find duplicate emails and show full customer details.
With duplicate_emails as (
	Select email
    From customer
    Group By email
    Having Count(*) > 1
)
Select c.* 
From customer c
Join duplicate_emails d
On c.email = d.email;
    
-- 6. Films never rented: Identify and count films that were never rented.
With rented_films as (
	Select Distinct i.film_id
    From inventory i
    Join rental r On i.inventory_id = r.inventory_id
)
Select 
	f.film_id,
	f.title
From film f
Left Join rented_films rf
On f.film_id = rf.film_id
Where rf.film_id Is Null;

-- ============================================
-- SUBQUERIES
-- ===========================================
-- 7. Customers spending above overall average
Select 
	customer_id,
    Sum(amount) as total_spend
From payment
Group By customer_id
Having total_spend > (
	Select Avg(total_customer_spend)
    From (
		Select Sum(amount) as total_customer_spend
        From payment
        Group By customer_id
	) t
);

-- 8. Films rented more than average rentals
Select
	f.film_id, 
    Count(r.rental_id) as rental_count
From film f
Join inventory i On f.film_id = i.film_id
Join rental r On i.inventory_id = r.inventory_id
Group By f.film_id
Having rental_count > (
	Select Avg(rentals_per_film)
    From (
		Select Count(r.rental_id) as rentals_per_film
        From film f2
        Join inventory i2 On f2.film_id = i2.film_id
        Join rental r2 On i2.inventory_id = r2.inventory_id
        Group By f2.film_id
		) x
);

-- 9. Staff with revenue above store average
Select 
	staff_id,
    Sum(amount) as staff_revenue
From payment
Group By staff_id
Having staff_revenue > (
	Select Avg(store_revenue)
    From (
		Select 
			staff_id,
            Sum(amount) as store_revenue
		From payment
        Group By staff_id
	) s
);
            
-- 10. Payments not made by top 3 customers
Select *
From payment
Where customer_id Not In (
	Select customer_id
    From (
		Select customer_id
        From payment
        Group By customer_id
        Order By Sum(amount) Desc
        Limit 3
	) Top3
);
    
-- 11. Categories with films longer than average film length
Select c.name, avg(f.length) as avg_length
From category c
Join film_category fc On c.category_id = fc.category_id
Join film f On fc.film_id = f.film_id
Group By c.name 
Having avg_length > ( 
	Select Avg(length) From film
);

-- 12. Rentals before first payment
Select r.*
From rental r
Where r.rental_date < ( 
	Select Min(payment_date)
    From payment p 
    Where p.customer_id  = r.customer_id
);

-- ========================================
-- CTE + WINDOWS
-- ========================================
-- 13. Customer revenue rank
With customer_revenue as (
	Select 
		customer_id, 
        Sum(amount) as Total_Spend
	From payment
    Group By customer_id
)
Select *,
	Rank () Over (Order By Total_Spend Desc) As revenue_rank
From customer_revenue;

-- 14. Running total payments
With running_payments as (
	Select 
		customer_id,
        payment_date,
        Sum(amount) Over (
			Partition By customer_id
            Order By payment_date
		) as running_total
	From payment
)
Select * From running_payments;

-- 15. LAG payment amount
With payment_lag As (
	Select 
		customer_id,
        payment_date,
        amount,
        Lag(amount) Over (
			Partition By customer_id
            Order By payment_date
		) as previous_amount
	From payment
)
Select * From payment_lag;

-- 16. Top 3 customers per rating
With rating_spend as (
	Select f.rating, p.customer_id, Sum(p.amount) as spend
    From payment p
    Join rental r On p.rental_id = r.rental_id
    Join inventory i On r.inventory_id = i.inventory_id
    Join film f On i.film_id = f.film_id
    Group By f.rating, p.customer_id
)
Select *
From (
	Select *,
		Rank() Over (
			Partition By rating
            Order By spend Desc
		) As rating_rank
	From rating_spend
) t
Where rating_rank <= 3;

-- 17. Film revenue percentile
With film_revenue as (
    Select f.film_id, SUM(p.amount) as revenue
    From film f
    Join inventory i On f.film_id = i.film_id
    Join rental r On i.inventory_id = r.inventory_id
    Join payment p On r.rental_id = p.rental_id
    Group By f.film_id
)
Select *,
       Ntile(4) Over (Order By revenue Desc) as revenue_quartile
From film_revenue;

-- 18. Consecutive rental days
With rental_gaps AS (
    Select customer_id, rental_date,
           Datediff(
               rental_date,
               Lag(rental_date) Over (
                   Partition By customer_id
                   Order By rental_date
               )
           ) as gap_days
    From rental
)
Select *
From rental_gaps
Where gap_days = 1;

-- 19. Monthly revenue MoM growth
With monthly_rev as (
Select date_format(payment_date, '%y-%m') as month,
sum(amount) as revenue
From payment
Group By date_format(payment_date, '%y-%m')
)
Select 
	month,
	revenue,
	revenue - Lag(revenue) Over (Order By month) as mom_growth
From monthly_rev;

-- 20. Average rating per category
With category_avg as (
	Select 
		c.name as category_name,
		Avg(f.rental_rate) as avg_rate
	From category c
	Join film_category fc On c.category_id = fc.category_id
	Join film f on fc.film_id = f.film_id
	Group by c.name
)
Select * From category_avg;



















    
    
    
    
    
    
    
    
    
    
    
    
    
    
        












		