USE PortfolioProject;

SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4;

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

SELECT Location, Date, total_cases, total_deaths, (total_deaths * 1.0/total_cases) * 100.0 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2;

SELECT Location, Date, Population, total_cases, (total_cases * 1.0/population) * 100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases * 1.0/population)) * 100 as HighestInfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY HighestInfectedPercentage DESC;

SELECT Location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, sum(new_deaths) * 1.0/SUM(new_cases) * 100 AS DeathPercentage--, total_deaths, (total_deaths * 1.0/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases <> 0
--GROUP BY date
ORDER BY 1,2;


SELECT *
FROM 
	PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date
;

WITH PopsVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..CovidVaccinations vac
	ON 
		dea.date = vac.date
		AND
		dea.location = vac.location
WHERE
	dea.continent IS NOT NULL
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated * 1.0/Population) * 100
FROM PopsVsVac;

drop table if exists #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..CovidVaccinations vac
	ON 
		dea.date = vac.date
		AND
		dea.location = vac.location
WHERE
	dea.continent IS NOT NULL
;

SELECT *, (RollingPeopleVaccinated * 1.0/Population) * 100
FROM #PercentPopulationVaccinated;	


CREATE View PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM 
		PortfolioProject..CovidDeaths dea
		JOIN
		PortfolioProject..CovidVaccinations vac
		ON 
			dea.date = vac.date
			AND
			dea.location = vac.location
	WHERE
		dea.continent IS NOT NULL
;

SELECT * 
FROM PortfolioProject.dbo.PercentPopulationVaccinated;
