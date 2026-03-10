-- ==============================================================
-- Day 18 — Finance Tracker (Constraints + Triggers + Analytics)
-- ==============================================================
-- Core Tables
-- ==============================================================
-- 1. Create the database and accounts table
Create Database finance_tracker;

Use finance_tracker;

Create Table accounts (
	account_id Int Primary Key Auto_increment,
    account_name Varchar(50) Not Null Unique,
    balance Decimal(12,2) Default 0.00 Check (balance >= 0)
);

-- 2. Create the categories table
Create Table categories (
	category_id Int Primary Key Auto_Increment,
    category_name Varchar(50) Not Null Unique,
    type Enum ('Income', 'Expense') Not Null
);

-- 3. Create the transactions table
Create Table transactions (
	transactions_id Int Primary Key Auto_Increment,
    account_id Int,
    category_id Int,
    amount Decimal(10,2) Check (amount <> 0),
    transaction_date Date Not Null,
    description Varchar(200)
);

-- 4. Create the budgets table to track monthly budget for categories.
-- # MySQL does not support YEAR_MONTH, so we store month as DATE.
Create Table budgets (
	budget_id Int Primary Key Auto_increment,
    category_id Int,
    month Date,
    budget_limit Decimal(10,2) Check (budget_limit > 0),
    actual_spent Decimal(10,2) Default 0.00
);

-- 5. Add foreign key relationships
Alter Table transactions 
Add Constraint fk_account
Foreign Key (account_id)
References accounts(account_id);

Alter Table transactions
Add Constraint fk_category
Foreign Key (category_id)
References categories(category_id);

Alter Table budgets
Add Constraint fk_budget_category
Foreign Key (category_id)
References categories(category_id);

-- ======================================
-- Advanced Constraints
-- =====================================
-- 6. Create indexes for performance
Create Index idx_trans_date
On transactions(transaction_date);

Create Index idx_budget_month
On budgets(month);

-- 7. Add composite UNIQUE constraint to ensure only one budget per category per month
Alter table budgets
Add Constraint unique_budget
Unique (category_id, month);

-- 8. Enforce income/expense rule using trigger
	-- Transactions must match the category type:
	-- 1. Income → amount must be positive
	-- 2.Expense → amount must be negative
Delimiter $$

Create Trigger check_transation_type
Before Insert On transactions
For each row 
Begin
	Declare cat_type Varchar(10);
    
	Select type Into cat_type
    From categories
    Where category_id = New.category_id;
	
    If cat_type = 'Income' And New.amount <= 0 Then
		Signal sqlstate '45000'
        Set Message_text = 'Income must be positive';
	End If;
    
    If cat_type = 'Expense' And New.amount >= 0 Then
		Signal SQLstate '45000'
        Set Message_text = 'Expense must be negative';
	End If;
End$$

Delimiter ;

-- Test it
-- Valid: Salary (+10000)
Insert Into transactions (account_id, category_id, amount, transaction_date) 
Values
(1, 1, 10000, '2026-03-01');  -- Succeeds

-- Invalid: Rent (+5000) → "Expense must be negative"
Insert Into transactions (account_id, category_id, amount, transaction_date) 
Values 
(1, 2, 5000, '2026-03-01');  -- BLOCKED!

-- 9. Add default value to description
Alter Table transactions
Modify description Varchar(200)
Default 'General';

-- 10. Test constraint violations
-- Duplicate budget example
Insert Into budgets (category_id,month,budget_limit)
Values
(1,'2026-03-01',20000);

-- Invalid income example
Insert Into transactions (account_id,category_id,amount,transaction_date)
Values
(1,1,-5000,'2026-03-10');

-- ====================================
-- Data Setup & Analytics
-- ====================================
-- 11. Insert sample data
-- Accounts
Insert Into accounts (account_name, balance)
Values
('Savings', 50000),
('Salary Account', 0),
('Groceries Account', 0);

-- Categories
Insert Into categories(category_name, type)
Values
('Salary','Income'),
('Freelance','Income'),
('Rent','Expense'),
('Groceries','Expense'),
('Utilities','Expense');

-- Transactions
Insert Into transactions
(account_id, category_id, amount, transaction_date, description)
Values
(2,1,100000,'2026-03-01','Monthly Salary'),
(1,3,-20000,'2026-03-03','House Rent'),
(3,4,-5000,'2026-03-05','Groceries'),
(3,4,-3000,'2026-03-08','Supermarket'),
(1,5,-2000,'2026-03-10','Electricity'),
(1,5,-1500,'2026-03-12','Internet'),
(2,2,15000,'2026-03-14','Freelance'),
(3,4,-2000,'2026-03-16','Vegetables'),
(1,3,-20000,'2026-03-18','Rent Payment'),
(3,4,-1000,'2026-03-20','Snacks'),
(2,2,10000,'2026-03-25','Side Project'),
(1,5,-1200,'2026-03-27','Water Bill');

-- Budgets
Insert Into budgets (category_id, month, budget_limit)
Values
(3,'2026-03-01',25000),
(4,'2026-03-01',10000),
(5,'2026-03-01',5000);

-- ===========================
-- Finance Analytics Queries
-- ===========================
-- 12. Find over-budget categories
Select 
	c.category_name,
    Sum(Abs(t.amount)) as total_spent,
    b.budget_limit
From transactions t
Join categories c
	On t.category_id = c.category_id
Join budgets b 
	On c.category_id = b.category_id
Where c.type = 'Expense'
Group By c.category_name, b.budget_limit
Having total_spent > b.budget_limit;

-- 13. Calculate monthly net worth per account
Select 
	a.account_name,
    Sum(t.amount) as net_balance
From accounts a
Join transactions t
	On a.account_id = t.account_id
Group By a.account_name;

-- 14. Top expense categories
Select 
	c.category_name,
    Sum(Abs(t.amount)) as total_expense
From transactions t
Join categories c	
	On t.category_id = c.category_id
Where c.type = 'Expense'
Group By c.category_name
Order By total_expense Desc
Limit 3;

-- 15. Year-to-date income vs expense (2026)
Select 
	c.type,
    Sum(t.amount) as total_amount
From transactions t
Join categories c
	On t.category_id = c.category_id
Where Year(t.transaction_date) = 2026
Group By c.type;


































