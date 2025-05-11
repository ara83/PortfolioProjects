
--query starts

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--total cases vs total deaths
--Likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'India'
ORDER BY 1,2

--Looking at total cases vs population
--Percentage of population got covid 
SELECT location,date,total_cases,total_deaths,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'India'
ORDER BY 1,2

--Country with highest infection rate 
SELECT location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Group By location,population
ORDER BY PercentPopulationInfected Desc


----Country with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount,MAX((total_deaths/population))*100 as PercentPopulationDeath
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
Group By location
ORDER BY HighestDeathCount Desc

----Considering continent
--Showing continent with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is NOT NULL
Group By continent
ORDER BY HighestDeathCount Desc

--Global numbers

SELECT SUM(new_cases) as Totalnewcase, SUM(CAST(new_deaths as INT)) as TotalDeath, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where continent is NOT NULL
--Group By date
ORDER BY 1,2

--JOINS
--total populaton vs vacination
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3



---USE by CTE
With PopvsVac(continent,location,date,population, new_vaccinations, rollingpeoplevaccinated)as 
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(rollingpeoplevaccinated/population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric(20,0),
new_vaccinations numeric(20,0),
rollingpeoplevaccinated numeric(20,0)
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *,(rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated


---Creating view for data visualisation

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated




