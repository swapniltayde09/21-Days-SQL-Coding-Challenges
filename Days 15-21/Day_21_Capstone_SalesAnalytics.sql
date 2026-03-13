-- ==============================================
-- Day 21 — Sales Analytics Platform (Capstone)
-- ==============================================
-- 1. Create database
Create Database sales_analytics_2026;

Use sales_analytics_2026;

-- 2. Customers Table
Create Table customers (
	customer_id Int Primary Key Auto_Increment,
    name Varchar(100),
    email Varchar(100),
    phone Varchar(20),
    city Varchar(50),
    join_date Date,
    loyalty_tier enum('Bronze', 'Silver', 'Gold'),
    Unique (email, city)
);

-- 3. Products table
Create Table products (
	product_id Int Primary Key Auto_increment,
    product_name Varchar(150),
    category Varchar(50),
    price Decimal(10, 2),
    cost_price Decimal(10, 2),
    stock Int,
    supplier Varchar(100)
);

-- 4. Orders table
Create Table orders (
	order_id Int Primary Key Auto_increment,
	customer_id Int,
    order_date Date,
    status ENUM('Pending','Shipped','Delivered','Cancelled'),
    total_amount Decimal(12,2),
    
    Foreign Key (customer_id)
    References customers(customer_id) 
    On Delete Cascade
);

-- 5. Order Items table
Create Table order_items (
	order_item_id Int Primary Key Auto_increment,
    order_id Int,
    product_id Int,
    quantity Int,
    unit_price Decimal(10,2),
    discount Decimal(3,2) Check (discount Between 0 And 0.5),
    
    Foreign Key (order_id)
    References orders(order_id)
    On Delete Cascade,
    
    Foreign Key (product_id)
    References products(product_id)
    On Delete Cascade
);

-- Indexes
Create Index idx_orders_date_customer
On orders(order_date, customer_id);

Create Index idx_products_category
On products(category);

-- 6. Example Data Inserts
-- Example customers
Insert Into customers (name,email,phone,city,join_date,loyalty_tier)
Values
('Swapnil Tayde','swapnil@email.com','9999999991','Mumbai','2025-01-01','Gold'),
('Rahul Sharma','rahul@email.com','9999999992','Delhi','2025-02-01','Silver'),
('Anita Verma','anita@email.com','9999999993','Bangalore','2025-03-01','Bronze');

-- Example products
Insert Into products (product_name,category,price,cost_price,stock,supplier)
Values
('Laptop','Electronics',70000,55000,15,'Dell'),
('Headphones','Electronics',2500,1500,40,'Sony'),
('SQL Book','Books',800,400,50,'Pearson'),
('T-Shirt','Clothing',1200,500,60,'Nike');

-- Example orders
Insert Into orders (customer_id,order_date,status,total_amount)
Values
(1,'2026-03-01','Delivered',72000),
(2,'2026-03-03','Delivered',3000),
(3,'2026-03-04','Cancelled',1200);

-- Example order items
Insert Into order_items (order_id,product_id,quantity,unit_price,discount)
Values
(1,1,1,70000,0.05),
(1,2,1,2500,0.00),
(2,2,1,2500,0.10),
(3,4,1,1200,0.00);

-- ======================================
-- Basic Queries
-- ======================================
-- 7. Top 5 customers by revenue
Select 
	c.customer_id,
    c.name,
    Sum(o.total_amount) as total_spent
From customers c
Join orders o
On c.customer_id = o.customer_id
Group By c.customer_id
Order By total_spent Desc	
Limit 5;

-- 8. Low stock products
Select *
From products
Where stock < 10;

-- 9. Cancelled Orders 
Select * 
From orders
Where status = 'Cancelled';

-- ================================
-- Joins and Aggregations
-- ================================
-- 10. Category profit
Select 
	p.category,
    Sum((oi.unit_price - p.cost_price) * oi.quantity) as profit
From order_items oi
Join products p
	On oi.product_id = p.product_id
Group By p.category;

-- 11. City-wise average order value
Select
	c.city,
    Avg(o.total_amount) as avg_order_value
From customers c
Join orders o
	On c.customer_id = o.customer_id
Group By c.city;

-- 12. Weekly sales trend
Select 
	Week(order_date) as week_number,
    Sum(total_amount) as weekly_sales
From orders
Group By Week(order_date)
Order By week_number;

-- ================================
-- Window Functions
-- ================================
-- 14. Customer revenue ranking
Select 
	customer_id,
    Sum(total_amount) as total_spent,
    Rank() Over (order By Sum(total_amount) Desc) as revenue_rank
From orders
Group By customer_id;

-- 15. Running total sales
Select 
	order_date,
    Sum(total_amount) Over (
		Order By order_date
	) as running_sales
From orders;

-- 16. Month-over-month growth
Select 
	Date_format(order_date, '%Y-%m') as month,
    Sum(total_amount) as revenue,
    Sum(total_amount) -
		Lag(Sum(total_amount)) Over (Order By Date_Format(order_date, '%Y-%m')) as mom_growth
From orders
Group By month;

-- 17. Top 3 products per category
Select *
	From (
		Select 
			p.product_name,
            p.category,
            Sum(oi.quantity) as total_sales,
            Rank() Over (
				Partition By p.category
                Order By Sum(oi.quantity) Desc
                ) as rank_in_category
			From order_items oi
            Join products p
				On oi.product_id = p.product_id
			Group By p.product_name, p.category
		) ranked
	Where rank_in_category <= 3;

-- =====================================
-- CTE + Subqueries
-- =====================================
-- 18. Customers spending above average
With customer_spend As (
	Select 
		customer_id,
        Sum(total_amount) as spend
	From orders
    Group By customer_id
    )
    
    Select *
    From customer_spend
    Where spend > (
		Select Avg(spend) From customer_spend
	);

-- 19. Repeat buyers (>3 orders)
Select 
	customer_id,
    Count(order_Id) as order_count
From orders
Group By customer_id
Having Count(order_id) > 3;

-- 20. Products never ordered
Select *
From products p
Where Not Exists (
	Select 1
    From order_items oi
    Where oi.product_id = p.product_id
);

-- ===================================
-- Performance Queries
-- ===================================
-- 21. City sales performance
Explain
Select 
	c.city,
    Sum(o.total_amount)
From customers c
Join orders o
	On c.customer_id = o.customer_id
Group By c.city;

-- Add Index
Create Index idx_customer_city
On customers(city);

-- 22. Pagination for top products
Select * 
From products
Order By price Desc
Limit 10 Offset 20;

-- 23. Cross month comparison
Select
	Date_format(order_date, '%Y-%m') as month,
    Sum(total_amount) as revenue
From orders
Group By month;

-- =============================
-- Advanced Analytics
-- =============================
-- 24. Dashboard pivot (status by week)
Select 
	Week(order_date) as week,
    Sum(Case When status='Pending' Then 1 Else 0 End) as pending_orders,
    Sum(Case When status='Delivered' Then 1 Else 0 End) as delivered_orders,
    Sum(Case When status='Cancelled' Then 1 Else 0 End)  as cancelled_orders
From orders
Group By Week(order_date);

-- 25. Detect anomalies
Select * 
From orders
Where total_amount >
	(Select 
		Avg(total_amount) + 3 * Stddev(total_amount)
	From orders
    );

-- 26. Recent order audit
Select * 
From orders
Order By order_date Desc
Limit 10;

-- 27. Bonus: Production Features
-- Trigger: Update stock after order
Delimiter $$
Create Trigger update_stock_after_order
After Insert On order_items
For Each Row
Begin

Update products
Set stock = stock - New.quantity
Where product_id = New.product_id;

End$$

DELIMITER ;

-- 28. View: Monthly profit
Create View monthly_profit as
	Select
		Date_format(o.order_date, '%Y-%m') as month,
        Sum((oi.unit_price - p.cost_price) * oi.quantity) as profit
	From order_items oi
    Join products p 	
		On oi.product_id = p.product_id
	Join orders o 
		On oi.order_id = o.order_id
	Group By month;

-- 29. Stored Procedure: Sales Report
DELIMITER $$

Create Procedure GetSalesReport(in report_year Int)

Begin

Select
	Month(order_date) as month,
    Sum(total_amount) as monthly_sales
From orders
Where Year(order_date) = report_year
Group By Month(order_date);

End$$

DELIMITER ;





















