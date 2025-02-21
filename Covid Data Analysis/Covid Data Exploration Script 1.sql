select * from CovidDeaths;
select 
	location, date, total_cases, new_cases, total_deaths, population
from 
	CovidDeaths
order by 1,2;

--looking at total cases vs total deaths
select 
	location,
	sum(total_cases) as total_cases_per_location,
	sum(total_deaths) as total_deaths_per_location
from 
	CovidDeaths 
group by 1
;

select 
	location, 
	date,
	total_cases,
	total_deaths,
	round((total_deaths/total_cases)*100,2) as DeathPercentage
from 
	CovidDeaths 
;

--looking at totalcases vs population
select 
	location, 
	date,
	total_cases,
	population,
	round((total_cases/population)*100,2) as InfectionRate
from 
	CovidDeaths

;

--looking at countries with highest infection rate
select 
	location,
	round((total_cases/population * 100),2) as InfectionRate
from 
	CovidDeaths 
group by 1
order by InfectionRate desc;

--showing countries with highest death rate per population
select 
	location,
	max(cast(total_deaths as int)) as totalDeathCount
from 
	CovidDeaths
where continent!= ''
group by 1
order by totalDeathCount desc;


--showing continents with highest death count
select 
	continent,
	sum(cast (total_deaths as int)) as totalDeathCount
from 
	CovidDeaths 
where 
	continent!= ''
group by 1
order by totalDeathCount desc;

---
create view PeopleVaccinated as
select 
dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, sum(cast(new_vaccinations as int))over(partition by dea.location order by dea.date) as total_rolling_vaccinations
from 
CovidDeaths dea join CovidVaccinations vacc 
on dea.location  = vacc.location 
and dea.date = vacc.date
where dea.continent != ''
order by 1,2,3


