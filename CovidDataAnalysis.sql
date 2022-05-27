SELECT * FROM dbo.Covidvaccinations ORDER BY 5 DESC;

SELECT * FROM dbo.CovidDeaths ORDER BY 8 DESC;

DROP TABLE dbo.CovidVaccination

CREATE DATABASE CovidData

SELECT * FROM dbo.CovidVaccination;

SELECT Location, Population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS RateOfDeath
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 5 DESC;

SELECT Location, Population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population)*100) AS RateOfInfection
FROM CovidDeaths
--WHERE location = ('United States')
GROUP BY Location, population
ORDER BY RateOfInfection DESC;

SELECT continent, Population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population)*100) AS RateOfInfection
FROM CovidDeaths
--WHERE location = ('United States')
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY RateOfInfection DESC;

SELECT continent, SUM(population) AS Population
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Population DESC;

SELECT continent, TotalPopulation, NumberOfDeath, (NumberOfDeath/TotalPopulation)*100 AS DeathRate
FROM (
	SELECT continent, SUM(population) AS TotalPopulation, SUM(CAST(total_deaths AS int)) AS NumberOfDeath
	FROM CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY continent) X
ORDER BY DeathRate DESC;


WITH PopVac (continent, location, date, population, new_vaccinations, TotalVacByLoc)
AS (
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(int, V.new_vaccinations)) OVER (PARTITION BY D.Location ORDER BY D.Location, D.date) AS TotalVacByLoc
FROM CovidDeaths D
JOIN CovidVaccinations V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL)
SELECT *, (TotalVacByLoc/population)*100 AS RateOfVaccine 
FROM PopVac
--WHERE location = 'Nigeria';


SELECT *, (TotalVacByLoc/population)*100 AS RateOfVaccine
FROM (
	SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(CONVERT(int, V.new_vaccinations)) OVER (PARTITION BY D.Location ORDER BY D.Location, D.date) AS TotalVacByLoc
	FROM CovidDeaths D
	JOIN CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
	WHERE D.continent IS NOT NULL) Z;

SELECT DISTINCT Location FROM CovidVaccinations ORDER BY location;

DROP TABLE PercentPopVac;

CREATE TABLE PercentPopVac 
(Continent nvarchar, 
Location nvarchar, 
Date datetime, 
Population numeric, 
New_Vaccinations numeric,
TotalVacByLoc numeric)

INSERT INTO PercentPopVac
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(int, V.new_vaccinations)) OVER (PARTITION BY D.Location ORDER BY D.Location, D.date) AS TotalVacByLoc
FROM CovidDeaths D
JOIN CovidVaccinations V
ON D.location = V.location
AND D.date = V.date
--WHERE D.continent IS NOT NULL

SELECT * FROM PercentPopVac;

CREATE VIEW RateOfVaccine AS
SELECT *, (TotalVacByLoc/population)*100 AS RateOfVaccine
FROM (
	SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
	SUM(CONVERT(int, V.new_vaccinations)) OVER (PARTITION BY D.Location ORDER BY D.Location, D.date) AS TotalVacByLoc
	FROM CovidDeaths D
	JOIN CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
	WHERE D.continent IS NOT NULL) Z;
