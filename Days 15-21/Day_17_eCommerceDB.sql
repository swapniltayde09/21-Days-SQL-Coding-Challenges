-- =================================================================
-- Day 17 — Ecommerce Database Design + Performance Queries
-- =================================================================
-- Schema Design
-- =================================================================
-- 1. Create the database and customers table
Create Database ecommerce_db;

Use ecommerce_db;

Create Table customers (
	customer_id Int Primary Key auto_increment,
    first_name Varchar(50) Not Null,
    last_name Varchar(50) Not Null,
    email Varchar(100) Unique,
    join_date Date,
    city Varchar(50)
);

-- 2. Create the products table 
Create Table products (
	product_id Int Primary Key Auto_increment,
    product_name Varchar(100) Not Null,
    category Varchar(50),
    price Decimal(10,2) Check (price > 0),
    stock Int Default 0
);

-- 3. Create the orders table
Create Table orders (
	order_id Int Primary Key auto_increment,
    customer_id Int,
    order_date Date,
    total_amount Decimal(10,2)
);

-- 4. Create the order_items table
Create Table order_items (
	order_item_id Int Primary Key Auto_Increment,
    order_id Int,
    product_id Int,
    quantity Int Check (quantity > 0),
    unit_price Decimal(10,2)
);

-- 5. Add foreign key relationships
Alter Table orders
Add Constraint fk_customer
Foreign Key (customer_id)
References customers(customer_id);

Alter Table order_items
Add Constraint fk_order
Foreign Key (order_id)
References orders(order_id);

Alter Table order_items
Add Constraint fk_product
Foreign Key (product_id)
References products(product_id);

-- 6. Create indexes to improve performance
Create Index idx_customer_email
On customers(email);

Create Index idx_order_date
On orders(order_date);

Create Index idx_product_category
On products(category);

-- 7. Insert sample data
-- Insert customers
Insert Into customers (first_name,last_name,email,join_date,city)
Values
('Amit','Sharma','amit@email.com','2024-01-01','Mumbai'),
('Neha','Verma','neha@email.com','2024-02-10','Delhi'),
('Rohit','Patel','rohit@email.com','2024-03-15','Pune'),
('Anita','Singh','anita@email.com','2024-03-20','Mumbai'),
('Rahul','Mehta','rahul@email.com','2024-04-01','Bangalore');

-- Insert products
Insert Into products (product_name,category,price,stock)
Values
('Laptop','Electronics',50000,15),
('Headphones','Electronics',2000,25),
('Keyboard','Electronics',1500,20),
('SQL Book','Books',800,40),
('Python Book','Books',900,35),
('Data Science Book','Books',1200,30);

-- Insert orders
Insert Into orders (customer_id,order_date,total_amount)
Values
(1,'2024-05-01',15000),
(2,'2024-05-02',4000),
(3,'2024-05-03',2500),
(4,'2024-05-04',5000),
(5,'2024-05-05',6000),
(1,'2024-05-06',3000),
(2,'2024-05-07',2000),
(3,'2024-05-08',1500);

-- Insert order items
Insert Into order_items (order_id,product_id,quantity,unit_price)
Values
(1,1,1,50000),
(1,4,2,800),
(2,2,2,2000),
(2,4,1,800),
(3,3,1,1500),
(3,5,1,900),
(4,1,1,50000),
(4,6,2,1200),
(5,4,3,800),
(5,5,1,900),
(6,2,1,2000),
(6,3,2,1500),
(7,4,2,800),
(8,6,1,1200),
(8,5,1,900);

-- ===========================================
-- Normalization & Constraints
-- ===========================================
-- 8. Add data validation constraints
Alter Table products
Add Constraint chk_stock
Check (stock >= 0);

Alter Table order_items
Add Constraint chk_price
Check (unit_price > 0);

-- 9. Add composite unique constraint
	-- Ensure email and city combination is unique.
Alter Table customers
Add Constraint unique_email_city
Unique (email, city);

	-- Test duplicate
Insert Into customers (first_name,last_name,email,join_date,city)
Values ('Test','User','amit@email.com','2024-05-10','Mumbai');

-- 10. Add default value to orders
Alter Table orders
Modify total_amount Decimal(10,2)
Not Null Default 0.00;

-- 11. Test constraint violations
	-- Invalid Stock:
Insert Into products (product_name, category, price, stock)
Values 
('Invalid Product', 'Electronics', 2000, -5);

	-- Invalid Quantity:
Insert Into order_items (order_id, product_id, quantity, unit_price)
Values
(1,2,-1,2000);

-- ======================================================
-- Performance & Analytics
-- ======================================================
-- 12. Find low-stock products
Explain
Select * 
From products
Where stock < 10;

-- 13. Customer lifetime value
Select 
	c.customer_id,
    c.first_name,
    Sum(oi.quantity * oi.unit_price) as lifetime_value
From customers c
Join orders o
	On c.customer_id = o.customer_id
Join order_items oi
	On o.order_id = oi.order_id
Group By c.customer_id, c.first_name
Having lifetime_value > 10000;

-- 14. Top product categories by revenue
Select 
	p.category,
    Sum(oi.quantity * oi.unit_price) as total_revenue
From products p 
Join order_items oi
	On p.product_id = oi.product_id
Group By p.category
Order By total_revenue Desc
Limit 3;

-- 15. Orders in the last 30 days
Explain
Select *
From orders
Where order_date >= Curdate() - Interval 30 Day;











