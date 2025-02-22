-- PORTFOLIO PROJECT

select * from coviddeaths;
select * from covidvaccinations;

select location, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths

select location, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like '%states%'
order by 1,2;


-- Looking at Total Cases vs Population

select location,  new_cases, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from coviddeaths
-- where location like '%states%'
order by 1,2;

-- Looking at Countries with HIghest Infected Rate Compared to Population

select location, population, max(total_cases) as Highest_infection_count, 
max((total_cases/population))*100 as percent_population_infected
from coviddeaths
group by location, population
order  by percent_population_infected desc;

-- Showing Countries with HIgest Death Count per Population 

select location, max(total_deaths) as Total_death_count
from coviddeaths
where continent is not null
group by location
order by Total_death_count desc;

-- Showing continent with higest death count per population


select continent, max(total_deaths) as Total_death_count
from coviddeaths
where continent is not null
group by continent
order by Total_death_count desc;


-- Global Numbers

-- All the Cases and Deaths by Loaction wise

select location, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
from coviddeaths
where continent is not null
group by location
order by 1,2;

-- All the Total cases , Total deaths and Death percentage

select  SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
from coviddeaths
where continent is not null
order by 1,2;

-- LOoking at Total Population vs Vaccinations

-- Using JOIN

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolio_project.coviddeaths as dea
join portfolio_project.Covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Using OVER BY PARTITION

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as People_vaccinated
from portfolio_project.coviddeaths as dea
join portfolio_project.Covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- USING CTE

with popvsvac (continent, location, date, population, new_vaccinations, people_vaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as People_vaccinated
from portfolio_project.coviddeaths as dea
join portfolio_project.Covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select * ,(people_vaccinated/population)*100
from popvsvac;


-- Creating Temporary table

create table popvsvac
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
);
insert into popvsvac (continent, location, date, population, new_vaccinations, people_vaccinated)

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as People_vaccinated
from portfolio_project.coviddeaths as dea
join portfolio_project.Covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

select * ,(people_vaccinated/population)*100
from popvsvac;


-- Creating View to store data for later visualizations

create view percentpopulationvaccinated as

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as People_vaccinated
from portfolio_project.coviddeaths as dea
join portfolio_project.Covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;


select * 
from percentpopulationvaccinated;











