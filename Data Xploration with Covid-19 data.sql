/* Covid 19 Data Exploration with focus on Nigeria

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types*/

Select *
From Covidvaxn
order by 3, 4;

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeath
order by 1,2;

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeath
Where continent is not null
order by 1, 2;

/*TQuestion 1: Total cases against total death*/
--I had to change the data type to numeric because it was auto rounding-up the results
Alter table coviddeath
alter column total_deaths numeric;

Alter table coviddeath
alter column total_cases numeric;

--This shows the chance by which Nigerians could get affected by the covid.
Select Location, date, total_cases, total_deaths, Round ((total_deaths/total_cases)*100,1) as death_percentage
From CovidDeath
Where location = 'nigeria'
and continent is not null
order by 1, 2;

--Q2 Total cases vs the population = 0.1 of the population.
Select Location, date, population, total_cases, Concat (Round ((total_cases/population)*100,1),'%') as percentageInfected
From CovidDeath
Where location = 'nigeria'
order by 1,2 desc;

--Q3 countries with highest infection rate compared to their population
Select Location, population, Max(total_cases) as highest_rate_of_infection, Concat(Round (Max((total_cases/population))*100, 2),'%') as percentinfectedperpopulation
From CovidDeath
group by  location, population
order by percentinfectedperpopulation desc;

--Q4 countries with highest death count per population
Select continent, Location, Max(total_deaths) as highest_rate_of_death
from CovidDeath
Where continent is not null
group by location, continent
order by highest_rate_of_death desc;

--Q5 continent with highest death count
Select continent, max(total_deaths) as highest_rate_of_death
from CovidDeath
Where continent is not null
group by continent
order by highest_rate_of_death desc

--Q5 continent with highest death count (Done with a different data source)
Select continent, sum(deaths_total) as DeathCountTotal
from newcd
Where continent is not null
group by continent
order by DeathCountTotal desc


-- Q6 Total cases across the world 
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(new_deaths)/sum(nullif(new_cases,0))* 100 as percentageDeath
from CovidDeath
where continent is not null
order by 1,2;

--Q7 number of people vaccinated in the world
With PopVaxxed as (SELECT d.continent, d.location,d.date, population,new_vaccinations,
SUM(CAST(new_vaccinations as numeric)) OVER (Partition by d.location ORDER BY d.location, d.date) as peopleVaxxed
FROM CovidDeath as d
Inner Join Covidvaxn as v
ON d.location = v.location and d.date =v.date 
where d.continent is not null 
)
Select *, (peopleVaxxed/population)*100
from PopVaxxed;

--Q4 countries with highest death count
Select location,  Max(total_deaths) as DeathCountTotal
from CovidDeath
Where continent is null
and location not in ('World', 'European Union', 'International', 'Lower middle income', 'Low income', 'High income', 'Upper middle income')
group by location
order by DeathCountTotal desc;



-- Creating views
Create view PopVaxxed as 
SELECT d.continent, d.location,d.date, population,new_vaccinations,
SUM(CAST(new_vaccinations as numeric)) OVER (Partition by d.location ORDER BY d.location, d.date) as peopleVaxxed
FROM CovidDeath as d
Inner Join Covidvaxn as v
ON d.location = v.location and d.date =v.date 
where d.continent is not null;

Create view total_global_death as 
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(new_deaths)/sum(nullif(new_cases,0))* 100 as percentageDeath
from CovidDeath
where continent is not null;
