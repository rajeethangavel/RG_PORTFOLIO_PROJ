----Covid 19 Data Exploration 

/*Skills used: 
Joins, CTE's, Temp Tables, Windows Functions,
Aggregate Functions, Creating Views, Converting Data Types */


--Select *
--From Portfolio_Proj..Covid_Deaths
--Where continent is not null 
--order by 3,4


--Select Data that we are going to be starting with

--Select Location, date, total_cases, new_cases, total_deaths, population
--From Portfolio_Proj..Covid_Deaths
--Where continent is not null 
--order by 1,2


-- Total Cases vs Total Deaths

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From Portfolio_Proj..Covid_Deaths
--Where location like '%states%'
--and continent is not null 
--order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

--Select Location, date, Population, total_cases,  (total_cases/population)*100 as Percent_Pop_Inftd
--From Portfolio_Proj..Covid_Deaths
--Where location like '%states%'
--order by 1,2


-- Countries with Highest Infection Rate compared to Population

--Select Location, Population, MAX(total_cases) as High_Inf_Cnt,  Max((total_cases/population))*100 as Percent_Pop_Inftd
--From Portfolio_Proj..Covid_Deaths
--Where location like '%states%'
--Group by Location, Population
--order by Percent_Pop_Inftd desc


-- Countries with Highest Death Count per Population

--Select Location, MAX(cast(Total_deaths as int)) as Tot_Dth_Cnt
--From Portfolio_Proj..Covid_Deaths
--Where location like '%states%'
--and continent is not null 
--Group by Location
--order by Tot_Dth_Cnt desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

--Select continent, MAX(cast(Total_deaths as int)) as Tot_Dth_Cnt
--From Portfolio_Proj..Covid_Deaths
--Where location like '%states%'
--and continent is not null 
--Group by continent
--order by Tot_Dth_Cnt desc

-- GLOBAL NUMBERS

--Select SUM(new_cases) as tot_cases, SUM(cast(new_deaths as int)) as tot_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Dth_Prcnt
--From Portfolio_Proj..Covid_Deaths
--Where location like '%states%'
--and continent is not null 
--Group By date
--order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Roll_Ppl_Vcntd
--,(Roll_Ppl_Vcntd/dea.population)*100
From Portfolio_Proj..Covid_Deaths dea
Join Portfolio_Proj..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVacn (Continent, Location, Date, Population, New_Vaccinations, Roll_Ppl_Vcntd)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Roll_Ppl_Vcntd
From Portfolio_Proj..Covid_Deaths dea
Join Portfolio_Proj..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

Select *, (Roll_Ppl_Vcntd/Population)*100
From PopvsVacn


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists Prcnt_Pop_Vcntd
Create Table Prcnt_Pop_Vcntd
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Roll_Ppl_Vcntd numeric
)

Insert into Prcnt_Pop_Vcntd
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Roll_Ppl_Vcntd
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Proj..Covid_Deaths dea
Join Portfolio_Proj..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (Roll_Ppl_Vcntd/Population)*100
From Prcnt_Pop_Vcntd

-- Creating View to store data for later visualizations

--drop view if exists Prcnt_Popn_Vcntd ----Wont work as drop table as create view should be the 1st statement in a query batch 
Create View Prcnt_Popn_Vcntd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Roll_Ppl_Vcntd
From Portfolio_Proj..Covid_Deaths dea
Join Portfolio_Proj..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--drop view Prcnt_Popn_Vcntd

select * 
from Prcnt_Popn_Vcntd

