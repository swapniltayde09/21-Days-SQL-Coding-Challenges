-- ===============================================
-- Day 14: Window LAG/LEAD + Running Totals
-- ===============================================
Use sakila;

-- Backup first
Create Table payment_backup As Select * From payment;

-- UPDATE with condition
UPDATE payment_backup
SET amount = amount * 1.08
WHERE amount BETWEEN 2 AND 5;

-- DELETE with condition
DELETE FROM payment_backup
WHERE amount < 0.01;

-- Verify
SELECT ROW_COUNT() AS rows_changed;

-- ==================================================
-- Running Totals 
-- ==================================================
-- 1. Running total of payments per customer
-- Question: For each customer, calculate a cumulative running total of payments ordered by payment_date.
Select
    customer_id,
    payment_date,
    amount,
    SUM(amount) Over (
        Partition By customer_id
        Order By payment_date
    ) AS running_total
FROM payment;

-- 2. Rental cumulative count over time
-- Question: Calculate cumulative total rentals ordered by rental_date.
Select
    rental_date,
    Count(*) Over (
        Order By rental_date
        Rows Between Unbounded Preceding And Current Row
    ) AS cumulative_rentals
From rental;

-- 3. Staff revenue running total.
-- Question: For each staff member, calculate cumulative revenue over time.
Select
    staff_id,
    payment_date,
    amount,
    SUM(amount) Over (
        Partition By staff_id
        Order By payment_date
        Rows Between Unbounded Preceding And Current Row
    ) As staff_running_total
From payment;

-- 4. Film rental running total
-- Question: Calculate cumulative rental count per film using film → inventory → rental chain.
Select
    f.film_id,
    r.rental_date,
    COUNT(r.rental_id) Over (
        Partition By f.film_id
        Order By r.rental_date
        Rows Between Unbounded Preceding And Current Row
    ) AS film_running_rentals
FROM film f
Join inventory i On f.film_id = i.film_id
Join rental r ON i.inventory_id = r.inventory_id;

-- 5. Customer Year-To-Date (YTD) spend
-- Question: Calculate cumulative spend per customer within each year.
Select
    customer_id,
    payment_date,
    amount,
    SUM(amount) Over (
        Partition By customer_id, Year(payment_date)
        Order By payment_date
        Rows Between Unbounded Preceding And Current Row
    ) As ytd_spend
From payment;

-- ===========================================
-- LAG / LEAD
-- ===========================================
-- 6. Previous payment amount
-- Question: Show previous payment amount for each customer.
Select
    customer_id,
    payment_date,
    amount,
    Lag(amount) Over (
        Partition By customer_id
        Order By payment_date
    ) As previous_amount
From payment;

-- 7. Next rental date
-- Question: Show next rental date in chronological order.
Select
    rental_id,
    rental_date,
    Lead(rental_date) Over (
        Order By rental_date
    ) As next_rental_date
From rental;

-- 8. Payment growth vs previous payment
-- Question: Calculate difference between current and previous payment per customer.
Select
    customer_id,
    payment_date,
    amount,
    amount - Lag(amount) Over (
        Partition By customer_id
        Order By payment_date
    ) As payment_growth
From payment;

-- 9. Consecutive rentals (1-day gap detection)
-- Question: Identify rentals that occurred exactly 1 day after the previous rental for the same customer.
Select
    customer_id,
    rental_date,
    Datediff(
        rental_date,
        Lag(rental_date) Over (
            Partition By customer_id
            Order By rental_date
        )
    ) As gap_days
From rental;

-- 10. Staff Month-over-Month revenue change
-- Question: Calculate monthly revenue per staff and compare with previous month.
Select
    staff_id,
    revenue_month,
    monthly_revenue,
    monthly_revenue - Lag(monthly_revenue) Over (
        Partition By staff_id
        Order By revenue_month
    ) as MoM_change
From (
    Select
        staff_id,
        Date_Format(payment_date, '%Y-%m') as revenue_month,
        Sum(amount) as monthly_revenue
    From payment
    Group By staff_id, DATE_FORMAT(payment_date, '%Y-%m')
) t;

-- ===================================
-- Advanced Windows
-- ===================================
-- 11. 3-day moving average payment
-- Question: Calculate moving average of payments over current row and previous 2 rows.
Select
    payment_date,
    amount,
    Avg(amount) Over (
        Order By payment_date
        Rows Between 2 Preceding and Current Row
    ) as moving_avg_3
From payment;

-- 12. Customer spend percentile (5 groups)
-- Question: Divide customers into 5 equal spending groups.
Select
    customer_id,
    total_spend,
    Ntile(5) Over (
        Order By total_spend Desc
    ) as spend_percentile
From (
    Select
        customer_id,
        SUM(amount) AS total_spend
    From payment
    Group By customer_id
) t;

-- 13. First and last payment per customer
-- Question: Show first and most recent payment per customer.
Select
    customer_id,
    payment_date,
    amount,
    First_Value(amount) Over (
        Partition By customer_id
        Order By payment_date
    ) As first_payment,
    Last_Value(amount) Over (
        Partition By customer_id
        Order By payment_date
        Rows Between Unbounded Preceding and Unbounded Following
        ) As last_payment
From payment;

-- 14. Rental streak detection
-- Step 1: Generate row numbers per customer
Select
    customer_id,
    rental_date,
    date_sub(rental_date, interval rn day) as streak_key
From (
    Select
        customer_id,
        rental_date,
        Row_number() over (
            Partition by customer_id
            Order by rental_date
        ) as rn
    From rental
) t;

-- step 2: use date offset trick to detect streak groups
Select
    customer_id,
    min(rental_date) as streak_start,
    max(rental_date) as streak_end,
    count(*) as streak_length
From (
    Select
        customer_id,
        rental_date,
        date_sub(rental_date, interval rn day) as streak_group
    From (
        Select
            customer_id,
            rental_date,
            Row_number() Over (
                Partition by customer_id
                Order by rental_date
            ) as rn
        From rental
    ) x
) y
Group by customer_id, streak_group
Order by customer_id, streak_start;

-- 15. Top 3 customers per month by spend
Select *
From (
    Select
        revenue_month,
        customer_id,
        monthly_spend,
        Rank() over (
            Partition by revenue_month
            Order by monthly_spend desc
        ) as rank_in_month
    From (
        Select
            date_format(payment_date, '%y-%m') as revenue_month,
            customer_id,
            sum(amount) as monthly_spend
        From payment
        Group by date_format(payment_date, '%y-%m'), customer_id
    ) t1
) t2
Where rank_in_month <= 3;
