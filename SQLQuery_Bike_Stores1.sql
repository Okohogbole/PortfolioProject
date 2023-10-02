---ABOUT
---In this guided project courtesy of Data Guru, using SQL queries, I Created a Dataset comprising of several tables containing data from an imaginary bike share business.
---The task here is to extract relevant data from the various tables pertaining business performance, format the data to requirements and then extract the final results for 
---into Excel and Tableau for further Analysis and visiualization.
--- The objective of the project is to utilize key performance metrics to Analyze and create visualizations to guide business decision making by Executives.

---View the tables contining the datasets
SELECT *
FROM [production].[categories]

SELECT *
FROM [production].[products]

SELECT *
FROM [production].[brands]

SELECT *
FROM [production].[stocks]

SELECT *
FROM [sales].[customers]

SELECT *
FROM [sales].[orders]

SELECT *
FROM [sales].[order_items]

SELECT *
FROM [sales].[stores]

SELECT *
FROM [sales].[staffs]


--- Extract specific data needed and perform calculations to further explore the data
--- The query pulls out data from several tables using JOINs to identify orders , customer detils , product details (Name,quantity, category) 
--- and revenue as well as store and sales rep details.
  
SELECT
ord.Order_id,
CONCAT(cus.first_name,' ',cus.last_name) Customer_Name,
cus.City,
cus.State,
ord.Order_date,
SUM(ite.quantity) AS 'Total Units',---for total sales 
SUM(ite.quantity * ite.list_price) AS 'Revenue',---revenue generated
pro.product_name,
cat.category_name,
sto.store_name,
CONCAT(staff.first_name,' ',staff.last_name) AS 'Rep_Name'
FROM Sales.Orders ord
JOIN Sales.Customers cus
ON  ord.Customer_id = cus.Customer_id
JOIN Sales.Order_items ite
ON ord.order_id = ite.order_id
JOIN Production.Products pro
ON ite.product_id = pro.product_id
JOIN production.categories cat
ON pro.category_id = cat.category_id
JOIN sales.stores sto
ON ord.store_id = sto.store_id
JOIN sales.staffs staff
ON ord.staff_id = staff.staff_id
GROUP BY ---since we are using aggregate functions
ord.Order_id,
CONCAT(cus.first_name,' ',cus.last_name),
cus.City,
cus.State,
ord.Order_date,
pro.product_name,
cat.category_name,
sto.store_name,
CONCAT(staff.first_name,' ',staff.last_name)
