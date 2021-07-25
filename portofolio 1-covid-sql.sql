select * 
From [portofolio project]..[covid death]
where continent is not null
order by 3,4

--select * 
--From [portofolio project]..covidVaccine
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [portofolio project]..[covid death]
order by 1,2

-------------------------------------
--total cases vs total death

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [portofolio project]..[covid death]
where location like '%indonesia%'
and continent is not null
order by 1,2

--total cases vs population 
Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From [portofolio project]..[covid death]
where location like '%indonesia%'
and continent is not null
order by 1,2

--country with highest infected rate compared with population
Select location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From [portofolio project]..[covid death]
--where location like '%indonesia%'
where continent is not null
Group by location, population 
order by PercentPopulationInfected desc

--continent with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [portofolio project]..[covid death]
--where location like '%indonesia%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- country with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [portofolio project]..[covid death]
--where location like '%indonesia%'
where continent is null
Group by location 
order by TotalDeathCount desc
 

--global numbers

Select sum(new_cases) as total_chases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [portofolio project]..[covid death]
--where location like '%indonesia%'
where continent is not null
--group by date
order by 1,2

--total population vs vaccinatnion
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from [portofolio project]..[covid death] dea
join [portofolio project]..covidVaccine vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
order by 2,3

--cte

with popvsvac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from [portofolio project]..[covid death] dea
join [portofolio project]..covidVaccine vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From popvsvac


--using temp table performing calculation partition by previous query
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from [portofolio project]..[covid death] dea
join [portofolio project]..covidVaccine vac
	on dea.location = vac.location
	and dea.date = vac. date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [portofolio project]..[covid death] dea
join [portofolio project]..covidVaccine vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null

select *
from PercentPopulationVaccinated