/*
Covid-19 Exploartion Data Analysis

Data sources: 
github.com/AlexTheAnalyst/PortfolioProjects/blob/main/CovidDeaths.xlsx, 
github.com/AlexTheAnalyst/PortfolioProjects/blob/main/CovidVaccinations.xlsx

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--Select the data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Look for Total Case vs Total Deaths
-- Shows probability of dying if you had COVID-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as [Death Percentage]
FROM PortfolioProject..CovidDeaths
WHERE location like 'Indonesia'
and continent is not null
ORDER BY 1, 2

-- Look for Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as [Covid Percentage]
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as [Covid Percentage]
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY [Covid Percentage] DESC

-- Shows countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as [Total Death]
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY [Total Death] DESC


-- ANALYZING DATA BY CONTINENT

-- Shows continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as [Total Death]
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY [Total Death] DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases)/SUM(cast(new_deaths as int))*100 as [Death Percentage]
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- Look at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent is not null
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent is not null
