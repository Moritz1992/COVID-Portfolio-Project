/* 
Nicholas Moritz
09/01/2021

SURVEYING Data in SQL Queries
Importing Data using OPENROWSET

Here we are looking to see what is going on with infection rates and deaths happening with COVID. Please be safe out there ladies and gentlemen!

Heres a link to my tableau after going through all the data! https://public.tableau.com/app/profile/nicholas.moritz/viz/CovidDashboardPortfolio_16306018213200/Dashboard1

*/





select *
From PortfolioProject..CovidVaccinations
Where continent is not NULL 
Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not NULL 
Order by 1,2

-- My aim is to connect deaths with the first cases just to have some refrence to go by right now (Total cases vs Total Deaths)

Select Location, date, total_cases, (total_deaths/total_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population to see what percent of population got covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as Percentage_of_Covid 
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as Percentage_of_Covid
From PortfolioProject..CovidDeaths
Where continent is not NULL 
Group by Location, Population
order by Percentage_of_Covid DESC

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL 
Group by Location
order by TotalDeathCount DESC

-- Now to look at each continent with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL 
Group by Location
order by TotalDeathCount DESC

-- layers created for drill down in vizualiztion

-- Global Numbers of covid from when it began

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(New_Cases)*100 as GloabalDeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- OVERALL death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(New_Cases)*100 as GloabalDeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Surveying the total population vs vaccinations

Select * 
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- USING CTE here

With PopvsVac (Continent, Loaction, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PopvsVac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view Percentofvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From Percentofvaccinated
