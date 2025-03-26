# Indian-Sales-Analysis
## **1. Project Description**

**📌 Title:** Indian Online Store Sales Analysis

**🎯 Goal:**

- Analyze revenue trends and profit to identify key performance drivers.;
- Conduct a geographical analysis of top cities and regions to understand regional sales patterns;
- Identify the most popular categories and subcategories;
- Identify loss-making subcategories to optimize product offerings.

**📂 Data Source:** https://www.kaggle.com/datasets/benroshan/ecommerce-data?select=Order+Details.csv

**🚀 Final Vizualization:** https://public.tableau.com/app/profile/yevheniia.nechai/viz/IndianSalesAnalysis/Salesandprofitabilityanalysis?publish=yes](https://public.tableau.com/shared/7TWM5S34S?:display_count=n&:origin=viz_share_link

## **2. Data Cleaning using Python**

I am preparing the data before exporting it to PostgreSQL, as the CSV files contain empty rows and incorrect formats, which are easier to clean using Python. I used Python with Visual Studio.

```python
# Import necessary libraries
import numpy as np
import pandas as pd

# Read the List_of_Orders.csv file and set the first column as the index
list_orders = pd.read_csv("C:\\Users\\admin\\Desktop\\Projects\\Second_pet-project\\List_of_Orders.csv", index_col = 0)

# Display the first 5 rows of the dataset
print(list_orders.head())

# Display the entire dataset
print(list_orders)

# Check for any missing values in the dataset and print the sum of missing values for each column
print(list_orders.isnull().sum())

# Drop rows where all values are missing and store the cleaned dataset
list_cleaned = list_orders.dropna(how="all")

# Check again for missing values in the cleaned dataset
print(list_cleaned.isnull().sum())

# Display the cleaned dataset
print(list_cleaned)

# Save the cleaned dataset to a new CSV file
list_cleaned.to_csv("List_orders_cleaned.csv")

# Read the Order_Details.csv file and set the first column as the index
order_datails = pd.read_csv("C:\\Users\\admin\\Desktop\\Projects\\Second_pet-project\\Order_Details.csv", index_col = 0)

# Display the Order_Details dataset
print(order_datails)

# Check for missing values in the Order_Details dataset. There are no missing values, so I just skip it.
print(order_datails.isnull().sum())

# Read the Sales_target.csv file and set the first row as the header
sales = pd.read_csv("C:\\Users\\admin\\Desktop\\Projects\\Second_pet-project\\Sales_target.csv", header = 0)

# Convert the 'Month of Order Date' column to a datetime format
sales['Month of Order Date'] = pd.to_datetime(sales['Month of Order Date'], format='%b-%y')

# Display the Sales_target dataset after converting the date
print(sales)

# Save the Sales_target dataset without the index column
sales.to_csv("Sales_target.csv", index = False)
```

## **3. Data Praparation using PostgreSQL**

**3.1 Connection Data**

I used PostgreSQL to preprocess and structure the datasets in a format that’s more convenient for analysis and visualization in Tableau.

```sql
-- Create the table for storing order information
CREATE TABLE list_of_orders (
    Order_ID TEXT PRIMARY KEY,       -- Unique identifier for each order
    Order_date DATE,                 -- Date when the order was placed
    Customer_name TEXT,              -- Name of the customer
    State TEXT,                      -- State where the order was placed
    City TEXT                        -- City where the order was placed
);

-- Create the table for storing order details
CREATE TABLE order_details (
    Order_ID TEXT,                   -- Order ID, used to link to the list_of_orders table
    Amount NUMERIC,                  -- Amount of money for the order
    Profit NUMERIC,                  -- Profit made from the order
    Quantity INT,                    -- Quantity of items ordered
    Category TEXT,                   -- Category of the ordered product
    Sub_category TEXT                -- Sub-category of the ordered product
);

-- Create the table for storing sales targets
CREATE TABLE sales_target (
    Date_of_order DATE,              -- Date when the target is set
    Category TEXT,                   -- Category of the target sales
    Target NUMERIC                   -- Sales target value for the specified category
);
```
Then I connected cvs files to the Database the menue options.
After that, I reviewed the tables to check for errors or inconsistencies. The data is ready for further work.
```sql
-- Select all columns and rows from the 'list_of_orders' table
SELECT *
FROM list_of_orders;

-- Select all columns and rows from the 'order_details' table
SELECT *
FROM order_details;

-- Select all columns and rows from the 'sales_target' table
SELECT *
FROM sales_target;

-- Select distinct sub-categories from the 'order_details' table
-- This will return unique sub-categories without duplicates
-- The result will be ordered by the sub_category column
SELECT DISTINCT(order_details.sub_category)
FROM order_details
ORDER BY sub_category;
```

**3.2 Praparation Data**

Create a new table that combines relevant columns into one table for easier analysis in Tableau.

```sql
-- Creating table 'orders' by (inner) joining 'list_of_orders' and 'order_details'  
CREATE TABLE orders AS  
SELECT lo.*, od.amount, od.profit, od.quantity, od.category, od.sub_category  
FROM list_of_orders AS lo  
JOIN order_details AS od  
ON lo.order_id = od.order_id;  
```
The resulting table contains 1500 rows.

```sql
-- Renaming the 'amount' column to 'price' for better clarity  
ALTER TABLE orders  
RENAME COLUMN amount TO price;  

-- Adding new columns for cost and revenue calculations per sub-category  
ALTER TABLE orders  
ADD COLUMN subcat_cost NUMERIC,  
ADD COLUMN subcat_revenue NUMERIC,  
ADD COLUMN cost_per_unit NUMERIC;

-- Calculating cost per unit for each sub-category  
UPDATE orders  
SET cost_per_unit = price - (profit / quantity);  

-- Rounding cost per unit to 2 decimal places for better readability  
UPDATE orders  
SET cost_per_unit = ROUND(cost_per_unit, 2);  

-- Calculating total cost per sub-category  
UPDATE orders  
SET subcat_cost = cost_per_unit * quantity;  

-- Calculating total revenue per sub-category  
UPDATE orders  
SET subcat_revenue = price * quantity;  
```

After starting work in Tableau, I noticed an error in one of the locations. So, I returned to PostgreSQL and corrected it.

```sql
-- Correcting the state name for Hyderabad from an incorrect value to 'Telangana'  
UPDATE orders  
SET state = 'Telangana'  
WHERE city = 'Hyderabad';  
```
Data is properly structured and cleaned before further analysis in Tableau. 

## **4. Analysis and Visualization in Tableau**

After preparing the data, I connected orders and sales_target tables to Tableau Public via Text File format.

***Dashboard 1: Executive Summary***

This dashboard provides key business metrics and financial insights.

![image](https://github.com/user-attachments/assets/b6b7b279-4f51-4f38-9d82-a56531e5bcc4)

Sheets:
- Key Performance Indicators (KPIs):
  - Total Revenue: SUM([subcat_revenue])
  - Total Profit: SUM([profit])
  - Return on Sales (ROS %): SUM([profit]) / SUM([subcat_revenue]) (formatted as a percentage)
  - Average Order Value: SUM([subcat_revenue]) / COUNTD([order_id])
  - Total Number of Orders: COUNTD([order_id])
  - Unique Customers: COUNTD([customer_name])
- Revenue Trend by Month (Line Chart):

- Profit Trend by Month (Bar Chart):
- Sales Map by State (Profit Heatmap):

***Dashboard 2: Geographic Sales Analysis***

This dashboard focuses on sales distribution across different states and cities.

There I implemented ranking calculations using Calculated Fields and Parameter.
Used Dashboard Actions to enhance interactivity.

![image](https://github.com/user-attachments/assets/d245b1cb-f8bf-46db-9a69-fadc6dc0da5e)

Sheets:
- Sales Map by State (Profit Heatmap)

- Top 10 States by Order Volume (Horizontal Bar Chart)

- Top 10 Cities by Order Volume (Horizontal Bar Chart)
Implemented ranking calculations using Calculated Fields.
Used Dashboard Actions to enhance interactivity.

***Dashboard 3: Product Analysis***

This dashboard analyzes sales and profitability at the category and sub-category levels.

![image](https://github.com/user-attachments/assets/35f23efd-3912-45e3-868d-695c48312904)

Sheets:
- Category Share in Total Profit (Pie Chart)

- Top 5 Subcategories by Sales (Bar Chart)

- Units Sold vs. Profitability (Scatter Plot)

## **Key Takeaways from the Project 🚀:**
- Successfully cleaned and transformed raw sales data using Python and PostgreSQL before visualization in Tableau.

- Used Python for initial data preprocessing, handling missing values, and correcting data inconsistencies.

- Applied PostgreSQL for data transformation, merging tables, and calculating key financial metrics.

- Integrated calculated fields and interactivity in Tableau to enhance data exploration.

- Built a structured sales analysis, covering revenue trends, geographic performance, and product-level insights.

This project showcases my ability to clean, transform, and analyze data using Python, PostgreSQL, and Tableau, enabling data-driven decision-making.
