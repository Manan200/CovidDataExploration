Select * from DataExploration..CovidDeaths
order by location, date


-- Comparing Total Deaths and Total Cases
-- Shows the likely chance of dying if you caught covid in your country
Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from DataExploration..CovidDeaths
where location = 'India'
order by 1,2

-- Analyzing percentage of populated infected with covid for a particular country
Select location,date, total_cases, population, (total_cases/population)*100 as PercentageInfected
from DataExploration..CovidDeaths
where location = 'India'
order by 1,2

-- Looking at countries with highest infected rate compared to their population

Select location,Population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentageInfected
from DataExploration..CovidDeaths
Group by location, population
order by PercentageInfected desc

-- Showing Countries with highest death rate
Select location, Max(cast(total_deaths as int)) as HighestDeathCount
from DataExploration..CovidDeaths
where continent is not null
Group by location
order by HighestDeathCount desc

-- Showing Continents with highest death rate
Select location, Max(cast(total_deaths as int)) as HighestDeathCount
from DataExploration..CovidDeaths
where continent is null
Group by location
order by HighestDeathCount desc


-- Showing Continents with highest death count for a particular country
Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
from DataExploration..CovidDeaths
where continent is not null
Group by continent
order by HighestDeathCount desc

--Checking Global numbers on each individual Date
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from DataExploration..CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking at Total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from DataExploration..CovidDeaths dea 
join DataExploration..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE
With PopVsVac as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from DataExploration..CovidDeaths dea 
join DataExploration..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac



-- use Temp Table

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from DataExploration..CovidDeaths dea 
join DataExploration..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated



-- Crwating view to store data for later visualizations

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from DataExploration..CovidDeaths dea 
join DataExploration..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * from PercentagePopulationVaccinated