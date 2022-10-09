--https://ourworldindata.org/covid-deaths

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs. total deaths
--shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like 'India'
and continent is not null
order by 1,2



-- Looking at total cases vs population
--shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
--where Location like 'India'
where continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population
select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where Location like 'India'
where continent is not null
group by location,population
order by PercentagePopulationInfected desc


--Showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where Location like 'India'
where continent is not null
group by location
order by TotalDeathCount desc



--break up by continent (as per video)
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where Location like 'India'
where continent is not null
group by continent
order by TotalDeathCount desc


--Showing the continents with  highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where Location like 'India'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, 
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking at total population vs vaccinations
with PopvsVac (continent, location, date,population,new_vaccination, RollingPeopleVaccinated )
as
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3 *The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.
)
select *,  (RollingPeopleVaccinated/population)*100 from PopvsVac


--using  temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null

select *,  (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


--creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null

