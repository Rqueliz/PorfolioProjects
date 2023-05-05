Select * 
FROM [Portfolio Project]..CovidDeaths 
Where continent is not null
order by 3,4


----Select * 
----FROM [Portfolio Project]..CovidVacinations 
----order by 3,4
--Select Data tha we are going to be  using 

Select Location, date , total_cases,new_cases, total_deaths,population
From [Portfolio Project]..CovidDeaths 
order by 1,2

-- Looking at total cases vs Total Deaths
-- Show likelihood of dayinh if you contract covid in your country
Select Location, date , total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases VS Population
--Show what percentage of population got covid
Select Location, date , population,  total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at countries with Highest Infection Rate Compared to population

Select Location, population,  MAX(total_cases)AS HighestIngectionCount, MAX((total_cases/population))*100 
as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc 

-- Showing Countries with Highest Death Count Per Population


Select Location, Max(Cast (total_deaths as Int)) as TotalDeathsCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathsCount desc 

-- lET'S Break Things Down By CONTINENT



-- Showing Contintents with the highest death count per population

Select continent, Max(Cast (total_deaths as Int)) as TotalDeathsCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathsCount desc 


-- Global Numenrs


Select SUM(NEW_cases) as total_cases, SUM(CAST (NEW_DEATHS as int))as total_deaths,SUM(CAST (NEW_DEATHS as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By Date
order by 1,2



--Looking at Total Population Vs Vaccinations


Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(convert (int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeopleVaccinated
, (rollingpeopleVaccinated/population)100*
 From    [Portfolio Project].. CovidDeaths dea
Join [Portfolio Project].. CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null
order by  2,3


-- USE CTE

with PopvsVac(Continent,location, date, population,new_vaccinations, rollingpeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(convert (int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeopleVaccinated
--, (rollingpeopleVaccinated/population)100*
 From    [Portfolio Project].. CovidDeaths dea
Join [Portfolio Project].. CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null
--order by  2,3
) Select *, (rollingpeopleVaccinated/population)*100 
From PopvsVac

-- TEMP TABLE
-- 
Drop table if exists #percentpopulationVaccinated
Create table  #percentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeopleVaccinated numeric
)

insert into #percentpopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(convert (int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeopleVaccinated
--, (rollingpeopleVaccinated/population)100*
 From    [Portfolio Project].. CovidDeaths dea
Join [Portfolio Project].. CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
--Where dea.continent is not null
--order by  2,3

Select *, (rollingpeopleVaccinated/population)*100 
From #percentpopulationVaccinated


-- Creating View to store data for later visualizations

Create view percentpopulationVaccinated as 
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(convert (int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as rollingpeopleVaccinated
--, (rollingpeopleVaccinated/population)100*
 From    [Portfolio Project].. CovidDeaths dea
Join [Portfolio Project].. CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null
--order by  2,3

Select * from percentpopulationVaccinated