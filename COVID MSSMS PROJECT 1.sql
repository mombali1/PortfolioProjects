/*covid-19 our world in data and will be used for google data analytics project 

types of tables used, Join, Temp table, windows fucntion, aggregates, view, data type casting

 look at everything in tables
157,476 rows
*/

SELECT *
FROM PortfolioProject..CovidDeaths
--WHERE CONTINENT IS NULL
ORDER BY 3,4;


 SELECT *
FROM CovidVaccinations
--WHERE continent is null
ORDER BY 3,4;

--148,014 rows
SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.Continent IS  NOT NULL
ORDER BY  3,4

 

-- select data from table for queries

SELECT Location, Date, Total_cases, 
new_cases, total_deaths, population
FROM CovidDeaths

--TOTAL CASES VS TOTAL DEATHS
--COVID DEATH RATE, OVER TIME, BY COUNTRY

SELECT Location, Date, Total_cases, total_deaths, 
ROUND((TOTAL_DEATHS/total_cases)*100, 3) AS DeathPercentage
FROM CovidDeaths
--WHERE Location LIKE '%states'
ORDER BY 1,2

-- looking at the total cases vs population
--SHOWS INFECTION RATE AS PERCENTAGE OF POPULATION, OVER TIME, BY COUNTRY

SELECT Location, Date, Total_cases, population,
ROUND((total_cases/population)*100,3) as infection_rate
FROM CovidDeaths
--WHERE LOCATION LIKE '%STATES'
ORDER BY 1,2

--MOST INFECTIONS BY COUNTRY FROM START OF DATA OLLECTION, AND THE INFECTION RATE BY POPULATION

SELECT Location, MAX(Total_cases) HighestInfectionCount, population,
ROUND(MAX((total_cases/population))*100,3) as infection_rate
FROM portfolioproject..CovidDeaths
--WHERE LOCATION LIKE '%STATES'
GROUP BY population, location
ORDER BY 1

-- showing most deaths per population by country

--DEATHS BY REGION

SELECT continent, MAX(CAST(total_deaths as int)) TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%STATES'
WHERE Continent IS NOT NULL 
GROUP BY Continent
ORDER BY TotalDeathsCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NOT NULL
ORDER BY 1,2

-- TOTAL POPULATION VS VACCINATED


SELECT DEA.CONTINENT,DEA.LOCATION, DEA.DATE,DEA.POPULATION,VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS BIGINT))  OVER 
(PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLINGVACCINATIONS
FROM PortfolioProject..COVIDDEATHS DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.LOCATION=VAC.location
AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL AND DEA.LOCATION LIKE '%STATES'
ORDER BY 2,3

--CTE

WITH NvacVsVac (CONTINENT, LOCATION, DATE, POPULATION, new_vaccinations, ROLLINGVACCINATIONS)
AS 
(
SELECT DEA.CONTINENT,DEA.LOCATION, DEA.DATE, DEA.POPULATION, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS BIGINT))  OVER 
(PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLINGVACCINATIONS
FROM PortfolioProject..COVIDDEATHS DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.LOCATION=VAC.location
AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL and dea.location like'united%'
--ORDER BY 2,3
)
SELECT *,ROUND((ROLLINGVACCINATIONS/POPULATION)*100,3) as '% of populaion vacinated'
FROM NvacVsVac
ORDER BY 2,3


--TEMP TABLE
DROP TABLE IF EXISTS PERCENTPOPULATIONVACCINATED
CREATE TABLE PERCENTPOPULATIONVACCINATED
(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATIONS NUMERIC,
ROLLINGVACCINATIONS NUMERIC
)
INSERT INTO PERCENTPOPULATIONVACCINATED
SELECT DEA.CONTINENT,DEA.LOCATION, DEA.DATE,DEA.POPULATION,VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS BIGINT))  OVER 
(PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE)AS ROLLINGVACCINATIONS
 --(ROLLINGVACCINATIONS/POPULATION)*100
FROM PortfolioProject..COVIDDEATHS DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.LOCATION=VAC.location
AND DEA.DATE=VAC.DATE
--WHERE DEA.CONTINENT IS NOT NULL 
--ORDER BY 2,3

SELECT *--,(ROLLINGVACCINATIONS/POPULATION)*100
FROM PERCENTPOPULATIONVACCINATED


-- CREATING VIEW FOR DATA VIZUALTISATION

CREATE VIEW #PERCENTPOPULATIONVACCINATED AS 
SELECT DEA.CONTINENT,DEA.LOCATION, DEA.DATE,DEA.POPULATION,VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS BIGINT))  OVER 
(PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE)AS ROLLINGVACCINATIONS
 --(ROLLINGVACCINATIONS/POPULATION)*100
FROM PortfolioProject..COVIDDEATHS DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.LOCATION=VAC.location
AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL 
--ORDER BY 2,3



--num of records for every location

SELECT LOCATION, COUNT(LOCATION) NUMRECORDS
FROM COVIDDEATHS
GROUP BY LOCATION
ORDER BY 2 DESC
