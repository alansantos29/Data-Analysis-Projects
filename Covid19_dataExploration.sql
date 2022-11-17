/*
Covid Data Exploration
tools used: 
*/

/* Display all the rows and collumns which 
Covid Death's table
*/
SELECT *
FROM `CovidDeaths.xlsx - CovidDeaths`;

#Covid vaccination table
SELECT *
FROM `CovidVaccinations.xlsx - CovidVaccinations`;


/* Display rows that are not null  */
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `CovidDeaths.xlsx - CovidDeaths`
WHERE continent is not null
ORDER BY location,date;


-- The Probability of dying if infected by the virus
-- On the Africn Continent 
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 Death_Percentage
FROM `CovidDeaths.xlsx - CovidDeaths`
WHERE continent like '_fri%'  and continent is not null
ORDER BY 1,2;

-- In my South Africa
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM `CovidDeaths.xlsx - CovidDeaths`
WHERE location like 'South africa' and location is not null
ORDER BY 1,2;

-- The Percentage of people infected with the virus of Covid 19
SELECT location, date, population, total_cases, (total_cases/population)*100  Percent_PeopleInfect
FROM `CovidDeaths.xlsx - CovidDeaths`
WHERE  location like '_outh _fri%'
ORDER BY 1,2;


-- African countries with Highest Infection Rate compared to it's Population
SELECT location, population, max(total_cases) HighestInfectCount, max((total_cases/population)*100) Perc_PeopleInfenct
FROM `CovidDeaths.xlsx - CovidDeaths`
WHERE continent like '_frica' and continent is not null
GROUP BY 1,2
ORDER BY Perc_PeopleInfenct;

-- African Countries with the highesth Death Count per population
SELECT location, population, max(cast(total_deaths as decimal)) as HighestDeathCoun
FROM `CovidDeaths.xlsx - CovidDeaths`
WHERE continent like '_fri%' and continent is not null
GROUP BY 1,2
ORDER BY 3 DESC;

-- Continent with the Highest Death count per Population 
SELECT distinct continent , population, max(cast(total_deaths as decimal)) as HighestDeathCount
FROM `CovidDeaths.xlsx - CovidDeaths`
WHERE continent is not null
GROUP BY continent, population
ORDER BY 3 DESC;

-- Total Numbers (New cases, new Deaths and recent death percentage)  
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as decimal)) as total_NewDeaths, sum(cast(new_deaths as decimal))/sum(new_cases)*100 as NewDeathPercent
FROM `CovidDeaths.xlsx - CovidDeaths`
WHERE continent is not null
ORDER BY 1,2;


-- Percentage of the people that have received Covid vacine
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(v.new_vaccinations, decimal)) over (partition by d.location order by d.location, d.date) as RpeopleVacinated
FROM `CovidDeaths.xlsx - CovidDeaths` d 
JOIN `CovidVaccinations.xlsx - CovidVaccinations` v
ON d.location = v.location and d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3;


-- CTE (COMMON TABLE EXPRESSION) to perform calculation on partition by in the query above ???????????
WITH VacxPop (continent, location, date, population, new_vaccinations, RpeopleVacinated)
as
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(v.new_vaccinations, decimal)) over (partition by d.location order by d.location, d.date) as RpeopleVacinated
FROM `CovidDeaths.xlsx - CovidDeaths` d 
JOIN `CovidVaccinations.xlsx - CovidVaccinations` v
ON d.location = v.location and d.date = v.date
WHERE d.continent is not null)
SELECT *, (RpeopleVacinated/population)*100
FROM VacxPop;


-- Creating a temporary table in order to perform calculation on partion by usin the previous query
DROP TABLE if exists PpeopleVac;
CREATE TABlE PpeopleVac
(
continent varchar(255),
location varchar(255),
date datetime,
population int,
new_vaccinations int,
RpeopleVacinated int
);

INSERT INTO  PpeopleVac (continent, location, date, population, new_vaccinations, RpeopleVacinated)   #PpeopleVac Table
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(v.new_vaccinations, decimal)) over (partition by d.location order by d.location, d.date) as RpeopleVacinated
FROM `CovidDeaths.xlsx - CovidDeaths` d 
JOIN `CovidVaccinations.xlsx - CovidVaccinations` v
ON d.location = v.location and d.date = v.date;

SELECT *, (RpeopleVacinated/population*100)
FROM PpeopleVac;



-- Creating view to store data for later visualisation

CREATE VIEW PercentPeopleVacx as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(v.new_vaccinations, decimal)) over (partition by d.location order by d.location, d.date) as RpeopleVacinated
FROM `CovidDeaths.xlsx - CovidDeaths` d 
JOIN `CovidVaccinations.xlsx - CovidVaccinations` v
ON d.location = v.location and d.date = v.date
WHERE d.continent is not null;



