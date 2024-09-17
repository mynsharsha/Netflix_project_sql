-- Netflix project;



drop table if exists netflix;
create table netflix(
show_id varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year INT,
rating varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(250)
);
select * from netflix;

select count(*) from netflix;

select distinct type from netflix;

--1. count the number of movies vs tvshows

select type,count(*) 
from netflix
group by 1;

--2. find the most common rating for movies and tv shows
select type, rating,ranking
from( 
	select type,
		    rating,
			count(*), rank () over (partition by type order by count(*) desc) as ranking
	from netflix group by 1,2
) as t1
where ranking=1; 		

--3.List all Movies released in the year 2022

select *
	from netflix
	where type='Movie' and release_year='2020';


--4.find the top 5 countries with the most content on netflix
 
select 
	unnest(string_to_array(country,',')) as new_country,count(show_id) as total_count
from netflix
group by 1
order by count(*) desc
limit 5;
select 
unnest(string_to_array(country,',')) as new_country
from netflix;

--5. identify the longest movie
select * 
from netflix
where type='Movie'
and
duration=(select max(duration) from netflix);

--6. find content added in the last 5 years

select * 
from netflix 
where to_date(date_added,'month dd,yyyy')>=(select current_date-interval '5 years');

select to_date(date_added,'month dd,yyyy') 
from netflix;
select current_date - interval '5 years';

-- 7 find all the movies/ tv shows directed by 'Rajiv Chilaka'
--select  director from netflix where director ="%Rajiv Chilaka";
--select unnest(string_to_array(director,',')) as new_director from netflix;

select *
from netflix
where director like '%Rajiv Chilaka%';

--8. List all TV Shows which have more than 5 seasons

select *
from netflix
where type='TV Show' and split_part(duration,' ',1)::numeric>5;

--9 count the number of content in each genre

select unnest(string_to_array(listed_in,',')) as genre,
       count(show_id)
from netflix
group by 1;

--10. find each year and avg no.of content release in India on netflix return top 5 year
--with highest avgg content release

select * from netflix;

select extract(year from to_date(date_added,'Month dd,year')) as datee,count(*) as c,
count(*)::numeric/(select count(*) from netflix where country='India')*100 as avg_per_year
from netflix
where country ='India'
group by 1

--11 list all movies that are documentaries
select * from netflix;
select * from netflix
where listed_in like '%Documentaries%';


--12 find all content without a director

select * 
from netflix
where director is Null;

--13 find howmany movies actor salman khan acted in last 10 years
select * from netflix;
select count(show_id) from netflix
where casts like '%Salman Khan%' and 
release_year> extract(year from current_date)-10;

--14 find the top10 actors who appeared highes no of moviees in India

select * from netflix;

select unnest(string_to_array(casts,',')),count(show_id)
from netflix
where country='India'
group by 1
order by count(show_id) desc
limit 10;

--15. categorise the content 'kill' and 'violence' as bad and remaining all are good
-- count how many falls under each category

select * from netflix;

with t as(   
select 
case when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
else 'Good'
end as
category
from netflix)
select category,count(*) from t
group by 1;