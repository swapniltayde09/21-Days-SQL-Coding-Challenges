-- ===============================================
-- Day 16: Database Design + Constraints + Analytics
-- ===============================================
-- 1. Create the database and students table
Create Database student_db;

Use student_db;

Create Table students (
	student_id Int Primary Key Auto_Increment,
    first_name Varchar(50) Not Null,
    last_name Varchar(50),
    email Varchar(100) Unique,
    enrollment_date Date
);

-- 2. Create the courses table
Create Table courses (
	course_id Int Primary Key Auto_Increment,
    course_name Varchar(100) Not Null,
    credits Int Check (credits Between 1 and 6)
);

-- 3. Create the teachers table
Create Table teachers (
	teachers_id Int Primary Key Auto_Increment,
    teacher_name Varchar(100) Not Null,
    subject Varchar(50)
);

-- 4. Create the enrollments table
Create Table enrollments (
	enrollment_id Int Primary Key Auto_increment,
    student_id Int,
    course_id Int,
    grade Char(2),
    enrolled_date date
);

-- 5. Add foreign keys to enrollments
Alter Table enrollments
Add Constraint fk_student
Foreign Key (student_id)
References students(student_id)
On Delete Cascade;

Alter Table enrollments
Add Constraint fk_course
Foreign Key (course_id)
References courses(course_id);

-- 6. Create indexes for faster queries
Create Index idx_student_email
On students(email);

Create Index idx_enroll_grade
On enrollments(grade);

-- 7. Insert sample student data
Insert Into students (first_name, last_name, email, enrollment_date)
Values
('Swapnil', 'Tayde', 'swapnil1@gmail.com', '2024-01-10'),
('Rahul','Sharma','rahul@email.com','2024-02-15'),
('Anita','Verma','anita@email.com','2024-03-05'),
('Rohit','Patel','rohit@email.com','2024-03-12'),
('Neha','Singh','neha@email.com','2024-04-02');

-- 8. Insert courses, teachers, and enrollments
Insert Into courses (course_name, credits)
Values
('SQL Mastery', 3), 
('Data Analytics', 4),
('Python Programming', 3);

Insert Into teachers (teacher_name, subject)
Values
('Dr. Mehta','SQL'),
('Prof. Kapoor','Analytics');

Insert Into enrollments (student_id, course_id, grade, enrolled_date)
Values
(1,1,'A','2024-01-15'),
(1,2,'B','2024-02-01'),
(2,1,'C','2024-02-16'),
(2,3,'B','2024-02-20'),
(3,1,'A','2024-03-10'),
(3,2,'B','2024-03-11'),
(4,3,'C','2024-03-20'),
(4,1,'B','2024-03-25'),
(5,2,'A','2024-04-05'),
(5,3,'B','2024-04-06');

-- ========================================
-- Constraints & Validation
-- ========================================
-- 9. Add grade validation constraint
Alter Table enrollments
Add Constraint chk_grade
Check (grade IN ('A', 'B', 'C', 'D', 'F'));

-- 10. Modify students table to enforce last name rule
Alter Table students
Modify column last_name Varchar(50)
Not Null Default 'Unknown';

-- 11. Attempt invalid insert (for testing constraints)
-- Duplicate email:
Insert Into students (first_name, last_name, email, enrollment_date)
Values ('Test','User','swapnil1@email.com','2024-05-01');

-- Invalid Grade:
Insert Into enrollments (student_id, course_id, grade, enrolled_date)
Values
(1,1,'Z','2024-05-01');

-- 12. Add unique constraint on teacher subjects
Alter Table teachers
Add Constraint unique_subject
Unique (subject);

-- Test duplicate subject:
Insert Into teachers (teacher_name, subject)
Values
('Dr. Rao', 'SQL');

-- ========================================
-- Analytics Queries
-- ========================================
-- 13. Students enrolled in two or more courses
Select 
	s.student_id,
    s.first_name,
    s.last_name,
    Count(Distinct e.course_id) as total_courses
From students s
Join enrollments e
On s.student_id = e.student_id
Group By s.student_id, s.first_name, s.last_name
Having count(Distinct e.course_id) >= 2;

-- 14. Average grade per course
Select 
	c.course_name,
    Avg(
		Case grade
			When 'A' Then 4.0
            When 'B' Then 3.0
            When 'C' Then 2.0
            When 'D' Then 1.0
            When 'F' Then 0.0
		End
	) as avg_grade
From courses c
Join enrollments e
On c.course_id = e.course_id
Group By c.course_name;

-- 15. Teachers with no enrolled students
Select
	t.teacher_name,
    t.subject,
    Count(e.enrollment_id) As student_count
From teachers t
Cross Join courses c
Left Join enrollments e On c.course_id = e.course_id
Group By t.teacher_id, t.teacher_name, t.subject
Having Count(e.enrollment_id) = 0
Order By t.teacher_name;

-- All teachers have "no direct students" (The schema doesn't link teacher-enrollment)
-- Instead: Courses with no enrollments (more realistic test)
Select 
	c.course_name, 
    c.credits
From courses c
Left Join enrollments e On c.course_id = e.course_id
Where e.course_id Is Null;




















    


    