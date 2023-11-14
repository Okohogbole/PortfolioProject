
--This project examines and analyses data covering a one year period (january 2015 - December 2015) of Pizza Sales from a Pizza sho.
-- The objective here is to answer certain critical business questions and present them in an interactive dashboard in Tableau to the owner.
-- The Key business Questions in need of answers by the owner falls into 5 KPI's and 11 trend charts;
--Total revenue
--Average Order Value
--Total Pizzas Sold
--Total Orders
--Average Number of Pizzas Per Order
--Hourly trend for Pizzas Sold
--Weekly Trend for Total Orders
--Percentage of sales by pizza category
-- Percentage of sales by pizza size 
--Total Pizzas Sold by pizza category
--Top 5 best sellers by Revenue, total quantity and total orders
--Bottom 5 best sellers by Revenue, total quantity and total orders


SELECT *
FROM [dbo].[Sales]

-- Calculate our KPI's

-- Total revenue, total of sales by price
SELECT ROUND(SUM(total_price),0) as Total_Revenue
FROM [dbo].[Sales]

-- Average Order Value, the average amount spent per order
SELECT (SUM(total_price))/(SELECT COUNT(DISTINCT(order_id))) as Average_Order_Value
FROM [dbo].[Sales]

--Total Pizzas Sold
SELECT SUM(quantity) as Total_Pizzas_Sold
FROM [dbo].[Sales]

--Total Orders
SELECT COUNT(DISTINCT(order_id)) as Total_Orders
FROM [dbo].[Sales]

--Average Number of Pizzas Per Order
SELECT CAST(CAST(SUM(quantity) as decimal (10,2))/ CAST(COUNT(DISTINCT(order_id)) as decimal (10,2)) as decimal (10,2)) as Average_Number_Pizzas_Per_Order
FROM [dbo].[Sales]

--Now for our charts 

-- Hourly trend for Pizzas Sold

SELECT DATEPART(HOUR,order_time) AS Order_Hour, SUM(quantity) AS Total_Puzzas_Sold
FROM [dbo].[Sales]
GROUP BY DATEPART(HOUR,order_time)
ORDER BY DATEPART(HOUR,order_time) 

-- Weekly Trend for Total Orders
SELECT DATEPART(ISO_WEEK,order_date) AS Week_Num,YEAR(order_date) AS Order_Year,
COUNT(DISTINCT order_id) AS Total_Orders
FROM [dbo].[Sales]
GROUP BY DATEPART(ISO_WEEK,order_date),YEAR(order_date)
ORDER BY DATEPART(ISO_WEEK,order_date),YEAR(order_date)

--Percentage of sales by pizza category
SELECT DISTINCT pizza_category AS Pizza_Category,SUM(total_price) AS Total_Sales, 
(SUM(total_price)/ (SELECT (SUM(total_price)) FROM [dbo].[Sales]))*100 AS Total_Sales_Percentage
FROM [dbo].[Sales]
GROUP BY pizza_category
ORDER BY pizza_category

--SELECT DISTINCT pizza_category AS Pizza_Category,SUM(total_price) AS Total_Sales,
--(SUM(total_price)/ (SELECT (SUM(total_price)) FROM [dbo].[Sales] WHERE MONTH(order_date) = 1))*100 AS Total_Sales_Percentage 
--FROM [dbo].[Sales]
--WHERE MONTH(order_date) = 1
--GROUP BY pizza_category
--ORDER BY pizza_category

-- Percentage of sales by pizza size  
SELECT DISTINCT pizza_size,CAST(SUM(total_price) AS decimal(10,2)) AS Total_Sales,
CAST((SUM(total_price)/ (SELECT (SUM(total_price)) FROM [dbo].[Sales]))*100 AS decimal(10,2)) AS Percentage_Sales
FROM [dbo].[Sales]
GROUP BY pizza_size
ORDER BY pizza_size

--SELECT DISTINCT pizza_size,CAST(SUM(total_price) AS decimal(10,2)) AS Total_Sales,
--CAST((SUM(total_price)/ (SELECT (SUM(total_price)) 
--FROM [dbo].[Sales] WHERE DATEPART(quarter,order_date)=1))*100 AS decimal(10,2)) AS Percentage_Sales
--FROM [dbo].[Sales]
--WHERE DATEPART(quarter,order_date)=1
--GROUP BY pizza_size
--ORDER BY pizza_size

--Total Pizzas Sold by pizza category
SELECT  DISTINCT pizza_category, SUM(quantity) as Total_Pizzas_Sold
FROM [dbo].[Sales]
GROUP BY pizza_category
ORDER BY pizza_category

--Top 5 best sellers by Revenue, total quantity and total orders

--Top 5 best sellers by Revenue
SELECT DISTINCT TOP 5 pizza_name,
SUM(total_price) AS Total_Revenue
FROM [dbo].[Sales]
GROUP BY pizza_name
ORDER BY Total_Revenue DESC

--Top 5 best sellers by total quantity
SELECT DISTINCT TOP 5 pizza_name,
SUM(quantity) as Total_Quantity
FROM [dbo].[Sales]
GROUP BY pizza_name
ORDER BY Total_Quantity DESC

--Top 5 best sellers by total orders
SELECT DISTINCT TOP 5 pizza_name,
COUNT(DISTINCT(order_id)) as Total_Orders
FROM [dbo].[Sales]
GROUP BY pizza_name
ORDER BY Total_Orders DESC

--Bottom 5 best sellers by Revenue, total quantity and total orders

--Bottom 5 sellers by Revenue
SELECT DISTINCT TOP 5 pizza_name,
SUM(total_price) AS Total_Revenue
FROM [dbo].[Sales]
GROUP BY pizza_name
ORDER BY Total_Revenue ASC

--Bottom 5 sellers by total quantity
SELECT DISTINCT TOP 5 pizza_name,
SUM(quantity) as Total_Quantity
FROM [dbo].[Sales]
GROUP BY pizza_name
ORDER BY Total_Quantity ASC

--Bottom 5 sellers by total orders
SELECT DISTINCT TOP 5 pizza_name,
COUNT(DISTINCT(order_id)) as Total_Orders
FROM [dbo].[Sales]
GROUP BY pizza_name
ORDER BY Total_Orders ASC
