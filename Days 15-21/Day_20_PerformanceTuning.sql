-- =========================================
-- Day 20 — SQL Performance Tuning Project
-- =========================================
-- Analysis Phase
-- =========================================
-- 1. Student database — check join performance
-- Question: Analyze a query joining students and enrollments filtered by city.
Use student_db;

Explain
Select *
From students s
Join enrollments e
	On s.student_id = e.student_id
Where s.city = 'Mumbai';

-- 2. Ecommerce database — order filtering performance
-- Question: Analyze a query retrieving order item revenue for recent orders.
Use ecommerce_db;

Explain 
Select oi.quantity * oi.unit_price
From order_items oi
Join orders o
	On oi.order_id = o.order_id
Where o.order_date >= '2026-02-01';

-- 3. Finance tracker — function preventing index use
-- Question: Analyze expense totals for year 2026.
Use finance_tracker;

Explain 
Select Sum(Abs(t.amount))
From transactions t
Join categories c
	On t.category_id = c.category_id
Where Year(t.transaction_date) = 2026
And c.type = 'Expense';

-- 4. Log analyzer — LIKE pattern performance
-- Question: Analyze counting error events from a subnet.
Use log_analyzer;

Explain 
Select Count(*)
From events
Where event_type = 'Error'
And ip_address Like '192.168.1.%';

-- 5. Identify the slowest query
-- Question: Run EXPLAIN for all queries and compare:
-- Look for:
-- type = ALL (full table scan)
-- large rows value
-- Using filesort

EXPLAIN SELECT * FROM students;

-- ==================================
-- Index Optimization
-- ==================================
-- 6. Optimize Student DB query 			
Use student_db;

-- Add 'city' column
Alter Table students add column city Varchar(50) default 'Unknown';

-- Add city data to your existing students
Update students set city = 'Mumbai' Where student_id IN (1,4);  -- Swapnil/Anita
Update students set city = 'Delhi' Where student_id = 2;        -- Rahul
Update students set city = 'Pune' Where student_id = 3;         -- Rohit
Update students set city = 'Bangalore' Where student_id = 5;    -- Neha

-- Add composite index
Create Index idx_student_city_enroll
On students(city, student_id);

-- Retest
Explain 
Select * 
From students s 
Join enrollments e
	On s.student_id = e.student_id
Where s.city = 'Mumbai';

-- 7. Optimize Ecommerce orders query
Use ecommerce_db;

Create Index idx_order_date_cust
On orders(order_date, customer_id);

-- Test Again
Explain
Select oi.quantity * oi.unit_price
From order_items oi
Join orders o
	On oi.order_id = o.order_id
Where o.order_date >= '2026-02-01';

-- 8. Optimize Finance tracker query
Use finance_tracker;

Alter Table transactions
Add Column trans_year Int
Generated Always as (Year(transaction_date)) stored;

-- Rewrite query
Explain 
Select Sum(Abs(t.amount))
From transactions t
Join categories c
	On t.category_id = c.category_id
Where t.trans_year = 2026
And c.type = 'Expense';

-- 9. Optimize Log Analyzer subnet search
Use log_analyzer;

Create Index idx_ip_event
On events(ip_address(8), event_type);

-- Retest 
Explain 
Select Count(*)
From events
Where event_type = 'Error'
And ip_address Like '192.168.1.%';

-- 10. Fix filesort issue
Use ecommerce_db;

Explain 
Select *
From orders
Order By order_date Desc;

-- ===============================
-- Query Refactors
-- ===============================
-- 11. Replace slow LIKE search
Use student_db;

-- Original
Select *
From students
Where email Like's%';

-- Optimised Version
Select * 
From students
Where email >= 's'
	And email < 't';

-- 12. Pagination optimization
Use ecommerce_db;

-- Original query:
Select *
From orders
Order By order_date Desc
Limit 100 Offset 1000;

-- Add index
Create Index idx_order_date
	On orders(order_date Desc);

-- Optimised pagination approach:
Select * 
From orders
Where order_date < '2026-04-01'
Order By order_date Desc
Limit 100;

-- 13. Running balance using window function
Use finance_tracker;

-- Efficient Version:
Select
	account_id,
    transaction_date,
    amount,
    Sum(amount) Over (
		Partition BY account_id
		Order By transaction_date
	) as running_balance
From transactions;

-- 14. Optimize hourly error query
Use log_analyzer;

-- Original Query:
Explain 
Select
	Hour(timestamp),
    Count(*)
From events
Where status_code >= 400
Group By Hour(timestamp);

-- 15. Cross-database optimization query XXXXXXXXXXXXXXXXXXXXXXXX
-- Question: Find Mumbai customers with orders in the last 30 days.
	-- Optimized query:
Select
	c.customer_id,
    c.first_name,
    o.order_id,
    o.order_date
From student_db.students s
Join ecommerce_db.customers c
	On s.email = c.email
Join ecommerce_db.orders o
	On c.customer_id = o.customer_id
Where s.city = 'Mumbai'
And o.order_date >= Curdate() - Interval 30 Day;

-- Index needed:
Create Index idx_student_city
On student_db.students(city);

Create Index idx_order_date_customer
On ecommerce_db.orders(order_date, customer_id);











