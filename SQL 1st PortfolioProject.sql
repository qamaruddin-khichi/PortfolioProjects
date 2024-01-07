--Data Sets For the Project

SELECT *
FROM PortfolioProjects.dbo.CovidVaccinations$

SELECT *
FROM PortfolioProjects.dbo.CovidDeaths$

-- Selecting the data that I am going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects.dbo.CovidDeaths$
Where continent IS NOT NULL
ORDER BY location, date

-- Looking at Total Cases VS Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProjects.dbo.CovidDeaths$
Where continent IS NOT NULL
ORDER BY location, date

-- Looking at Total Cases VS Population
-- Shows what Percentage of Population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CovidInfactedPercentage 
FROM PortfolioProjects.dbo.CovidDeaths$
Where continent IS NOT NULL
ORDER BY location, date

--Looking at countries with Higest Infection Rate compared to total population

SELECT location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases/population))*100
	AS CovidInfactedPercentage 
FROM PortfolioProjects.dbo.CovidDeaths$
GROUP BY location, population
ORDER BY CovidInfactedPercentage DESC

-- Showing countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjects.dbo.CovidDeaths$		
Where continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--Explore things by Continent

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjects.dbo.CovidDeaths$		
Where continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continent with the Higest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProjects.dbo.CovidDeaths$		
Where continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Let's Explore the Global Numbers

SELECT date, new_cases, total_cases
FROM PortfolioProjects.dbo.CovidDeaths$
Where continent IS NOT NULL
ORDER BY new_cases DESC, total_cases DESC


-- Total Population VS Total Vaccination

SELECT Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations,
SUM(Convert(int,Vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY Death.location, Death.date)
	AS RollingPeopleVaccinated
FROM PortfolioProjects.dbo.CovidDeaths$ AS Death
JOIN PortfolioProjects.dbo.CovidVaccinations$ AS Vaccine
ON Death.location = Vaccine.location
AND Death.date = Vaccine.date
WHERE Death.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE

WITH POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations,
SUM(Convert(int,Vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY Death.location, Death.date)
	AS RollingPeopleVaccinated
FROM PortfolioProjects.dbo.CovidDeaths$ AS Death
JOIN PortfolioProjects.dbo.CovidVaccinations$ AS Vaccine
ON Death.location = Vaccine.location
AND Death.date = Vaccine.date
WHERE Death.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM POPvsVAC

-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccined numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations,
SUM(Convert(int,Vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY Death.location, Death.date)
	AS RollingPeopleVaccinated
FROM PortfolioProjects.dbo.CovidDeaths$ AS Death
JOIN PortfolioProjects.dbo.CovidVaccinations$ AS Vaccine
ON Death.location = Vaccine.location
AND Death.date = Vaccine.date
--WHERE Death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Create View to store data for later visulalization

CREATE VIEW PercentPopulationVaccinated AS
SELECT Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations,
SUM(Convert(int,Vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY Death.location, Death.date)
	AS RollingPeopleVaccinated
FROM PortfolioProjects.dbo.CovidDeaths$ AS Death
JOIN PortfolioProjects.dbo.CovidVaccinations$ AS Vaccine
ON Death.location = Vaccine.location
AND Death.date = Vaccine.date
WHERE Death.continent IS NOT NULL
--ORDER BY 2,3
