-- ----------------------------ASSESSING THE DATA---------------------------------------
----------------------------------------------------------------------------------------
DESCRIBE coviddeathedit;
DESCRIBE covidvaccinationsedit;

SELECT *
FROM coviddeathedit
WHERE continent IS NOT Null
ORDER BY 3,4; -- Sorts the death cases based on location and date using the column index 3 and 4--

SELECT *
FROM covidvaccinationsedit
ORDER BY 3,4; -- Sorts the vaccination data based on location and date using the column index 3 and 4--


-- -----------------------------SELECTING DATA FOR ANALYSIS----------------------------------
---------------------------------------------------------------------------------------------
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeathedit
ORDER BY 1,2;  -- Sorts the results based on location and date using the column index 1 and 2--



-- -----------------------------COMPARATIVE ANALYSIS-----------------------------------------
---------------------------------------------------------------------------------------------

-- -----------------------------Total Cases vs Total Deaths----------------------------------
SELECT continent, location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 AS death_percentage
FROM coviddeathsedit
ORDER BY 1,2; -- Sorts the result in a temporary coulmn with the aid of an "alias"---


SELECT continent, location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 AS death_percentage
FROM coviddeathedit
WHERE location LIKE '%States%' -- Filters results based on the criteria of containing "states" therein--
ORDER BY 1,2;


-- ------------Total Cases vs Population(Percentage of the Population with Covid)-----------
SELECT continent, location, date, total_cases, population, (total_cases/population)*100 AS Infected_population_percentage
FROM coviddeathedit
WHERE location LIKE '%States%' -- Filters results based on the criteria of containing "states" therein--
ORDER BY 1,2;


-- ---------Countries with High Infection Rate compared to Population-------------
SELECT continent, location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS infected_population_percentage
FROM coviddeathedit
WHERE continent IS NOT Null
GROUP BY location, population -- Arranges/Summarizes the results based on location and population
ORDER BY Infected_population_percentage DESC;


-- ------------Countries with The Highest Death Count Per Population---------------
SELECT continent, location, MAX(total_deaths) AS Total_Death_Count
FROM coviddeathedit
WHERE continent IS NOT Null
GROUP BY location -- Arranges/Summarizes the results based on location 
ORDER BY Total_Death_Count DESC;


-- -------------------Death Count Continental Breakdown------------------------
SELECT continent, MAX(total_deaths) AS Total_Death_Count
FROM coviddeathedit
WHERE continent IS NOT Null
GROUP BY continent -- Arranges/Summarizes the results based on continent
ORDER BY Total_Death_Count DESC;


-- -------------------Death Count Location Breakdown---------------------------
SELECT continent, location, MAX(total_deaths) AS Total_Death_Count
FROM coviddeathedit
WHERE continent IS NOT Null
GROUP BY location -- Arranges/Summarizes the results based on location
ORDER BY Total_Death_Count DESC;


-- -------Highest Death Count Continental Breakdown per Population--------------
SELECT continent, MAX(total_deaths) AS Total_Death_Count
FROM coviddeathedit
WHERE continent IS NOT Null
GROUP BY continent -- Arranges/Summarizes the results based on continent
ORDER BY Total_Death_Count DESC;



-- --------------------------GLOBAL NUMBERS BREAKDOWN--------------------------
-------------------------------------------------------------------------------
SELECT date, SUM(new_cases) 
FROM coviddeathedit
WHERE continent IS NOT Null
GROUP BY date -- Arranges/Summarizes the results based on date
ORDER BY 1,2;


SELECT date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM coviddeathedit
WHERE continent IS NOT Null
GROUP BY date -- Arranges/Summarizes the results based on date
ORDER BY 1,2;


SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM coviddeathedit
WHERE continent IS NOT Null
ORDER BY 1,2;


-- ---------------------Total Population Vs Vaccination-----------------------
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeathedit dea
JOIN covidvaccinationsedit vac
    ON dea.location = vac.location
    AND dea.date = vac.date;


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS continued_vaccination
FROM coviddeathedit dea
JOIN covidvaccinationsedit vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT Null
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS continued_vaccination,
(continued_vaccination/population)*100
FROM coviddeathedit dea
JOIN covidvaccinationsedit vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT Null
ORDER BY 2,3;


-- ----------------------Using CTEs-------------------------------
WITH PopvsVac(continent, location, date, population, new_vaccinations, continued_vaccination) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS continued_vaccination
FROM coviddeathedit dea
JOIN covidvaccinationsedit vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT Null
)
SELECT *, (continued_vaccination/population)*100
FROM PopvsVac;


-- ----------------Temp Table-------------------

CREATE TABLE percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
continued_vaccination numeric
);

INSERT INTO percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS continued_vaccination
FROM coviddeathedit dea
JOIN covidvaccinationsedit vac
    ON dea.location = vac.location
    AND dea.date = vac.date;
    
SELECT *, (continued_vaccination/population)*100
FROM percent_population_vaccinated;

-- --------Creating View to Store Data for a Later Reference-----------
CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS continued_vaccination
FROM coviddeathedit dea
JOIN covidvaccinationsedit vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT Null
ORDER BY 2,3;































