SELECT * 
FROM 
	PortfolioProject.dbo.CovidDeaths
WHERE 
	continent is not null 
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--SELECT Data that we are going to be using 


SELECT 
	Location, date, 
	total_cases, new_cases,
	total_deaths, population
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent is not null
ORDER BY 
	1, 2



-- Looking at Total Cases vs Total Deaths 
-- Shows the percentage of people who died from Covid in each country
CREATE VIEW 
	death_percentage_by_country AS
SELECT 
	Location, 
	SUM(CAST(total_cases AS bigint)) AS total_cases, SUM(CAST(total_deaths AS bigint)) AS total_deaths, 
	SUM(CAST(total_deaths AS float)) / SUM(CAST(total_cases AS float))*100 AS death_percentage
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL 
	AND total_deaths IS NOT NULL 
	AND total_cases IS NOT NULL
	-- AND location LIKE '%states%'
GROUP BY 
	location






-- Looking at Total Cases vs Population 
-- Show what percentage of population has gotten Covid

SELECT 
	Location, date, population,
	total_cases, (total_cases / population)*100 AS population_infection_percentage
FROM 
	PortfolioProject..CovidDeaths
-- WHERE location like '%states%' 
ORDER BY 
	1, 2


-- Looking at countries with highest infection rate compared to population
CREATE VIEW	
	country_infect_percentage AS
SELECT 
	Location, population,
	MAX(total_cases) AS highest_infection_count, MAX((total_cases / population))*100 AS population_infection_percentage
FROM 
	PortfolioProject..CovidDeaths
-- WHERE location like '%states%' 
GROUP BY
	Location,
	population
-- ORDER BY population_infection_percentage DESC


--Showing Countries with Highest Death Count 

SELECT 
	 Location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM 
	PortfolioProject..CovidDeaths 
WHERE 
	continent is not null -- AND location like '%states%'
GROUP BY
	location
ORDER BY 
	total_death_count DESC


-- NOW let's break things down by continent 
-- Showing contintents with the highest death count 

SELECT 
	 continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM 
	PortfolioProject..CovidDeaths 
WHERE 
	continent is not null 
GROUP BY
	continent
ORDER BY 
	total_death_count DESC


-- Global Numbers

SELECT 
	 SUM(new_cases) AS total_cases,
	 SUM(CAST(new_deaths AS int)) AS total_deaths,
	 SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent is not null
-- GROUP BY date
ORDER BY 
	1, 2


--Looking at Total Population vs Vaccinations

-- USE CTE

WITH Pop_vs_Vac (continent, location, date, population, new_vaccinations, rolling_vacc_count)
AS 
(
SELECT 
	dea.continent, dea.location,
	dea.date, dea.population,
	vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vacc_count
FROM
	PortfolioProject..CovidDeaths AS dea
INNER JOIN 
	PortfolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE 
	dea.continent is NOT null 
-- ORDER BY 2,3
)
SELECT 
	*, (rolling_vacc_count/population)*100 AS rolling_vacc_percentage 
FROM
	Pop_vs_Vac


-- TEMP TABLE 

DROP TABLE IF exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vacc_count numeric
)

INSERT INTO 
	#Percent_Population_Vaccinated
SELECT 
	dea.continent, dea.location,
	dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vacc_count
FROM
	PortfolioProject..CovidDeaths AS dea
INNER JOIN 
	PortfolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
-- WHERE dea.continent is NOT null 
-- ORDER BY 2,3

SELECT 
	* 
FROM
	#Percent_Population_Vaccinated



-- Creating View to store data for later Visulizations 

CREATE VIEW 
	Percent_Population_Vaccinated AS
SELECT 
	dea.continent, dea.location,
	dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vacc_count
FROM
	PortfolioProject..CovidDeaths AS dea 
INNER JOIN 
	PortfolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is NOT null 
-- ORDER BY 2,3

SELECT 
	*
FROM 
	death_percentage_by_country
WHERE
	location LIKE '%states%'

-- USE SOME OF THE QUERIES WE HAVE CREATED AS VIEWS FOR VISUAL