--- This project examines covid 19 data between 2020 and 2023, the aim of this project is to examine the figures  globally but with focus on Africa and Nigeria
--- The purpose of this project is to use SQL in exploring the data, pull out important information for subsequent examination and analysis

---LET'S GET STARTED 

----load tables and view the content, format the date column  and do some cleaning
select *
from dbo.['Covid-deaths]
order by 3,4

select *
from dbo.['Covid-vaccination]
order by 3,4


Select DateConverted, CONVERT(Date,date)
From dbo.['Covid-deaths]


ALTER TABLE dbo.['Covid-deaths]---create new date column to reflect date formatting
Add DateConverted Date;

Update dbo.['Covid-deaths]--- populate new column with the formatted date data
SET DateConverted = CONVERT(Date,date)

ALTER TABLE dbo.['Covid-deaths]---drops columns not relevant to the project
DROP COLUMN date


---specify columns to show from covid deaths table

select location,DateConverted,new_cases,total_cases,total_deaths,population
from dbo.['Covid-deaths]
order by 1,2

--- Examine and compare parameters
---total deaths vs total cases, death percentage (shows the likelihood of dying if infected  globally as well as in country e.g Nigeria)

select continent,location,DateConverted,total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from dbo.['Covid-deaths]
where continent is not NULL
order by 1,2

select continent,location,DateConverted,total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from dbo.['Covid-deaths]
where continent = 'Africa'
order by 1,2

select location,DateConverted,total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from dbo.['Covid-deaths]
where location = 'Nigeria'
order by 1,2

---let's look at total cases vs population as well as the total cases per population over time
---shows what percentage of the examined population has got covid

select location,DateConverted,total_cases,population,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS cases_per_population
from dbo.['Covid-deaths]
where continent is NOT NULL
order by 1,2


select location,DateConverted,total_cases,population,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS cases_per_population
from dbo.['Covid-deaths]
where continent = 'Africa'
order by 1,2


select location,DateConverted,total_cases,population,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS cases_per_population
from dbo.['Covid-deaths]
where location = 'Nigeria'
order by 1,2

---looking at the percentage of infection rates country wise (those with the highest infection rates) worldwide

select location,population,MAX(total_cases) as Highest_infection_Count,MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS percent_population_infected
from dbo.['Covid-deaths]
--where location like '%states%'
group by location,population
order by 4 desc

---looking at the percentage of infection rates country wise (those with the highest infection rates) for Africa

select location,population,MAX(total_cases) as Highest_infection_Count,MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS percent_population_infected
from dbo.['Covid-deaths]
where continent = 'Africa' 
group by location,population
order by 4 desc


--- showing the countries with the highest total death count worldwide

select location,MAX(total_deaths) as Highest_death_Count
from dbo.['Covid-deaths]
where continent is not NULL
group by location
order by 2 desc

--- showing the countries with the highest total death count in Africa

select location,MAX(total_deaths) as Highest_death_Count
from dbo.['Covid-deaths]
where continent = 'Africa'
group by location
order by 2 desc


---breaking it down by continent
---showing the continents death counts

select location,MAX(total_deaths) as Highest_death_Count
from dbo.['Covid-deaths]
where continent is NULL AND location not like '%income%'AND location not like '%world%'AND location not like '%union%'
group by location
order by 2 desc


---let's examine some more global numbers
--- examining global total cases vs total deaths as well as new cases vs new deaths and death percentages

select MAX(total_cases) as totalcases,MAX(total_deaths) as total_death_Count,sum(convert(float,total_deaths))/NULLIF(sum(convert(float,total_cases)),0)*100 as deathpercentage
from dbo.['Covid-deaths]
where continent is NULL
--group by location
--order by 2 desc

select MAX(new_cases) as totalnewcases,MAX(new_deaths) as new_death_Count,sum(convert(float,new_deaths))/NULLIF(sum(convert(float,new_cases)),0)*100 as deathpercentage
from dbo.['Covid-deaths]
where continent is NULL 
--group by location
--order by 2 desc


--- looking at total populations vs vaccinations showing a rolling summation of new vaccinations worldwide. i had to join the covid death and vaccination tables.

select dea.continent,dea.location,dea.DateConverted,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.DateConverted) rolling_people_vacc_count
from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.DateConverted =vac.date and dea.location=vac.location
where dea.continent is not NULL
order by 2,3


--- to create a column to calculate proportion of population vaccinated, to do this we need to create a CTE 

with popvsvacc(continent, location, DateConverted,population,new_vaccinations,rolling_people_vacc_count)
as
(
select dea.continent,dea.location,dea.DateConverted,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.DateConverted) rolling_people_vacc_count
from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.DateConverted =vac.date and dea.location=vac.location
where dea.continent is not NULL
--order by 2,3
)
SELECT*,(rolling_people_vacc_count/population)*100 as rolling_people_vacc_percentage
from popvsvacc


--- to create a temp table to draw up some of the data we have so far examined (Global and Africa)

---Global
Drop Table if exists percentagepopulationvaccinated---comes in handy when implementing changes
CREATE TABLE percentagepopulationvaccinated
(continent nvarchar (255), location nvarchar (255), DateConverted datetime, population numeric,new_vaccinations numeric,rolling_people_vacc_count numeric)
insert into  percentagepopulationvaccinated

select dea.continent,dea.location,dea.DateConverted,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.DateConverted) rolling_people_vacc_count
from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.DateConverted =vac.date and dea.location=vac.location
where dea.continent is not NULL
--order by 2,3

SELECT*,(rolling_people_vacc_count/population)*100 as rolling_people_vacc_percentage
from percentagepopulationvaccinated
order by 2,3

---Africa
Drop Table if exists percentagepopulationvaccinated---comes in handy when implementing changes
CREATE TABLE percentagepopulationvaccinated
(continent nvarchar (255), location nvarchar (255), DateConverted datetime, population numeric,new_vaccinations numeric,rolling_people_vacc_count numeric)
insert into  percentagepopulationvaccinated

select dea.continent,dea.location,dea.DateConverted,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.DateConverted) rolling_people_vacc_count
from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.DateConverted =vac.date and dea.location=vac.location
where dea.continent = 'Africa'
--order by 2,3

SELECT*,(rolling_people_vacc_count/population)*100 as rolling_people_vacc_percentage
from percentagepopulationvaccinated
order by 2,3


--- to create a view for later use for visualization

--- Globally
create view percentageofpopulationvaccinated
as
(
select dea.continent,dea.location,dea.DateConverted,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.DateConverted) rolling_people_vacc_count
from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.DateConverted =vac.date and dea.location=vac.location
where dea.continent is not NULL
--order by 2,3
)
select*
from percentageofpopulationvaccinated

---Africa
create view percentageofpopulationvaccinated
as
(
select dea.continent,dea.location,dea.DateConverted,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.DateConverted) rolling_people_vacc_count
from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.DateConverted =vac.date and dea.location=vac.location
where dea.continent is not NULL
--order by 2,3
)
select*
from percentageofpopulationvaccinated
where continent = 'Africa'

