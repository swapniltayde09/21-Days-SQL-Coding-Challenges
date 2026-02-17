-- =================================================
-- Day 8: String & Date Functions Mastery
-- =================================================

Use sakila;

-- ==================================
-- String Functions
-- ==================================

-- 1. Retrieve each actor’s ID and display their full name by combining first_name and last_name into a single column.
Select 
	actor_id,
    Concat(first_name, ' ', last_name) as Full_Name
From actor;

-- 2. Display all film titles in uppercase.
Select Upper(title) as title_upper
From film;

-- 3. Display all film titles in lowercase.
Select Lower(title) as title_lower
From film;

-- 4. Show the first 10 characters of each film title.
Select Left(title, 10)
From film;

-- 5. Show the last 5 characters of each film title.
Select Right(title, 5) 
From film;

-- 6. Retrieve the last names of actors whose last name starts with the letter “A”.
Select last_name
From actor
Where last_name Like 'A%';

-- 7. Retrieve film titles that contain the word “ACE” anywhere in the title.
Select title
From film
Where title = '%ACE%';

-- 8. Retrieve email addresses of staff members whose email ends with “store1.com”.
Select email 
From staff
Where email = '%store1.com';

-- ======================================
-- Date Functions (Q9-15)
-- ======================================
-- 9. Retrieve all rentals that occurred in the year 2006.
Select 
	rental_id,
    rental_date	
From rental
Where Year(rental_date) = 2006;

-- 10. Retrieve all payments made in May 2005.
Select
	payment_id,
    amount
From payment
Where Month(payment_date) = 5 And Year(payment_date)= 2005;

-- 11. Display the month name for each payment date.
Select Monthname(payment_date)
From payment;

-- 12. Display the day of the week for each rental date.
Select Dayname(rental_date)
From rental;

-- 13. Retrieve all payments made before February 15, 2007.
Select payment_id, amount
From payment
Where payment_date < '2007-02-15';

-- 14. Retrieve all rentals that occurred within the last 30 days from the date ‘2007-05-24’.
Select rental_id, rental_date
From rental
Where rental_date >= Date_sub('2007-05-24', Interval 30 Day);

-- 15. Count the number of payments made in Q1 (January, February, March) of 2007.
Select Count(*)
From payment
Where Month(payment_date) In (1,2,3) And Year(payment_date)=2007;