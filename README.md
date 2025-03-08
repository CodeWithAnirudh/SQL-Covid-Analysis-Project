/*
=============================================================
📊 COVID-19 Death Analysis - SQL Portfolio Project
=============================================================

Welcome to the **COVID-19 Death Analysis** SQL project.  
This project involves analyzing **COVID-19 cases, deaths, population impact, and vaccinations**.  
We use **joins, window functions, CTEs, temp tables, and views** for advanced analysis.

🚀 **Technologies Used**: MySQL, SQL Queries, Joins, Window Functions, CTEs.

=============================================================
🔹 DATASETS:
    1️⃣ `coviddeaths` - Contains data on COVID-19 cases and deaths.
    2️⃣ `covidvaccinations` - Contains vaccination details by country.
=============================================================
*/

-- =========================================================
-- 🔹 Step 1: Explore the Data
-- =========================================================

-- Preview the `coviddeaths` dataset
SELECT * FROM coviddeaths;

-- Preview the `covidvaccinations` dataset
SELECT * FROM covidvaccinations;

-- =========================================================
-- 📊 Step 2: Total Cases vs Total Deaths
-- =========================================================

-- ✅ Check the total cases, new cases, total deaths, and population
SELECT location, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY location, total_cases;

-- ✅ Calculate the Death Percentage for each location
SELECT location, total_cases, new_cases, total_deaths, population, 
       (total_deaths / total_cases) * 100 AS death_percentage
FROM coviddeaths
WHERE location LIKE '%states%'
ORDER BY location, total_cases;

-- =========================================================
-- 📊 Step 3: Total Cases vs Population
-- =========================================================

-- ✅ Find percentage of population infected
SELECT location, new_cases, population, total_cases, 
       (total_cases / population) * 100 AS percent_population_infected
FROM coviddeaths
ORDER BY location, total_cases;

-- ✅ Find countries with the highest infection rates
SELECT location, population, MAX(total_cases) AS highest_infection_count, 
       MAX((total_cases / population)) * 100 AS percent_population_infected
FROM coviddeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- =========================================================
-- 📊 Step 4: Countries with Highest Death Count
-- =========================================================

-- ✅ Find countries with the highest death count
SELECT location, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- ✅ Find the continent with the highest total deaths
SELECT continent, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- =========================================================
-- 📊 Step 5: Global COVID-19 Impact
-- =========================================================

-- ✅ Get total global cases, deaths, and death percentage by location
SELECT location, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
       (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location, total_cases;

-- ✅ Get total global cases, deaths, and overall death percentage
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
       (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL;

-- =========================================================
-- 📊 Step 6: Vaccination Analysis (Total Population vs Vaccinations)
-- =========================================================

-- ✅ Join `coviddeaths` and `covidvaccinations` to analyze vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

-- ✅ Use a window function to calculate cumulative vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS people_vaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

-- =========================================================
-- 📊 Step 7: Using Common Table Expressions (CTEs)
-- =========================================================

WITH pop_vs_vac AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS people_vaccinated
    FROM coviddeaths AS dea
    JOIN covidvaccinations AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (people_vaccinated / population) * 100 AS percent_population_vaccinated
FROM pop_vs_vac;

-- =========================================================
-- 📊 Step 8: Using Temporary Tables
-- =========================================================

-- ✅ Create a temporary table for vaccination analysis
CREATE TEMPORARY TABLE pop_vs_vac (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    people_vaccinated NUMERIC
);

-- ✅ Insert data into the temporary table
INSERT INTO pop_vs_vac (continent, location, date, population, new_vaccinations, people_vaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS people_vaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- ✅ Retrieve data from the temporary table
SELECT *, (people_vaccinated / population) * 100 AS percent_population_vaccinated
FROM pop_vs_vac;

-- =========================================================
-- 📊 Step 9: Creating a View for Future Analysis
-- =========================================================

CREATE OR REPLACE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS people_vaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- ✅ Retrieve data from the view
SELECT * FROM percent_population_vaccinated;

