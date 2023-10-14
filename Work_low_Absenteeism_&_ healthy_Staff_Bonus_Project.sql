
--- A portfolio project courtesy of Absent Data analysing employee data regarding their health and absenteeism 
--- patterns with the view of awarding an annual incentive bonus to staff that meet certain health and low absenteeism criteria.
--- The aim of this query is to identify and extract insightful data that would inform decision making by HR as to what constitutes 'healthy'
--- so as to identify staff to be given this bonus.


--- Data exploration
SELECT *
FROM [dbo].[Absenteeism_at_work]

SELECT *
FROM [dbo].[Reasons]

SELECT *
FROM [dbo].[compensation]

--- max age and min age 
SELECT max(Age), Min(Age)
FROM [dbo].[Absenteeism_at_work]

--- Eduaction levels. much information and context was not given here. i broke the levels down into 3 categories - Basic(1), intermediate(2 and 3), and Advanced (4)
SELECT DISTINCT(Education)
FROM [dbo].[Absenteeism_at_work]

 
--- Create our JOINS for the tables

SELECT * 
FROM  [dbo].[Absenteeism_at_work] ab
LEFT JOIN [dbo].[compensation] co
ON ab.ID = co.ID
LEFT JOIN [dbo].[Reasons] re
ON ab.Reason_for_absence = re.Number;

--- Task 1: to identify "healthy"  staff ( based on drinking, smoking and BMI status) who also have low absenteeism (based on number of hours absent) from the database

SELECT *
FROM [dbo].[Absenteeism_at_work]
WHERE Social_drinker = 0 AND Social_smoker = 0 AND Body_mass_index <25 AND
Absenteeism_time_in_hours <(SELECT AVG(Absenteeism_time_in_hours) FROM [dbo].[Absenteeism_at_work])

--- Task 2: Wage increase/ annual compensation for non-smoers based on a $983,221 Budget
--- first get the number of non smokers , then numbe rof hours worked by those workers over a year (686 workers*5 days*8 hours*52 weeks) = 1,426,880 hours
--- Therefore, the wage increase ( $983,221/1,426,880) = 0.689 cents per hour or $1433 per year

SELECT COUNT(*) as Nonsmokers
FROM [dbo].[Absenteeism_at_work]
WHERE Social_smoker = 0

---Updating this query

SELECT ab.ID,
	   re.Reason,
CASE WHEN [Month_of_absence] = 1 THEN 'January'
	 WHEN [Month_of_absence] = 2 THEN 'February'
	 WHEN [Month_of_absence] = 3 THEN 'March'
	 WHEN [Month_of_absence] = 4 THEN 'April'
	 WHEN [Month_of_absence] = 5 THEN 'May'
	 WHEN [Month_of_absence] = 6 THEN 'June'
	 WHEN [Month_of_absence] = 7 THEN 'July'
	 WHEN [Month_of_absence] = 8 THEN 'August'
	 WHEN [Month_of_absence] = 9 THEN 'September'
	 WHEN [Month_of_absence] = 10 THEN 'October'
	 WHEN [Month_of_absence] = 11 THEN 'November'
	 WHEN [Month_of_absence] = 12 THEN 'December'
	 ELSE 'Unknown' END AS Absentee_Month,
CASE WHEN Month_of_absence IN (12,1,2) THEN 'Winter'
	 WHEN Month_of_absence IN (3,4,5) THEN 'Spring'
	 WHEN Month_of_absence IN (6,7,8) THEN 'Summer'
	 WHEN Month_of_absence IN (9,10,11) THEN 'Fall'
	 ELSE 'Unknown' END AS Season_Name,
	   ab.Body_mass_index,
CASE WHEN Body_mass_index < 18.5 THEN 'underweight'
     WHEN Body_mass_index BETWEEN 18.5 AND 24.9 THEN 'Healthy'
	 WHEN Body_mass_index BETWEEN 24.9 AND 29.9 THEN 'Overweight'
	 WHEN Body_mass_index >= 30 THEN 'Obese'
	 ELSE 'Unknown' END AS BMI_Category,
CASE WHEN Day_of_the_week = 1 THEN 'Sunday'
	 WHEN Day_of_the_week = 2 THEN 'Monday'
	 WHEN Day_of_the_week = 3 THEN 'Teusday'
	 WHEN Day_of_the_week = 4 THEN 'Wednesday'
	 WHEN Day_of_the_week = 5 THEN 'Thursday'
	 WHEN Day_of_the_week = 6 THEN 'Friday'
	 WHEN Day_of_the_week = 7 THEN 'Saturday'
	 ELSE 'Unknown' END AS Absentee_day_of_week,
		 ab.Transportation_expense,
CASE WHEN Education = 1 THEN 'Basic'
	 WHEN Education BETWEEN 2 AND 3 THEN 'Intermediate'
	 WHEN Education = 4 THEN 'Advanced'
	 ELSE 'Unknown' END AS Education_category,
		 ab.Son as Children,
CASE WHEN Social_drinker = 0 THEN 'No'
	 WHEN Social_drinker = 1 THEN 'Yes'
	 ELSE 'Unknown' END AS Alcohol_intake,
CASE WHEN Social_smoker = 0 THEN 'No'
	 WHEN Social_smoker = 1 THEN 'Yes'
	 ELSE 'Unknown' END AS Smoke,
		 ab.Pet,
CASE WHEN Disciplinary_failure = 0 THEN 'No'
	 WHEN Disciplinary_failure = 1 THEN 'Yes'
	 ELSE 'Unknown' END AS Disciplinary_Caution,
CASE WHEN Age < 30 THEN 'Early working age'
	 WHEN Age BETWEEN 31 AND 54 THEN 'Prime working age'
	 WHEN Age >55 THEN 'Mature working age'
	 ELSE 'Unknown' END AS Age_category,
		 ab.Work_load_Average_day,
		 ab.Absenteeism_time_in_hours
FROM  [dbo].[Absenteeism_at_work] ab
LEFT JOIN [dbo].[compensation] co
ON ab.ID = co.ID
LEFT JOIN [dbo].[Reasons] re
ON ab.Reason_for_absence = re.Number;
