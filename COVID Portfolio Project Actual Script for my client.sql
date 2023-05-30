Select * 
from MyPortfolioProject..COVIDeath$
Where Continent is not null

Select Location,date,total_cases,new_cases,total_deaths, Population
from MyPortfolioProject..COVIDeath$
ORDER BY 1,2


--looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you get infected by COVID
Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)* 100 as DeathPopulation
from MyPortfolioProject..COVIDeath$
Where Location Like '%Nigeria%'
ORDER BY 1,2


--Looking at Total Cases Vs Population
--Shows what percentage of population got COVID
Select Location,date,population,total_cases, (total_cases/population) as PercentPopulationInfected
from MyPortfolioProject..COVIDeath$
Where Location Like '%Nigeria%'
ORDER BY 1,2


--Looking at Countries with Highest infection rate compared to population

Select Location,population, max(total_cases)as HighestInfectionCount, max(total_deaths/population)*100 as PercentPopulationInfected
from MyPortfolioProject..COVIDeath$ 
--Where Location Like '%Nigeria%'
Group by Location,population
ORDER BY PercentPopulationInfected desc


--Showing Countries with Highest Deathcount Per Population

Select Location, max(total_deaths) as TotalDeathCount
from MyPortfolioProject..COVIDeath$ 
--Where Location Like '%Nigeria%'
Where Continent is not null
Group by Location
ORDER BY TotalDeathCount desc

--Lets break things down by Continent
Select continent, max(total_deaths) as TotalDeathCount
from MyPortfolioProject..COVIDeath$ 
--Where Location Like '%Nigeria%'
Where Continent is not null
Group by continent
ORDER BY TotalDeathCount desc




--Showing continent with the Highest DeathCount Per Population
Select Continent,Max(cast(total_deaths as int)) as TotalDeathCount
from MyPortfolioProject..COVIDeath$
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount DESC


--Global Numbers 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From MyPortfolioProject..COVIDeath$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select *
From MyPortfolioProject..COVIDeath$ DEA
Join MyPortfolioProject..COVIDVacination$ VAC
on DEA.location=  VAC.location
and DEA.date = VAC.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..COVIDeath$ dea
Join MyPortfolioProject..COVIDVacination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.location, DEA.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..COVIDeath$ DEA
Join MyPortfolioProject..CovidVacination$ VAC
	On DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..COVIDeath$ dea
Join MyPortfolioProject..COVIDVacination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From MyPortfolioProject..COVIDeath$ DEA
Join MyPortfolioProject..COVIDVacination$ VAC
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select* 
from PercentPopulationVaccinated

