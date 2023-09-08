
----load tables and view the content
select *
from dbo.['Covid-deaths]
order by 3,4

select *
from dbo.['Covid-vaccination]
order by 3,4

--- add specific columns to show
select location,date,new_cases,total_cases,total_deaths,population
from dbo.['Covid-deaths]
order by 1,2

---total deaths vs total cases, perform calculations
--- shows the likelihood of dying if infected in country e.g Nigeria

select location,date,total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from dbo.['Covid-deaths]
where location = 'Nigeria'
order by 1,2

---let's look at total caases vs population
---shows what percentage of population has got covid

select location,date,total_cases,population,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS cases_per_population
from dbo.['Covid-deaths]
where location = 'Nigeria'
order by 1,2

--- looking at the percentage of infection rates country wise (those with the highest infection rates)

select location,population,MAX(total_cases) as Highest_infection_Count,MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS percent_population_infected
from dbo.['Covid-deaths]
--where location like '%states%'
group by location,population
order by 4 desc

--- showing the countries wit the highest total death count

select location,MAX(total_deaths) as Highest_death_Count
from dbo.['Covid-deaths]
--where location like '%states%'
where continent is not NULL
group by location
order by 2 desc

--- cleaning up our data to eliminate certain unwanted entries, 
--- breaking it down by continent
--- showing the continents with highest death counts

select location,MAX(total_deaths) as Highest_death_Count
from dbo.['Covid-deaths]
where continent is NULL AND location not like '%income%'AND location not like '%world%'
group by location
order by 2 desc

select continent,MAX(total_deaths) as Highest_death_Count
from dbo.['Covid-deaths]
where continent is not NULL 
group by continent
order by 2 desc

---let's examine some global numbers
--,(sum(cast(total_deaths as int))/NULLIF(sum(cast(total_cases as int),0)*100 as globaldeathpercentage

--select sum(convert(float,total_cases)) as total_cases, sum(convert(float,total_deaths)) as total_deaths,sum(convert(float,total_deaths))/sum(convert(float,total_cases))*100 as deathpercentage
--from dbo.['Covid-deaths]
--where continent is not NULL
----group by date
----order by 1,2

----- examining global new cases and new deaths

--select sum(convert(float,new_cases)) as new_cases, sum(convert(float,new_deaths)) as new_deaths,sum(convert(float,new_deaths))/NULLIF(sum(convert(float,new_cases)),0)*100 as deathpercentage
--from dbo.['Covid-deaths]
--where continent is not NULL
----group by date
----order by 1,2

---examining total numbers globally

--- examining global total cases vs total deaths as well as new cases vs new deaths

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

--- looking at total populations vs vaccinations showing a rolling summation of new vaccinations 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) rolling_people_vacc_count
from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.date =vac.date and dea.location=vac.location
where dea.continent is not NULL
order by 2,3

--- to create a column to calculate proportion of population vaccinated, to do this we need to create a CTE

with popvsvacc(continent, location, date,population,new_vaccinations,rolling_people_vacc_count)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) rolling_people_vacc_count

from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.date =vac.date and dea.location=vac.location
where dea.continent is not NULL
--order by 2,3
)
SELECT*,(rolling_people_vacc_count/population)*100 as rolling_people_vacc_percentage
from popvsvacc


--- to crate a temp table

Drop Table if exists percentagepopulationvaccinated---comes in handy when implementing changes
CREATE TABLE percentagepopulationvaccinated
(continent nvarchar (255), location nvarchar (255), date datetime, population numeric,new_vaccinations numeric,rolling_people_vacc_count numeric)
insert into  percentagepopulationvaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) rolling_people_vacc_count

from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.date =vac.date and dea.location=vac.location
where dea.continent is not NULL
--order by 2,3

SELECT*,(rolling_people_vacc_count/population)*100 as rolling_people_vacc_percentage
from percentagepopulationvaccinated
order by 2,3


--- to create a view for later use

create view percentageofpopulationvaccinated
as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) rolling_people_vacc_count
from dbo.['Covid-deaths] dea
join dbo.['Covid-vaccination] vac
on dea.date =vac.date and dea.location=vac.location
where dea.continent is not NULL
--order by 2,3

select*
from percentageofpopulationvaccinated

