Select * 
from PortfolioProject..CovidDeaths$
where continent is not null

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths--
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATH_PERCENTAGE
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%kingdom%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Cases_Percentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%kingdom%'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_of_population_Infected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY Percent_of_population_Infected DESC

--Showing the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--Global Numbers

SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATH_PERCENTAGE
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


SELECT date, sum(new_Cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/ SUM(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by Death_Percentage desc


--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ AS DEA
JOIN PortfolioProject..CovidVaccinations$ AS VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
where dea.continent is not null
order by 2,3

--Use CTE
with PopVSvac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ AS DEA
JOIN PortfolioProject..CovidVaccinations$ AS VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
where dea.continent is not null
--order by 2,3
)
select *, (Rolling_People_Vaccinated/Population)*100
from PopVSvac

--TEMP TABLE

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ AS DEA
JOIN PortfolioProject..CovidVaccinations$ AS VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
where dea.continent is not null
order by 2,3


select *, (Rolling_People_Vaccinated/Population)*100
from #PercentPopulationVaccinated


--Create view to store data for later visuals
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ AS DEA
JOIN PortfolioProject..CovidVaccinations$ AS VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
where dea.continent is not null
--order by 2,3
