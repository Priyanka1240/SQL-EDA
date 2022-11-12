select*from CovidDeaths1
select*from CovidVaccination1

---countrywise total volume
select location,sum(new_cases) total_cases,sum(new_deaths) Total_deaths
from CovidDeaths1
where continent <>' '
group by location
order by location


--select sum(new_cases) total_cases, max(Total_cases) [Maximum of Total Cases],sum(new_deaths) Total_deaths, max(total_deaths) [Maximum of Total Deaths]
--from CovidDeaths1
--where location='India'

---Total deaths vs Total cases
select location,date,population, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) Death_Percentage
from CovidDeaths1
--where total_cases<>0


---Total perecntage of infection of each country depending on its population
select location,population, max(total_cases) Maximum_cases,max((total_cases/population)*100 )Total_contraction_Percent                                                   
from CovidDeaths1
where population <>' '
group by location, population
order by 4 desc

----Order of the countries with maximum death count
select location, population, max(Total_deaths) [Total Death Count]
from CovidDeaths1
where continent<>' '
group by location, population
order by 3 desc

----Total vaccination, and percent of vaccinated population for each country
select vc.location,population,sum(new_vaccinations) [Total Vaccination Count], round((sum(new_vaccinations)/population)*100, 2) [%of vaccinated population]
from CovidVaccination1 vc
join CovidDeaths1 cd
on vc.date=cd.date and vc.location=cd.location
where cd.continent<>' ' and population<>' '
group by vc.location,population
order by 3 desc

----Running Total of vaccination and percent of running total for each country using window function and cte
with cte as
(
select v.location,v.date,population,sum(new_vaccinations) over(partition by v.location,v.date order by v.location,new_vaccinations rows between unbounded preceding and current row) [Rolling count of vaccination]                   
from CovidVaccination1 v
join CovidDeaths1 d
on v.date=d.date and v.location=d.location
where d.continent<>' ' 
--and population<>' '
group by v.location,v.date,population, new_vaccinations
)
select location,date, population,[Rolling count of vaccination] ,([Rolling count of vaccination] /population)*100 [%of Runnig Total Vaccination]
from cte
order by 3 desc

---Total count of cases, deaths and vaccinations globally
select min(cd.date) [From Date], max(cd.date)[Till Data], sum(new_cases) [Total Cases], Sum(new_deaths) [Total Deaths], sum(new_vaccinations) [Total Vaccinations]
from CovidVaccination1 vc
join CovidDeaths1 cd
on vc.date=cd.date and vc.location=cd.location
where cd.continent<>' '

---Total count by Continent
select d.continent, sum(new_cases) [Total Cases], Sum(new_deaths) [Total Deaths], sum(new_vaccinations) [Total Vaccinations]
from CovidVaccination1 v
join CovidDeaths1 d
on v.date=d.date and v.location=d.location
where d.continent<>' '
group by d.continent

---Country with maximum covid cases from each continent using Temp Table
select continent,location, SUM(new_cases) [Total cases]
into #Covid_cases
from CovidDeaths1
where continent<>' '
group by continent,location

select*from #Covid_cases
where [Total cases] in
(select max([Total cases]) 
from #Covid_cases
group by continent)
order by 3 desc

---Country with maximum covid deaths from each continent using View
create view VW_Coviddeaths
as
select continent,location, SUM(new_deaths) [Total deaths]
from CovidDeaths1
where continent<>' '
group by continent,location

select*from VW_Coviddeaths
where [Total deaths] in
(select max([Total deaths]) 
from VW_Coviddeaths
group by continent)
order by 3 desc

---Top 10 countries with highest infection rate as per population using window ranking function and cte
with cte as
(
select location, SUM(new_cases) [Total cases], DENSE_RANK() over(order by SUM(new_cases) desc) Ranking
from CovidDeaths1
where continent<>' ' 
group by location
)
select location [Country], [Total Cases]
from cte
where Ranking<=10

----Using 2 cte in single with clause and performing join on two cte
with cte1 as
(
select location, population,SUM(new_cases) [Total cases],SUM(new_deaths) [Total deaths]
from CovidDeaths1
where continent<>' ' 
group by location, population
),
cte2 as
(select v.location,sum(new_vaccinations)[Total Vaccinations] 
from CovidDeaths1 d
join CovidVaccination1 v
on d.date=v.date and d.location=v.location
where d.continent<>' ' 
group by v.location
)
select cte1.location,cte1.population,[Total cases],[Total deaths],[Total Vaccinations]
from cte1
join cte2
on cte1.location=cte2.location
order by 3 desc



	