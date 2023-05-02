--Project Started:

Select *
From portfolio_project..CovidDeaths
where continent is not NULL
Order By 3,4

--Select *
--From portfolio_project..CovidVaccinations
--Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population		
From portfolio_project..CovidDeaths
Order By 1,2


--Total Cases vs Total Deaths:
-- Shows the likelihood of dying if you get infected in that country

Select location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as  Death_percentage
From portfolio_project..CovidDeaths
Where location = 'India' 
Order By 1,2


--Total Cases vs Population:

Select location, date, total_cases, population, Round((total_cases/population)*100,2) as  population_got_affected
From portfolio_project..CovidDeaths
Where location = 'India' 
Order By 1,2


--Countries with Highest Infection Rate:

Select location, MAX(total_cases) as Highest_Infection_Count, population, Round(MAX((total_cases/population))*100,2) as  population_got_affected
From portfolio_project..CovidDeaths
Group by population, location
Order By population_got_affected desc


--Highest Death Count per Population:
--In this total_deaths has wrong datatype, so when using max func. it misinterpret what we want; to solve this use cast func.

Select location, MAX(cast(total_deaths as int)) as Total_Deaths_Count, population
From portfolio_project..CovidDeaths
where continent is not NULL
Group by location, population
Order By Total_Deaths_Count desc


--based on continent:

Select continent, MAX(cast(total_deaths as int)) as Total_Deaths_Count
From portfolio_project..CovidDeaths
where continent is not NULL
Group by continent
Order By Total_Deaths_Count desc


--based on location (not continent):

Select location, MAX(cast(total_deaths as int)) as Total_Deaths_Count
From portfolio_project..CovidDeaths
where continent is not NULL
Group by location
Order By Total_Deaths_Count desc


--Global Numbers:

Select date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as  Death_percentage
From portfolio_project..CovidDeaths
Where continent is not NULL
Order By 1,2


--this is daily change in death percentage:

Select date, Sum(new_cases), Sum(cast(new_deaths as int)), 
Round((Sum(cast(new_deaths as int))/Sum(new_cases))*100,2) as New_Death_percentage
From portfolio_project..CovidDeaths
Where continent is not NULL
Group by date
Order By 1,2


--this is death percentage of whole world:

Select Sum(new_cases), Sum(cast(new_deaths as int)), 
Round((Sum(cast(new_deaths as int))/Sum(new_cases))*100,2) as New_Death_percentage
From portfolio_project..CovidDeaths
Where continent is not NULL
--Group by date
Order By 1,2


--new table:

Select *
From portfolio_project	..CovidVaccinations


--joining both tables:
-- joining both tables from column location and date

Select *
From portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vacc
	on dea.location = vacc.location and 
	   dea.date = vacc.date


--looking at total population vs total vaccination globally:

Select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations
From portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vacc
	on dea.location = vacc.location and 
	   dea.date = vacc.date
where dea.continent is not NULL
order by 2,3

--refining it: 
--partition by location is used to add values for particular location, after that it resets for new locations
--it adds new vaccination and add it to people vaccinated col.

Select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations,
Sum(convert(int, vacc.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as People_vaccinated
From portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vacc
	on dea.location = vacc.location and 
	   dea.date = vacc.date
where dea.continent is not NULL
order by 2,3


Select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations,
Sum(convert(int, vacc.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as People_vaccinated,
--Round((People_vaccinated/population)*100)
From portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vacc
	on dea.location = vacc.location and 
	   dea.date = vacc.date
where dea.continent is not NULL
order by 2,3

--as we cannot use just created People_vaccinated col. to create another col.  
--we need to create CTE or Temp table

--using CTE: common tale expression

with PopvsVac(Continent, Location, Date, Population, New_Vaccination, People_vaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations,
Sum(convert(int, vacc.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as People_vaccinated
From portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vacc
	on dea.location = vacc.location and 
	   dea.date = vacc.date
where dea.continent is not NULL
)
Select *, Round((People_vaccinated/population)*100,2) as vaccine_percentage
From PopvsVac
Where Location = 'India'


--using Temp Table:

drop Table if exists #Populationvaccinatedpercent
Create Table #Populationvaccinatedpercent
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
People_vaccinated numeric
)

Insert into #Populationvaccinatedpercent
Select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations,
Sum(convert(int, vacc.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as People_vaccinated
From portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vacc
	on dea.location = vacc.location and 
	   dea.date = vacc.date
where dea.continent is not NULL

 Select *, Round((People_vaccinated/population)*100,2) as vaccine_percentage
From #Populationvaccinatedpercent



--create view: for visualisation

Create View Populationvaccinatedpercent_2 as
Select dea.continent, dea.location, dea.date,dea.population, vacc.new_vaccinations,
Sum(convert(int, vacc.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as People_vaccinated
From portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vacc
	on dea.location = vacc.location and 
	   dea.date = vacc.date
where dea.continent is not NULL

--check if view is created, as sometimes it doesn't show in the views tab after refresh
select *
from Populationvaccinatedpercent_2