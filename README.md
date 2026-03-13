# 21 Days SQL Coding Challenges
21-Days SQL Challenge using Sakila database (pre-installed in MySQL Workbench). 
Daily SQL practice questions adapted from LinkedIn interview prep resources (500-SQL-Questions, 50-MAANG, 300-MNC, 800-SQL). Day-by-day solutions with explanations, progressing from SELECT/WHERE basics to advanced window functions/CTEs. 
Perfect for data analyst interviews practice.
Daily 10~15 questions

[![SQL](https://img.shields.io/badge/SQL-blue?style=flat&logo=mysql&logoColor=white)](https://github.com/anuraghazra/github-readme-stats)

## Weekly Progress
### **Week 1: SQL Foundations (Sakila DB)**
- Day 1: Basic SELECT practice
- Day 2: Advanced_WHERE
- Day 3: WHERE + LIMIT + CASE 
- Day 4: LIMIT Practice + Subquery Filters + Prep for Aggregates
- Day 5: GROUP BY + HAVING + Aggregate Mastery
- Day 6: JOIN Practice (All Types)
- Day 7: JOIN + GROUP BY + HAVING

### **Week 2: Analytics Practice**
- Day 8: String & Date Functions Practice
- Day 9: Mixed Aggregates
- Day 10: Data Modifications + CASE + NULL Handling
- Day 11: Update/ Delete 
- Day 12: Data Cleaning (NULLs, duplicates, data quality)
- Day 13: Window Functions + Advanced Data Cleaning 
- Day 14: Window LAG/LEAD + Running Totals

  
### **Week 3: Production Engineering (5x Real DBs)**
- Day 15: CTEs + Subqueries + Window combinations
- Day 16: Database Design + Constraints + Analytics
- Day 17: Ecommerce Database Design + Performance Queries
- Day 18: Finance Tracker (Constraints + Triggers + Analytics)
- Day 19: Mixed Review Project – Log Analyzer
- Day 20: SQL Performance Tuning Project
- Day 21: Sales Analytics Platform (Capstone Project)

🏆 Day 21 Capstone Highlights
1️⃣ Mumbai Revenue: +25% MoM [LAG screenshot]
2️⃣ Profit Leader: Electronics ₹80k [Q10 output]  
3️⃣ Top Customer: Swapnil #1 Gold ₹72k [RANK]
4️⃣ Auto Stock: TRIGGER 15→13 [test]
5️⃣ Dashboard: monthly_profit VIEW [output]
6️⃣ API Ready: GetSalesReport(2026) PROC

## 🛠️ **Tech Stack Unlocked**
 120+ SQL queries (Sakila + 5x custom DBs)
✅ DDL: 3NF schemas, CHECK/UNIQUE/CASCADE
✅ Analytics: Windows/CTEs → Exec dashboards
✅ Production: Triggers/Views/Stored Procs
✅ Performance: EXPLAIN → 90% index hits, prefix indexes

## 📁 **File Structure**
├── Week1/ # Sakila daily grind (Days 1-12)
├── Projects/ # Production DBs (Days 16-21)
│ ├── Day16_StudentDB.sql
│ ├── Day17_EcommerceDB.sql
│ ├── Day18_FinanceTracker.sql
│ ├── Day19_LogAnalyzer.sql
│ ├── Day20_PerformanceTuning.sql
│ └── Day21_Capstone_SalesAnalytics.sql ⭐
└── README.md


## 🚀 **Run It**
```bash
# MySQL Workbench
Use sakila;           # Days 1-15
Use sales_analytics_2026;  # Capstone
Call GetSalesReport(2026); # Monthly dashboard!
