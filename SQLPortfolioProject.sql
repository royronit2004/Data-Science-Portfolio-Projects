
/* CovidDeaths & CovidVaccinations */

SELECT * 
FROM [SQL Portfolio Project]..CovidDeaths
order by 3,4

--SELECT * 
--FROM [SQL Portfolio Project]..CovidVaccinations
--order by 3,4



-- We will select the data which we we will use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [SQL Portfolio Project]..CovidDeaths
order by 1,2



-- Total Cases vs Total Deaths: Finding out the percentage of people who died by covid in India

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM [SQL Portfolio Project]..CovidDeaths
Where location like '%India%'
order by 1,2



-- Finding out the percentage of people who got infected Covid in India

SELECT Location, date, total_cases, population, (total_cases/population)*100 as Infected_Percentage
FROM [SQL Portfolio Project]..CovidDeaths
Where location like '%India%'
order by 1,2



-- Finding out the countries with highest infection compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfection, Max((total_cases/population))*100 as Population_Infected_Percentage
FROM [SQL Portfolio Project]..CovidDeaths
Group by Location, Population
order by Population_Infected_Percentage desc



-- Searching the countries with Highest Death Count per Population

SELECT Location, Population, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM [SQL Portfolio Project]..CovidDeaths
Group by Location, Population
order by TotalDeathCount desc

-- The problem with the above query was that it was showing grouping of entire continents as countries, like 'World', 'South America'
-- We can fix this with the query below...

SELECT Location, Population, MAX(cast (total_deaths as int)) as Total_Death_Count
FROM [SQL Portfolio Project]..CovidDeaths
Where continent is not null
Group by Location, Population
order by Total_Death_Count desc




-- Now we will break it down by continent

SELECT continent, MAX(cast (total_deaths as int)) as Total_Death_Count
FROM [SQL Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
order by Total_Death_Count desc

-- Notice in the above query that 'North America' only seems to include the numbers from The United States and not Canada...

-- We can fix this with the query below...

SELECT location, MAX(cast (total_deaths as int)) as Total_Death_Count
FROM [SQL Portfolio Project]..CovidDeaths
Where continent is null
Group by location
order by Total_Death_Count desc



--Showing Continents with Highest Death Count per Population

SELECT continent, MAX(cast (total_deaths as int)) as Total_Death_Count
FROM [SQL Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
order by Total_Death_Count desc






-- Let's Find Out The Global Numbers Group by Date

SELECT date, Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Death_Percentage
FROM [SQL Portfolio Project]..CovidDeaths
Where continent is not null
Group By date
order by 1,2


-- Just THE GLOBAL NUMBERS

SELECT Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Death_Percentage
FROM [SQL Portfolio Project]..CovidDeaths
Where continent is not null
--Group By date
order by 1,2


-- Total Population vs Vaccinations, ordered by Continents

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [SQL Portfolio Project]..CovidDeaths dea
Join [SQL Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by continent desc


-- Now, We are going To Find out The Number of New Vaccinations Per Day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order By dea.location, dea.date) as Total_People_Vaccinated
From [SQL Portfolio Project]..CovidDeaths dea
Join [SQL Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



-- Total Population vs Vaccinations; Using Common Table Expression (CTE)

With Pop_vs_Vac (continent, location, date, population, New_Vaccinations, Total_People_Vaccinated)
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order By dea.location, dea.date) as Total_Vaccinations
From [SQL Portfolio Project]..CovidDeaths dea
Join [SQL Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (Total_People_Vaccinated/population)*100 as Percentage_Of_People_Vaccinated
From Pop_vs_Vac



-- Total Population vs Vaccinations; Using TEMP Table


Drop Table if exists #Percentage_Of_People_Vaccinated
Create Table #Percentage_Of_People_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacccinations numeric,
Total_People_Vaccinated numeric
)


Insert into #Percentage_Of_People_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order By dea.location, dea.date) as Total_Vaccinations
From [SQL Portfolio Project]..CovidDeaths dea
Join [SQL Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null


Select *, (Total_People_Vaccinated/population)*100 as Percentage_Of_People_Vaccinated
From #Percentage_Of_People_Vaccinated




-- Create View for later Data Visualizations

Create View Percentage_Of_People_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order By dea.location, dea.date) as Total_Vaccinations
From [SQL Portfolio Project]..CovidDeaths dea
Join [SQL Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * From Percentage_Of_People_Vaccinated


/*Conclude*/