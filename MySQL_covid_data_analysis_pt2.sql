use corona;
select continent,location,date_register,new_cases,total_deaths, population from covid_data order by 1,2;
select * from covid_data;
/*Total cases VS Total deaths  -- LIkelyhood of dying if you got covid*/
select location,date_register,total_cases,total_deaths,(total_deaths*100/total_cases) from covid_data 
where location like '%brazil%'
order by 1,2;

/*Total cases VS population*/
select location,date_register,total_cases,total_deaths,(total_cases*100/population) as cases_pop from covid_data 
where location like '%brazil%'
order by 1,2;

/*Looking at countries with highest infection rate compared to population*/
select location,max(total_cases) as Highest_Infectiokn_count,max((total_cases*100/population)) as cases_pop from covid_data 
group by location, population
order by cases_pop;

/*Looking at countries with highest death rate compared to population*/
select location,max(total_deaths) as max_death_count,max((total_deaths*100/population)) as cases_pop from covid_data 
group by location
order by max_death_count desc;


/*Countries with highest death count*/
select location,max(Total_deaths) 	as TotalDeathCount From covid_data
where continent != ''
group by location
order by TotalDeathCount desc;

/*Break Down by Continent*/
select location,max(Total_deaths) 	as TotalDeathCount From covid_data
where continent = ''
group by location
order by TotalDeathCount desc;

/*Showing the continents with highest death count per population*/
select continent,max(Total_deaths/population) as TotalperPop From covid_data
where continent != ''
group by continent
order by TotalperPop desc;

/* Global Numbers*/
select date_register,sum(new_cases),sum(new_deaths), (sum(new_deaths)*100/sum(new_cases)) as DeathRate From covid_data
where continent != '' /*and location like '%brazil%'*/
group by date_register
order by DeathRate desc;


/*Check vaccinations*/
with popVSvacc (Continent,Location,Date_Register,Population,New_Vaccinations,RollingPeopleVaccinated)
as(
select continent,location,date_register,population,new_vaccinations, 
sum(new_vaccinations) over (partition by location order by location,date_register) as RollingPeopleVaccinated
from covid_data
where continent != ''
) select location,date_register,RollingPeopleVaccinated/population from popVSvacc; 



/*temp table*/
create temporary table percentPopVacc(
continent nvarchar(255),
location nvarchar(255),
date_register datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric); 

insert into percentPopVacc
select continent,location,date_register,population,new_vaccinations, 
sum(new_vaccinations) over (partition by location order by location,date_register) as RollingPeopleVaccinated
from covid_data
where continent != '';

select * from percentPopVacc;
/*Creating view for later visualizations*/
create view percentPopVaccaV as
select continent,location,date_register,population,new_vaccinations, 
sum(convert(new_vaccinations,decimal)) over (partition by location order by location,date_register) as RollingPeopleVaccinated
from covid_data
where continent != '';
select location,RollingPeopleVaccinated from percentpopvaccav;



Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths )/SUM(New_Cases)*100 as DeathPercentage
From covid_data
where continent is not null 
order by 1,2;



Select location, SUM(new_deaths) as TotalDeathCount
From covid_data
Where continent = '' 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_data
Group by Location, Population
order by PercentPopulationInfected desc;

create view infection_rate as
Select Location, Population,date_register, MAX(total_cases) as HighestInfectionCount,  Max(total_cases*100/population) as PercentPopulationInfected
From covid_data
where continent != ''
Group by location, date_register
order by PercentPopulationInfected desc;


select * from infection_rate into outfile 'C:/wamp64/tmp/infection_rate.csv'
fields terminated by ',' enclosed by '"'
lines terminated by '\r\n';