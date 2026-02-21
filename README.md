Customer Shopping Behavior Analysis
📌 Overview
This project analyzes customer shopping behavior using transactional data from 3,900 purchases across multiple product categories.
The objective is to uncover insights into:
Customer spending patterns
Revenue distribution
Subscription impact
Product performance
Discount effectiveness
Customer segmentation
The project combines Python, SQL, and Power BI to deliver end-to-end business insights — from raw data to executive-level dashboard reporting.
📊 Dataset
Rows: 3,900
Columns: 18
Key Features
Customer Demographics
Age
Gender
Location
Subscription Status
Purchase Details
Item Purchased
Category
Purchase Amount
Season
Size
Color
Shopping Behavior
Discount Applied
Promo Code Used
Previous Purchases
Frequency of Purchases
Review Rating
Shipping Type
Missing Data
37 missing values in the review_rating column (handled during preprocessing).

Tools & Technologies
Python (Pandas, NumPy, Matplotlib/Seaborn)
SQL (PostgreSQL / MySQL / SQL Server)
Power BI
Gamma (for presentation design)

 Project Workflow

1️⃣ Data Loading & Cleaning (Python)
Imported dataset using Pandas
Checked structure using df.info() and df.describe()
Handled missing values in review_rating using median per product category
Renamed columns to snake_case
Created new features:
age_group (age binning)
purchase_frequency_days
Removed redundant column (promo_code_used)
Loaded cleaned dataset into PostgreSQL for SQL-based analysis
2️⃣ Business Analysis Using SQL
Key business questions answered:
Revenue comparison by gender
High-spending customers using discounts
Top 5 products by average rating
Shipping type impact on purchase amount
Subscribers vs Non-subscribers revenue comparison
Discount-dependent products
Customer segmentation (Returning, Loyal)
Top 3 products per category
Repeat buyers and subscription likelihood
Revenue contribution by age group
SQL queries were used to extract structured, business-ready insights from the database.
📊 Power BI Dashboard
An interactive Power BI dashboard was created to visualize:
Revenue distribution
Subscription impact
Customer segments
Age-group performance
Product performance
Discount behavior
The dashboard enables decision-makers to explore insights dynamically.
📈 Key Results
Subscribers generated higher average revenue than non-subscribers.
Repeat customers significantly contributed to total revenue.
Certain products showed high dependency on discounts.
Express shipping customers had higher average purchase amounts.
Specific age groups contributed the majority of revenue.
💡 Business Recommendations
Promote subscription benefits to increase retention
Implement loyalty programs for repeat buyers
Optimize discount strategies to protect margins
Highlight top-rated products in marketing campaigns
Focus targeted campaigns on high-revenue age groups
▶ How to Run This Project
Clone the repository
Install required Python libraries:
Copy code

pip install pandas numpy matplotlib seaborn sqlalchemy psycopg2
Run the Python script / Jupyter Notebook for data cleaning
Connect to PostgreSQL and execute SQL queries
Open the Power BI file to explore the dashboard
