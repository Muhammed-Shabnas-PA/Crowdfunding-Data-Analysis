CREATE DATABASE Media_Project

USE Media_Project

 --- we need to create a container to load our data

CREATE TABLE MediaP
 (ID VARCHAR(MAX),	Name VARCHAR(MAX),	Category VARCHAR(MAX),	Subcategory VARCHAR(MAX),
 	Country	VARCHAR(MAX),Launched VARCHAR(MAX),	Deadline VARCHAR(MAX),	Goal VARCHAR(MAX),	Pledged VARCHAR(MAX),	Backers VARCHAR(MAX),
	State VARCHAR(MAX))

SELECT * FROM MediaP

--- will import the data into our table mediaP by using Bulk insert query

BULK INSERT MediaP
FROM 'C:\Users\shadi\OneDrive\Desktop\Shabnas\SQL Practice\Business_domain_Mediap\Media_data.csv'
WITH ( FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2 )

-- next steps are to check the data validation-- data inconsistency, datatypes, anamolies in the data.

-- first step will change the datatype of the respecive fields

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS;

---- Goal, Pledged, Backers--->> INT

ALTER TABLE MediaP
ALTER COLUMN Goal INT;

ALTER TABLE MediaP
ALTER COLUMN Pledged INT;

ALTER TABLE MediaP
ALTER COLUMN Backers INT;

---Launched, Deadline --->> DATE

ALTER TABLE MediaP
ALTER COLUMN Deadline DATE;    /*error- Conversion failed when converting date and/or time from character string.*/

-- will plan to extract the hrs:min from the launched date and convert into date

ALTER TABLE MediaP
ADD Launch_Timing VARCHAR(20);

UPDATE MediaP
SET Launch_Timing = RIGHT(Launched, LEN(Launched)-CHARINDEX(' ', Launched));

UPDATE MediaP
SET Launched = LEFT(Launched, CHARINDEX(' ', Launched)-1);

UPDATE MediaP
SET Launched = CONVERT(DATE, Launched, 105);

ALTER TABLE MediaP
ALTER COLUMN Launched DATE;  ---Launched --->> DATE   

UPDATE MediaP
SET Deadline = CONVERT(DATE, Deadline, 105);

ALTER TABLE MediaP
ALTER COLUMN Deadline DATE;    --- Deadline --->> DATE

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS;

SELECT * FROM MediaP

--- how many distinct categories and sub categories of the project

SELECT DISTINCT Category, Subcategory
FROM MediaP;

SELECT COUNT (DISTINCT Category) AS 'TOTAL NO.OF CATEGORY', COUNT (DISTINCT Subcategory) AS 'TOTAL NO.OF SUBCATEGORY'
FROM MediaP;
-- **we have 15 categories and 159 categories distributed among these categories**

-- we'll find the caetegory wise no of projects

SELECT DISTINCT Category, COUNT(ID) AS 'NO.OF PROJECT'
FROM MediaP
GROUP BY Category
ORDER BY 2 DESC;

-- countries data

SELECT DISTINCT COUNTRY
FROM MediaP;

SELECT COUNT(DISTINCT COUNTRY) AS 'NO.OF COUNTRIES'
FROM MediaP;
---**we have 22 countries data**

--- projects distributed among the countries

--- Successful Project distributed among the countries

SELECT Country, COUNT(ID) AS 'NO.OF PROJECTS'
FROM MediaP
WHERE State = 'Successful'
GROUP BY Country
ORDER BY 'NO.OF PROJECTS' DESC;   /* highest successful projects are from USA = 109299*/

SELECT Country, COUNT(ID) AS 'NO.OF PROJECTS'
FROM MediaP
WHERE State = 'Successful'
GROUP BY Country
ORDER BY 'NO.OF PROJECTS';   /*Least successful are  from Japan = 7 */

--- Failed Project distributed among the countries

SELECT Country, COUNT(ID) AS 'NO.OF PROJECTS'
FROM MediaP
WHERE State = 'Failed'
GROUP BY Country
ORDER BY 'NO.OF PROJECTS' DESC;  /* Highest failed projects are from USA = 152059 */

SELECT Country, COUNT(ID) AS 'NO.OF PROJECTS'
FROM MediaP
WHERE State = 'Failed'
GROUP BY Country
ORDER BY 'NO.OF PROJECTS';  /* Least failed projects are also from Japan = 16 */

--- projects distributed among the Category

SELECT Category, COUNT(ID) AS 'TOTAL PROJECTS',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END) AS 'TOTAL SUCCESSFUL PROJECTS',
	   COUNT (CASE WHEN State = 'Failed' THEN 1 END) AS 'TOTAL FAILED PROJECTS',
	   COUNT (CASE WHEN State = 'Live' THEN 1 END) AS 'TOTAL LIVE PROJECTS',
	   COUNT (CASE WHEN State = 'Canceled' THEN 1 END) AS 'TOTAL CANCELED PROJECTS',
	   COUNT (CASE WHEN State = 'Suspended' THEN 1 END) AS 'TOTAL SUSPENDED PROJECTS',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END)*100.0/COUNT(ID) AS 'SUCCESS RATIO'
FROM MediaP
GROUP BY Category
ORDER BY 'SUCCESS RATIO' DESC;  /*based on Success rate Dance, Theater, Comics, Music & Art are the top 5 categories*/

SELECT Category, COUNT(ID) AS 'TOTAL PROJECTS',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END) AS 'TOTAL SUCCESSFUL PROJECTS',
	   COUNT (CASE WHEN State = 'Failed' THEN 1 END) AS 'TOTAL FAILED PROJECTS',
	   COUNT (CASE WHEN State = 'Live' THEN 1 END) AS 'TOTAL LIVE PROJECTS',
	   COUNT (CASE WHEN State = 'Canceled' THEN 1 END) AS 'TOTAL CANCELED PROJECTS',
	   COUNT (CASE WHEN State = 'Suspended' THEN 1 END) AS 'TOTAL SUSPENDED PROJECTS',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END)*100.0/COUNT(ID) AS 'SUCCESS RATIO'
FROM MediaP
GROUP BY Category
ORDER BY 'SUCCESS RATIO'; /* Tech, Journalism, Crafts, fashion & food are the least successful rate categories */

--- projects distributed among the Category, Subcategory

SELECT Category, Subcategory, COUNT(ID) AS 'TOTAL PROJECTS',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END) AS 'TOTAL SUCCESSFUL PROJECTS',
	   COUNT (CASE WHEN State = 'Failed' THEN 1 END) AS 'TOTAL FAILED PROJECTS',
	   COUNT (CASE WHEN State = 'Live' THEN 1 END) AS 'TOTAL LIVE PROJECTS',
	   COUNT (CASE WHEN State = 'Canceled' THEN 1 END) AS 'TOTAL CANCELED PROJECTS',
	   COUNT (CASE WHEN State = 'Suspended' THEN 1 END) AS 'TOTAL SUSPENDED PROJECTS',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END)*100.0/COUNT(ID) AS 'SUCCESS RATIO'
FROM MediaP
GROUP BY Category, Subcategory
ORDER BY Category DESC;

---find the top subcategories in all categories based on successful rate

WITH PROJECTDET AS (SELECT Category, Subcategory, COUNT(ID) AS 'TOTAL PROJECTS',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END) AS 'TOTAL SUCCESSFUL PROJECTS',
	   COUNT (CASE WHEN State = 'Failed' THEN 1 END) AS 'TOTAL FAILED PROJECTS',
	   COUNT (CASE WHEN State = 'Live' THEN 1 END) AS 'TOTAL LIVE PROJECTS',
	   COUNT (CASE WHEN State = 'Canceled' THEN 1 END) AS 'TOTAL CANCELED PROJECTS',
	   COUNT (CASE WHEN State = 'Suspended' THEN 1 END) AS 'TOTAL SUSPENDED PROJECTS',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END)*100.0/COUNT(ID) AS 'SUCCESS RATIO',
	   RANK() OVER( PARTITION BY Category ORDER BY COUNT (CASE WHEN State = 'Successful' THEN 1 END)*100.0/COUNT(ID) DESC) AS 'RANK'
FROM MediaP
GROUP BY Category, Subcategory)
SELECT Category, Subcategory, [TOTAL PROJECTS], [TOTAL SUCCESSFUL PROJECTS], [TOTAL FAILED PROJECTS], [TOTAL LIVE PROJECTS], [TOTAL CANCELED PROJECTS], [SUCCESS RATIO]
FROM PROJECTDET
WHERE [RANK] = 1
ORDER BY [SUCCESS RATIO] DESC;  /* Chiptune, Anthologies, Residencies, Letterpress, Theater are the top 5 subcategories in all categories based on successful rate */

-- analyzing the goal amount by sub categories

SELECT Category, Subcategory, SUM(Goal) AS 'Total_Goal_Amount', AVG(Goal) AS 'Avg. Goal_Amount'
FROM MediaP
GROUP BY Category, Subcategory
ORDER BY Total_Goal_Amount DESC; /* Technology, Video Games, Documentary, Film & Video, Product Design are the top 5 sub categories by goal amount*/ 

-- analyzing the Pledged amount by sub categories

SELECT Category, Subcategory, SUM(Pledged) AS 'Total_Pledged_Amount', AVG(Pledged) AS 'Avg. Pledged_Amount'
FROM MediaP
GROUP BY Category, Subcategory
ORDER BY Total_Pledged_Amount DESC;  /* Product Design, Tabletop Games, Video Games, Hardware, Technology are the top 5 sub categories by Pledged amount*/ 

--- Let;s go with demographic analysis-- what info we have here-- country

SELECT Country, COUNT(ID) AS 'Country_wise_project', SUM(CAST(Goal AS bigint)) AS 'Total_asked_amount', SUM(CAST(Pledged AS bigint)) AS 'Total_collected_amount',
	   COUNT(Backers) AS 'Individial_inv'
FROM MediaP
GROUP BY Country
ORDER BY Total_collected_amount DESC, Country_wise_project DESC; /* United States, United Kingdom, Canada, Australia, Germany are the highest amount collected countries */

---let's correlate the Goal Amount with the success rate

SELECT GoalRange, COUNT (CASE WHEN State = 'Successful' THEN 1 END) AS 'TOTAL SUCCESSFUL PROJECTS',
	   COUNT (CASE WHEN State = 'Failed' THEN 1 END) AS 'TOTAL FAILED PROJECTS',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END)*100.0/COUNT(ID) AS 'SUCCESS RATIO'
FROM ( SELECT ID, Name, State, CASE WHEN Goal<1000 THEN 'Below 1000'
									WHEN Goal BETWEEN 1000 AND 5000 THEN '1000-6000'
									WHEN Goal BETWEEN 6000 AND 10000 THEN '6000-10000'
									ELSE 'Above 10000' END AS GoalRange
									FROM MediaP) AS GoalRanges
GROUP BY GoalRange
ORDER BY [SUCCESS RATIO] DESC; /* When the goal amount increased, the success ratio decreased. */

--- Backers- who contributed in the project individually
--Problem- Determine the distribution of Backers across projects and their categories
--Where it determines the interest of Backers on Various projects then can plan accordingly to engage more backers to the projects

SELECT Category, Subcategory, SUM(Backers) AS 'Total_Backers', AVG(Backers) AS 'Avg._Backers', 
	   MAX(Backers) AS 'Max._Backers', MIN(Backers) AS 'Min._Backers'
FROM MediaP
GROUP BY Category, Subcategory
ORDER BY Total_Backers DESC; /* The subcategories with the highest number of backers are Product Design, Tabletop Games, Video Games, Documentary, and Technology. */

--- We'll create the Category_per_metrics

WITH Cat_Status AS (SELECT Category, Subcategory, COUNT(CASE WHEN State = 'Successful' THEN 1 END) AS 'Successful_Projects', COUNT(*) AS 'Total_Projects',
					COUNT(CASE WHEN State = 'Successful' THEN 1 END)*100/COUNT(*) AS 'Success_Percentage', SUM(CAST(Pledged AS bigint)) AS 'Total_Pledged',
					AVG(CAST(Pledged AS bigint)) AS 'Avg_Pledged', VAR(CAST(Pledged AS bigint)) AS 'Var_Pledged', STDEV(CAST(Pledged AS bigint)) AS 'Std_Pledged'
					FROM MediaP
					GROUP BY Category, Subcategory),
	 Overall_Status AS ( SELECT AVG(CAST(Pledged AS bigint)) AS 'Avg_Overall_Pledged', COUNT(*) AS 'Total_Projects', 
						 COUNT(CASE WHEN State = 'Successful' THEN 1 END)*100/COUNT(*) AS 'Overall_Success_Percentage'
						 FROM MediaP),
	 Status_Rank AS ( SELECT Category, Subcategory, Success_Percentage, Avg_Pledged, Total_Pledged,
					  RANK() OVER (ORDER BY Success_Percentage DESC) AS 'Success_Percentage_Rank',
					  RANK() OVER (ORDER BY Avg_Pledged DESC) AS 'Avg_Pledged_Rank'
					  FROM Cat_Status),
	 Percentile AS ( SELECT Category, Subcategory,
					 NTILE(100) OVER( PARTITION BY Category ORDER BY Success_Percentage) AS 'Success_Percentile',
					 NTILE(100) OVER( PARTITION BY Category ORDER BY Avg_Pledged) AS 'Avg_Pledged_Percentile'
					 FROM Cat_Status)
SELECT CS.Category, CS.Subcategory, CS.Success_Percentage, CS.Avg_Pledged, CS.Var_Pledged, CS.Std_Pledged,
	   OS.Avg_Overall_Pledged, OS.Overall_Success_Percentage, 
	   SR.Success_Percentage_Rank, SR.Avg_Pledged_Rank,
	   P.Success_Percentile, P.Avg_Pledged_Percentile
FROM Cat_Status CS
JOIN Overall_Status OS
ON 1=1
JOIN Status_Rank SR
ON CS.Category = SR.Category
JOIN Percentile P
ON CS.Category = P.Category
ORDER BY CS.Var_Pledged DESC;

--- filter out the 5 high to low variance subcategories

SELECT TOP 5 Category, Subcategory,VAR(CAST(Pledged AS bigint)) AS 'Var_Pledged'
FROM MediaP
GROUP BY Category, Subcategory
ORDER BY Var_Pledged DESC; /* The top five subcategories with the highest variance are Gaming Hardware, Sound, 3D Printing, Product Design, and Wearables.*/


select * from MEdiap
-- we have two dates here ( launched and deadline) we can also understand that difference in these dates can be understand as 
-- campaingn duration

---do some modelling in data

SELECT YEAR(Launched) AS 'Launched_Year', MONTH(Launched) AS 'Launched_Month',
	   COUNT(*) AS 'Total_Project',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END) AS 'Successfull_Projects',
	   COUNT (CASE WHEN State = 'Failed' THEN 1 END) AS 'Failed_Projects',
	   COUNT (CASE WHEN State = 'Suspended' THEN 1 END) AS 'Suspended_Projects',
	   COUNT (CASE WHEN State = 'Canceled' THEN 1 END) AS 'Canceled_Projects',
	   COUNT (CASE WHEN State = 'live' THEN 1 END) AS 'live_Projects',
	   SUM(CAST(Goal AS bigint)) AS 'Total_Goal',
	   SUM(CAST(Pledged AS bigint)) AS 'Total_Pledged',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END) *100.0/NULLIF(COUNT(*),0) AS 'Success_Percentage',
	   COUNT (CASE WHEN State = 'Failed' THEN 1 END) *100.0/NULLIF(COUNT(*),0) AS 'Failed_Percentage'
FROM MediaP
GROUP BY YEAR(Launched), MONTH(Launched)
ORDER BY Total_Project DESC;

------------------------------------------------------------------------------------------------------------

SELECT FORMAT(Launched,'yyyy') as 'Launch_date',
	   COUNT(*) AS 'Total_Project',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END) AS 'Successfull_Projects',
	   COUNT (CASE WHEN State = 'Failed' THEN 1 END) AS 'Failed_Projects',
	   COUNT (CASE WHEN State = 'Suspended' THEN 1 END) AS 'Suspended_Projects',
	   COUNT (CASE WHEN State = 'Canceled' THEN 1 END) AS 'Canceled_Projects',
	   COUNT (CASE WHEN State = 'live' THEN 1 END) AS 'live_Projects',
	   SUM(CAST(Goal AS bigint)) AS 'Total_Goal',
	   SUM(CAST(Pledged AS bigint)) AS 'Total_Pledged',
	   COUNT (CASE WHEN State = 'Successful' THEN 1 END) *100.0/NULLIF(COUNT(*),0) AS 'Success_Percentage',
	   COUNT (CASE WHEN State = 'Failed' THEN 1 END) *100.0/NULLIF(COUNT(*),0) AS 'Failed_Percentage'
FROM MediaP
GROUP BY FORMAT(Launched,'yyyy')
ORDER BY Total_Project DESC;


/* 
Analysis Report
1. Yearly Trends (Launched_Year)
- Total Projects: Analyze the increase or decrease in the number of projects launched over the years. If the total number of projects shows a steady rise, it suggests a growing interest in launching projects.
- Success Trends: By observing the `Success_Percentage` over years, you can see whether projects are becoming more successful. A declining trend may indicate increasing challenges in meeting goals or market saturation.

2. Monthly Seasonality (Launched_Month)
- Project Launches: Certain months might show higher project launches. For example, there might be spikes in launches at the start of the year (January) or around specific seasons, such as the holiday period.
- Success Rates: Months with higher `Success_Percentage` might indicate favorable seasons for launching successful projects. Conversely, months with low success rates could represent less effective times to launch.

3. Project Status Breakdown
- Success vs. Failure: A growing number of `Failed_Projects` or `Suspended_Projects` might highlight increasing challenges or more ambitious project goals.
- Canceled Projects: Analyze whether cancellations are seasonally or yearly influenced, indicating periods of higher risk or uncertainty.

4. Funding Trends
- Pledged vs. Goal: Comparing `Total_Pledged` with `Total_Goal` can highlight periods where funding goals are more likely to be met. If specific months or years consistently show higher pledged amounts, they may represent strategic times for launching projects.
- Average Funding Per Project: Analyze if the average funding per project improves over time, which might reflect market growth or better project planning.

5. Success vs. Failure Percentages
- Seasonal Peaks: If `Success_Percentage` is significantly higher in certain months or years, it could indicate seasonal or economic factors favoring success.
- Failure Analysis: Identify trends in `Failed_Percentage` to find periods of high risk or common pitfalls.
*/
---------------------------------------------------------------------------------------------------------------------------------------------

-- we have 22 countries data for these projects

-- analyse the Impact of the country in Project success

--- find out the more deep analysis on trend of data

WITH Project_data AS (
    SELECT ID, Name, Category, Country, 
           YEAR(launched) AS 'tyear',
           MONTH(launched) AS 'tmonth',
           DATEPART(QUARTER, Launched) AS 'tquarter',
           [state]
    FROM mediap
)

-- Let's aggregate the data by year, quarter, month
, Data_aggregation AS (
    SELECT tyear, tmonth, tquarter, category, country,
           COUNT(*) AS 'tprojects',
           COUNT(CASE WHEN state = 'Successful' THEN 1 END) AS 'Sccs_projects',
           COUNT(CASE WHEN state = 'Successful' THEN 1 END) * 100.0 / COUNT(*) AS 'Sccs_percnt'
    FROM project_data
    GROUP BY tyear, tquarter, tmonth, country, category
)

--- Let's find their cumulative totals
, runningtotals AS (
    SELECT tyear,
           tmonth,
           tquarter,
           country,
           category,
           tprojects,
           sccs_projects,
           sccs_percnt,
           SUM(tprojects) OVER (PARTITION BY category, country ORDER BY tyear, tquarter, tmonth) AS 'Cum_projects',
           SUM(sccs_projects) OVER (PARTITION BY category, country ORDER BY tyear, tquarter, tmonth) AS 'Cum_sccs_projects',
           AVG(Sccs_percnt) OVER (PARTITION BY category, country ORDER BY tyear, tquarter, tmonth ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS 'Moving_avg_Sccs_rt'
    FROM Data_aggregation
)

--- Final result with the query
SELECT tyear, tquarter, tmonth, category, country, tprojects,
       sccs_projects, sccs_percnt, cum_projects,
       cum_sccs_projects, moving_avg_sccs_rt
FROM runningtotals
ORDER BY tyear, tquarter, tmonth, category, country;

SELECT * FROM Mediap;