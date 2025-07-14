SELECT
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths)/SUM(total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

SELECT
	location,
	SUM(new_deaths) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
	AND location NOT IN ('World', 'High-income countries', 'Upper-middle-income countries', 'European Union (27)', 'Lower-middle-income countries', 'Low-income countries')
GROUP BY location
ORDER BY 2 DESC;

SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY
	location,
	population
ORDER BY 4 DESC

SELECT
	location,
	population,
	date,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY
	location,
	population,
	date
ORDER BY 5 DESC

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- SELECT *
-- FROM PortfolioProject..CovidVaccinations
-- ORDER BY 3,4

-- Selected Data to use
SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Viewing Total Cases vs. Total Deaths
-- Likelhood of death if positive with covid in county
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/NULLIF(total_cases,0))*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Viewing Total Cases vs. Population
-- Viewing percentage of population contracting Covid
SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS case_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Viewing countries with highest infection rate compared to population
SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population)*100) AS highest_case_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY
	location,
	population
ORDER BY 4 DESC;

-- Viewing by continent with highest death count
SELECT
	continent,
	MAX(total_deaths) AS highest_death_count,
	MAX((total_deaths/population)*100) AS highest_death_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

-- Global Numbers
SELECT 
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
-- HAVING SUM(new_cases) > 0
ORDER BY 1, 2;

-- Viewing Population vs. Vaccinations
SELECT
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinations
--	(rolling_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths AS cd
	JOIN PortfolioProject..CovidVaccinations AS cv
		ON cd.location = cv.location
			AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE
WITH PopVSVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
	AS (
		SELECT
			cd.continent,
			cd.location,
			cd.date,
			cd.population,
			cv.new_vaccinations,
			SUM(cast(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinations
--			(rolling_vaccinations/population)*100
		FROM PortfolioProject..CovidDeaths AS cd
			JOIN PortfolioProject..CovidVaccinations AS cv
				ON cd.location = cv.location
					AND cd.date = cv.date
		WHERE cd.continent IS NOT NULL
--		ORDER BY 2, 3
		)
SELECT *, (rolling_vaccinations/population)*100
FROM PopVSVac

-- Using TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
	(continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_vaccinations numeric
	)
INSERT INTO PercentPopulationVaccinated
		SELECT
			cd.continent,
			cd.location,
			cd.date,
			cd.population,
			cv.new_vaccinations,
			SUM(cast(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinations
--			(rolling_vaccinations/population)*100
		FROM PortfolioProject..CovidDeaths AS cd
			JOIN PortfolioProject..CovidVaccinations AS cv
				ON cd.location = cv.location
					AND cd.date = cv.date
--		WHERE cd.continent IS NOT NULL
--		ORDER BY 2, 3
SELECT *, (rolling_vaccinations/population)*100
FROM PercentPopulationVaccinated

-- Creating VIEW to store data for visualization
CREATE VIEW Percent_PopulationVaccinated AS
	SELECT
		cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinations
	--			(rolling_vaccinations/population)*100
	FROM PortfolioProject..CovidDeaths AS cd
		JOIN PortfolioProject..CovidVaccinations AS cv
			ON cd.location = cv.location
				AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	--		ORDER BY 2, 3

SELECT *
FROM Percent_PopulationVaccinated
ORDER BY location