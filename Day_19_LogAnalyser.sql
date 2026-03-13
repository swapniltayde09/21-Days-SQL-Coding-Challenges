-- ==============================================
-- Day 19: Mixed Review Project – Log Analyzer
-- ==============================================
-- Schema Design
-- ==============================================
-- 1. Create database and users table
Create Database log_analyzer;

Use log_analyzer;

Create Table users (
	user_id Int Primary Key Auto_Increment,
    username Varchar(50) Unique Not Null,
    role Enum('Admin', 'User', 'Guest')
);

-- 2. Create events table
Create Table events (
	event_id Int Primary Key auto_increment,
    user_id Int,
    ip_address Varchar(50),
    event_type enum('Login', 'Logout', 'Error', 'Query'),
    timestamp Datetime,
    status_code Int Check (status_code Between 100 And 599),
    duration_ms int
);

-- 3. Add foreign key and indexes
Alter Table events
Add Constraint fk_user
Foreign Key (user_id)
References users(user_id);

Create Index idx_event_timestamp
On events(timestamp);

Create Index idx_event_type
On events(event_type);

-- ===========================================
-- 4. Data Population
-- ===========================================
-- Insert users
Insert Into users (username, role)
Values
('swapnil_admin','Admin'),
('Swapnaja','Admin'),
('Anshul','User'),
('Parag','User'),
('Gaurav','User'),
('Yogesh','Guest');

-- Insert sample events (March 2026)
Insert Into events
(user_id,ip_address,event_type,timestamp,status_code,duration_ms)
Values
(1,'192.168.1.1','Login','2026-03-01 09:00:00',200,NULL),
(1,'192.168.1.1','Query','2026-03-01 09:02:00',200,150),
(2,'192.168.1.2','Login','2026-03-01 09:05:00',200,NULL),
(3,'192.168.1.3','Login','2026-03-01 09:06:00',401,NULL),
(3,'192.168.1.3','Login','2026-03-01 09:07:00',401,NULL),
(3,'192.168.1.3','Login','2026-03-01 09:08:00',401,NULL),
(4,'192.168.1.4','Query','2026-03-01 10:00:00',200,700),
(4,'192.168.1.4','Query','2026-03-01 10:02:00',200,300),
(5,'192.168.1.5','Error','2026-03-01 10:05:00',500,NULL),
(5,'192.168.1.5','Error','2026-03-01 10:06:00',500,NULL),
(1,'192.168.1.1','Query','2026-03-02 09:00:00',200,200),
(2,'192.168.1.2','Query','2026-03-02 09:05:00',200,450),
(3,'192.168.1.3','Error','2026-03-02 09:07:00',404,NULL),
(4,'192.168.1.4','Query','2026-03-02 10:00:00',200,650),
(5,'192.168.1.5','Login','2026-03-02 11:00:00',200,NULL),
(6,'192.168.1.6','Login','2026-03-02 12:00:00',200,NULL),
(1,'192.168.1.1','Logout','2026-03-02 13:00:00',200,NULL),
(2,'192.168.1.2','Logout','2026-03-02 13:05:00',200,NULL),
(3,'192.168.1.3','Query','2026-03-02 14:00:00',200,500),
(4,'192.168.1.4','Error','2026-03-02 14:30:00',500,NULL),
(5,'192.168.1.5','Query','2026-03-02 15:00:00',200,900),
(1,'192.168.1.1','Query','2026-03-03 09:00:00',200,120),
(2,'192.168.1.2','Error','2026-03-03 09:10:00',500,NULL),
(3,'192.168.1.3','Query','2026-03-03 09:20:00',200,400),
(4,'192.168.1.4','Login','2026-03-03 09:30:00',200,NULL);

-- ======================================================
-- Mixed Analytics
-- =====================================================
-- 5. Detect failed login attempts per IP
Select 
	ip_address,
    Count(*) as Failed_Attempts
From events
Where event_type = 'Login'
And status_code >= 400
Group By ip_address
Having Count(*) > 2;

-- 6. User activity grouped by role
Select
	u.role,
    Count(*) as total_events
From users u
Join events e
	On u.user_id = e.user_id
Group By u.role
Order By total_events Desc;

-- 7. Hourly event distribution
Select
	Hour(timestamp) as event_hour,
    Count(*) as event_count
From events
Group By Hour(timestamp)
Order By event_hour;

-- 8. Top IPs generating errors
Select
	ip_address,
    Count(*) as error_count
From events
Where event_type = 'Error'
Group By ip_address
Order By error_count Desc
Limit 5;

-- 9. Queries executed by admins
Select 
	u.username,
    e.timestamp,
    e.duration_ms
From events e
Join users u
	On e.user_id = u.user_id
Where e.event_type = 'Query'
And u.role = 'Admin';

-- 10. Detect consecutive failures
Select 
	ip_address,
    timestamp,
    status_code,
    Lag(status_code) Over (
		Partition By ip_address
        Order By timestamp
	) as previous_status
From events
Where status_code >= 400;

-- 11. Event sequence per IP
Select 
	Week(timestamp) as week_number,
    Count(*) as total_events,
    Avg(status_code) as avg_status
From events
Group By Week(timestamp);

--  12. Weekly event statistics
Select 
	Week(timestamp) as week_number,
    Count(*) as total_events,
    Avg(status_code) as avg_status
From events
Group By Week(timestamp);

-- 13. Slowest queries
Select 
	user_id,
    ip_address,
    duration_ms
From events
Where event_type = 'Query'
Order By duration_ms Desc
Limit 5;

-- 14. Users with high error rate (>10%)
Select
	u.username,
    Sum(Case When e.status_code >= 400 Then 1 Else 0 End) / 
    Count(*) as error_rate
From users u
Join events e
	On u.user_id = e.user_id
Group By u.username
Having error_rate > 0.10;

-- 15. Daily event dashboard summary
Select
	Date(timestamp) as event_date,
    Sum(Case When event_type= 'Login' Then 1 Else 0 End) as logins,
    Sum(Case When event_type= 'Logout' Then 1 Else 0 End) as logouts,
    Sum(Case When event_type= 'Error' Then 1 Else 0 End) as errors,
    Sum(Case When event_type= 'Query' Then 1 Else 0 End) as queries
From events
Group By Date(timestamp)
Order By event_date;



























