SELECT *
FROM PortoflioProject..CovidDeaths$
ORDER BY 3,4

SELECT *
FROM PortoflioProject..CovidVaccinations$
ORDER BY 3,4

--Select the Data That We are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortoflioProject..CovidDeaths$
ORDER BY 1,2

--Looking at the Total Cases vs Total Deaths 
--Shows Likelyhood of Dying if you contract COVID in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortoflioProject..CovidDeaths$
Where location = 'India'
ORDER BY 1,2

--Looking at the total cases vs the population
--Shows what percentage of population got covid
SELECT location, date, population, total_cases,(total_cases/population)*100 as PopulationCovidImpact
FROM PortoflioProject..CovidDeaths$
Where location = 'India'
ORDER BY 1,2

--Looking at the Countries with Highest Infection Rate comapared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationCovidImpact
FROM PortoflioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PopulationCovidImpact DESC

--showing countries with highest deathcount per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortoflioProject..CovidDeaths$
WHERE continent is NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS BY CONTINENT
-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortoflioProject..CovidDeaths$
WHERE continent is not NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as Deathpercentage
FROM PortoflioProject..CovidDeaths$
Where location IS NOT NULL
ORDER BY 1,2

--Looking at Total Pouplation vs Total Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingpeopleVaccinated
FROM PortoflioProject..CovidDeaths$ dea
JOIN PortoflioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- with CTE
with popvsvac (continet, location, date, population, new_vaccinatiions, RollingpeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingpeopleVaccinated
FROM PortoflioProject..CovidDeaths$ dea
JOIN PortoflioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingpeopleVaccinated/population)*100
FROM popvsvac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationvaccinated
CREATE TABLE #PercentPopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric
)
Insert into #PercentPopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingpeopleVaccinated
FROM PortoflioProject..CovidDeaths$ dea
JOIN PortoflioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT * ,(RollingPeopleVaccinated/Population)*100 as RollingVaccinationPercentage
FROM #PercentPopulationvaccinated

--CREATE VIEW
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingpeopleVaccinated
FROM PortoflioProject..CovidDeaths$ dea
JOIN PortoflioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

select* from PercentPopulationVaccinated

 