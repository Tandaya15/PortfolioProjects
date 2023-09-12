

SELECT*
FROM PortfolioProject..CovidDeaths   -- short cut yung "..", pwede ding MAY dbo gaya nito kasing PortfolioProject.dbo.Deaths
ORDER BY 3,4 -- eto yung columns  


SELECT*
FROM PortfolioProject..CovidDeaths   -- short cut yung "..", pwede ding MAY dbo gaya nito kasing PortfolioProject.dbo.Deaths
WHERE continent IS NOT NULL    --  BECAUSE NULL MEANS GROUPED THE COUNTRIES
ORDER BY 3,4 -- eto yung columns  



SELECT*
FROM PortfolioProject..CovidVaccinations   -- short cut yung "..", pwede ding kasing PortfolioProject.dbo.Deaths
ORDER BY 3,4 -- eto yung columns  

-- Select the Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- If from USA, put where.

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- If from Australia, put where.

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%australia%'
ORDER BY 1,2


SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%philippines%'
ORDER BY 1,2

-- Looking at total cases vs Population
-- Show what percentage of population got Covid

SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%australia%'
ORDER BY 1,2

-- Looking at Countried with Highest Infection Rate COmpared to Population

SELECT location,population, MAX(total_cases) AS HighestInfectedCount,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location,population
ORDER BY PercentagePopulationInfected DESC

SELECT location,population, MAX(total_cases) AS HighestInfectedCount,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location,population  -- need to group what is in SELECT clause so both fields
ORDER BY HighestInfectedCount DESC

-- Showing Contries with Highest Death Count Per Population
-- with data type issue on total death as categorize as nVARCHAR.

SELECT location,MAX(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Corrected to INT the total death, casting

SELECT location,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- putting WHERE continent IS NOT NULL to remove groupped location  
SELECT location,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATON
SELECT continent,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date,SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS , remove the date

SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- COVID Vaccination table

SELECT *
FROM PortfolioProject..CovidVaccinations


-- Joining Deaths and Vaccination table ON Location & Date

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date



-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- WINDOWS FUNCTION PER MYSQL
-- wthe window over which the given function evaluation will be performed

-- act as the set of rows on which the given functio will be applied


-- OVER Means the window function that sets of row which the given function will be applied
-- OVER caluse will lead to dinwo specification , to provide rank values
-- If () is empty of none, row_number will perform to all rows.
-- COntaining Partition BY will set some partitions, see sample
-- Empty () will be a single partition, representing entire data set.


-- ADDING Rolling count by using PARTITION
-- with below, no rolling count yet

SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	--SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location) --- SUM ONLY PER COUNTRY
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location) AS SumaTotal--- pwede din ito convert
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- ETO WITH ROLLING COUNT
-- BY PUTTING ORDER BY , THE DATE WILL BE THE ONE THAT WILL SEPARATE IT

SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS  RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- ETO KAHIT WALANG ORDER BY LOCATION SAME RESULT
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTEs , Alex Way.

WITH PopsVsVac (continent, location, date,population,new_vaccinations,RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *
FROM PopsVsVac

--USE CTEs , 365 wAY, WALANG FIELDS AFTER NANG NAME OF cte , SAME RESULTS DIN

WITH PopsVsVac AS(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *
FROM PopsVsVac


--USE CTEs , Alex Way.

WITH PopsVsVac (continent, location, date,population,new_vaccinations,RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopsVsVac

-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
-- KAPAG WALA NITO EH WALANG DISPLAY
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--ALTERING

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date =vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
-- KAPAG WALA NITO EH WALANG DISPLAY
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEWS

