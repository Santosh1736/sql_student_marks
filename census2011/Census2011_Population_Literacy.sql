-- Displaying both the Dataset of Census 2011
Select * from DistrictCensus
Select * from Population

-------------------------------------------------------------------------------------------------------
-- showing the total number of rows in both dataset

Select Count(*) as Totalrows from DistrictCensus
Select Count(*) as Totalrows from Population

---------------------------------------------------------------------------------------------------------
-- show the data for jharkhand and bihar

Select * from DistrictCensus
where State='jharkhand' or State ='bihar'

Select * from Population
where State='jharkhand' or State= 'bihar'

--Using Join
Select dis.District,dis.State,dis.Growth,dis.Sex_Ratio,dis.Literacy,pop.Area_km2,pop.Population from DistrictCensus as dis
inner join Population as pop
on dis.District=pop.District
/*
where dis.state='bihar' or dis.State='jharkhand'
*/
where dis.State in ('bihar','jharkhand')

----------------------------------------------------------------------------------------------------------------------

--Population of India

Select SUM(Population) as TotalPopulation from Population
-------------------------------------------------------------------------------------------------------------

-- avg Growth
select State,AVG(Growth) as AvgGrowth from DistrictCensus
group by State
order by AvgGrowth Desc
------------------------------------------------------------------------------------------------------------------

--avg Sex ratio
Select State,round(AVG(Sex_Ratio),0) as avg_SexRatio from DistrictCensus 
group by State 
order by avg_SexRatio Desc
-------------------------------------------------------------------------------------------------------

--avg Literacy rate

Select State,round(AVG(Literacy),0) Avg_Literacy from DistrictCensus 
group by State 
having round(AVG(Literacy),0) >=90
order by Avg_Literacy Desc
-------------------------------------------------------------------------------------------------------------------

--top 3 state having highest growth rate of Population
Select top 3 State, round(avg(Growth)*100,0) as Avg_Growth_population from DistrictCensus 
group by State 
order by Avg_Growth_population Desc
-----------------------------------------------------------------------------------------------------------------------

--bottom 3 state having lowest Sex_ratio
Select top 3 State,round(avg(Sex_ratio),0) Avg_SexRatio from DistrictCensus group by State order by Avg_SexRatio asc
------------------------------------------------------------------------------------------------------------------------

-- top and bottom 3 states having literacy rate      --using temptable
drop table if exists top_state
create table top_state 
( state nvarchar(255),
  topstate float
  )
insert into top_state
select state, round(avg(Literacy),0) as Avg_Literacy from DistrictCensus
group by state

Select top 3 * from top_state order by topstate Desc

drop table if exists bottom_state
create table bottom_state 
( state nvarchar(255),
  bottomstate float
  )
insert into bottom_state
select state, round(avg(Literacy),0) as Avg_Literacy from DistrictCensus
group by state

Select top 3 * from bottom_state order by bottomstate asc
--------------------------------------------------------------------------------------------------------------

--Union operator

Select * from(
Select top 3 * from top_state order by topstate Desc) a 
union
Select * from(
Select top 3 * from bottom_state order by bottomstate asc) b
-------------------------------------------------------------------------------------------------------------

--state starting with letter a
select distinct state from DistrictCensus where state like 'a%' 

select distinct state from DistrictCensus where state like 'b%' or state like '%d'  --starting and ending with

select distinct state from DistrictCensus where state like '%ha%' or state like '_t%' -- containing letters
---------------------------------------------------------------------------------------------------------------------

--joining the both table to get total number of males and female at district level   --using subqueries

select district, state, round((Population/(Sex_Ratio+1000))*Sex_Ratio,0) female, round((Population/(Sex_Ratio+1000))*1000,0) male, Population from (
Select dis.District,dis.State,dis.Sex_Ratio,pop.Population from DistrictCensus as dis
inner join Population as pop
on dis.District=pop.District ) c

------------------------------------------------------------------------------------------------------------------------------------------------

--joining the both table to get total number of males and female at State level

select d.state, sum(d.male) as Total_Male,sum(d.female) as Total_female from(
select district, state, round((Population/(Sex_Ratio+1000))*Sex_Ratio,0) female, round((Population/(Sex_Ratio+1000))*1000,0) male, Population from (
Select dis.District,dis.State,dis.Sex_Ratio,pop.Population from DistrictCensus as dis
inner join Population as pop
on dis.District=pop.District ) c ) d group by d.state 

--------------------------------------------------------------------------------------------------------------------------------------


-- calculate total literate and illiterate population of each state using literacy ratio

select b.state, sum(b.literate_people) literate_population, sum(b.illterate_people) Illiterate_population, sum(b.population) Total_Population from(
select a.District, a.state, round((a.literacy*a.population),0) literate_people, round((1-a.literacy)*population,0) illterate_people,a.population population from(
select dis.District, dis.state, dis.literacy/100 literacy, pop.population from DistrictCensus 
dis Inner join Population pop on dis.District=pop.District) a) b
group by b.state
order by Total_Population

-----------------------------------------------------------------------------------------------------------------------------------------

-- calculate the population of previous census using growth rate

select b.state, sum(b.population) Population_2011, sum(b.pre_population) Population_2001_pre, round(avg(b.growth),3) Growth from ( 
select a.District, a.state,a.population, round(a.Population/(1+a.Growth),0) as pre_population,a.Growth from(
Select dis.District, dis.state, dis.Growth, pop.Population from DistrictCensus dis
Inner Join Population pop
On dis.District= pop.District ) a) b
group by b.state 
order by Growth desc

---------------------------------------------------------------------------------------------------------------------------------

-- Total Population of previous census and current census

select sum(c.Population_2001_pre) Previous_census_population, sum(c.Population_2011) current_census from(
select b.state, sum(b.population) Population_2011, sum(b.pre_population) Population_2001_pre from ( 
select a.District, a.state,a.population, round(a.Population/(1+a.Growth),0) as pre_population,a.Growth from(
Select dis.District, dis.state, dis.Growth, pop.Population from DistrictCensus dis
Inner Join Population pop
On dis.District= pop.District ) a) b
group by b.state ) c

------------------------------------------------------------------------------------------------------------------------------

-- people living per square km in previous and current census

select c.state,round((c.Population_2001_pre/c.Area_km2),0) Pop_Per_km2_2001,round((c.Population_2011/c.Area_km2),0) Pop_Per_km2_2011   from(
select b.state, sum(b.population) Population_2011, sum(b.pre_population) Population_2001_pre,sum(b.Area_km2) Area_km2 from ( 
select a.District, a.state,a.population, round(a.Population/(1+a.Growth),0) as pre_population,a.Area_km2 from(
Select dis.District, dis.state, dis.Growth,pop.Area_km2, pop.Population from DistrictCensus dis
Inner Join Population pop
On dis.District= pop.District ) a) b
group by b.state ) c
order by Pop_Per_km2_2001 desc

-------------------------------------------------------------------------------------------------------------------------

--window function

--output top 3 district from each state with highest literacy rate

select a.* from(
select district,state,literacy, rank() over( partition by state order by literacy desc ) rnk from DistrictCensus) a
where a.rnk in (1,2,3) order by state 