-- =========================================
-- Day 9: Mixed Aggregates 
-- =========================================

Use sakila;

-- =========================================
-- String + Aggregate 
-- =========================================

-- 1. Count the number of actors grouped by the first letter of their first name. Display the results in descending order of actor count.
Select
	Left(first_name, 1) as first_letter
From actor
Group By first_letter
Order By Count(first_letter) Desc;

-- 2. Calculate the average length of film titles.
Select Avg(Length(title))
From film;

-- 3. Count how many films have a title length greater than 20 characters.
Select *
From film
Where Length(title) > 20;

-- 4. For each first letter of an actor’s first name, calculate the average length of their last names.
Select 
	Left(first_name, 1) as First_Letter,
	Avg(Length(last_name)) as Avg_lastname_Length
From actor
Group By Left(first_name, 1);

-- 5. For each store, count the number of customers after converting their full names (first name + last name) to uppercase.
Select
	store_id,
	Count(Upper(Concat(first_name, ' ', last_name))) as Upper_Full_Name
From customer
Group By store_id;

-- 6. For each rating category, count how many films contain the word “ACE” anywhere in the title.
Select 
	Count(title),
    rating
From film
Where title Like '%ACE%'
Group By rating;

-- 7. Extract the email domain (text after ‘@’) for each staff member and count how many staff belong to each domain.
Select 
	Substring(email, Position('@' In email) + 1) as Domain,
    Count(*) as Domain_Count
From staff
Group By domain;

-- 8. Display the first 10 rental records showing rental_id and the rental date formatted as YYYY-MM-DD.
Select
	rental_id,
    Date_format(rental_date, '%Y-%m-%d') as Formatted_Dates
From rental
Limit 10;

-- ==============================================
-- Date + Aggregate 
-- ==============================================
-- 9. Calculate total revenue for each month (using month name) and display the results in descending order of total revenue.
Select 
    Monthname(payment_date) as Month_Name,
	Sum(amount) as Total_Revenue
From payment
Group By Monthname(payment_date)
Order By total_revenue Desc;

-- 10. Count the number of rentals for each weekday and display them in descending order of rental count.
Select
	Dayname(rental_date) as Weekday,
	Count(rental_id) As Total_Rentals   
From rental
Group By Dayname(rental_date)
Order By Total_Rentals Desc;

-- 11. Compare total revenue for Q1 (January–March) versus Q2 (April–June) of 2007.
Select
	Case 
		When Month(payment_date) In (1,2,3) Then 'Q1'
        Else 'Q2'
	End As Quarter,
	Sum(amount)
From payment
Where Year(payment_date) = 2007
	And Month(payment_date) Between 1 And 6
Group By Quarter;

-- 12. For each month, count the number of distinct customers who made at least one rental.
Select 
	Month(rental_date) as Rental_Month,
    Count(Distinct customer_id) as Active_Customers
From rental
Group By Month(rental_date)
Order By Rental_Month;

-- 13. Group films by their release decade and count how many films were released in each decade.
Select
	Floor(release_year / 10)* 10 As Release_Decade,
    Count(*) as Film_Count
From film
Group By release_decade
Order By release_decade;

-- 14. Categorize payments as “Before” or “After” February 15, 2007, and count how many payments fall into each category.
Select
	Case
		When payment_date < '2007-02-15' Then 'Before'
        Else 'After'
	End as Period_Group,
    Count(*) as Payment_Count
From payment
Group By period_group;

-- 15. Identify the top three busiest rental dates based on the number of rentals per day.
Select
	Date(rental_date) as Rental_Day,
    Count(rental_id) as Total_Rentals
From rental
Group By Date(rental_date)
Order By total_rentals Desc
Limit 3;








