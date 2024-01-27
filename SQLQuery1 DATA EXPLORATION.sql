SELECT *
FROM CovidDeaths
WHERE continent is null
ORDER BY 3,4


--percentage of people dying who gets infected
  
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as deathpercentage
FROM CovidDeaths
WHERE location LIKE '%ndia'
ORDER BY 1,2

--looking at total cases vs population
--shows us what percentage of population has gotten covid
  
SELECT location,date,total_cases,population,(total_cases/population) * 100 as percentpopulationinfected
FROM CovidDeaths
WHERE location LIKE '%ndia'
ORDER BY 1,2

--looking at countries with highest infection rate compared to population
  
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population) * 100) as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--showing countries with highest death count per population
  
SELECT location,MAX(cast(total_deaths as int)) as HighestdeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestdeathCount DESC

--let's break things down by continent
  
SELECT continent,MAX(cast(total_deaths as int)) as HighestdeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestdeathCount DESC

SELECT location,MAX(cast(total_deaths as int)) as HighestdeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY HighestdeathCount DESC

--showing continents with highest death count per population
  
SELECT continent,MAX(cast(total_deaths as int)) as HighestdeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestdeathCount DESC

--GLOBAL NUMBERS
  
SELECT date,SUM(new_cases)as totalcases,SUM(cast(new_deaths as int))as totaldeaths,SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathpercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--if we will remove date and see the total
  
SELECT SUM(new_cases)as totalcases,SUM(cast(new_deaths as int))as totaldeaths,SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as deathpercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--join both tables
  
SELECT *
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date

--looking at total population vs vaccination (total people in world that have been vaccinated)
  
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--rolling count
  
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rollingpeoplevaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--use cte and percentage of people getting vaccinated
  
with PopsvsVac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rollingpeoplevaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(rollingpeoplevaccinated/population)*100
FROM PopsvsVac

--temptable and stored procedure
  
CREATE PROCEDURE STAR
AS
CREATE TABLE #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacciantions numeric,
rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rollingpeoplevaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(rollingpeoplevaccinated/population)*100 
FROM #percentpopulationvaccinated

EXEC STAR

--creating view to store data for later visualizations

Create view percentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rollingpeoplevaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

Select *
From percentpopulationvaccinated
