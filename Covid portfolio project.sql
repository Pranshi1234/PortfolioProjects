USE PortfolioProject
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4
--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total casesvs totatl deaths 
--shows likelihood of dying if you contract covid in your country 
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
and continent is not null
order by 1,2

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid 

select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- looking at countries with highest infection rate compared to population

select location,population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population
order by PercentPopulationInfected desc


-- showing countries with highest death count per population

select location, MAX (cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc



-- lets break things down by continent 

select continent, MAX (cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- showing continents with highest death count per population

select continent, MAX (cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- global numbers 

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Looking At Total Population vs Vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date 
where dea.continent is not null
order by 2,3




--USE CTE

With PopVsVac(Continent ,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopVsVac



--TEMP TABLE 

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated 
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric )

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated