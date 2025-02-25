----- DATA CLEANING AND TRANSFORMATION
-- check for duplicates in the netflix table
-- 1. check if there are rows with duplicate show_id
select 
    show_id,
    count(*)
from 
    netflix 
group by 1 
having count(*) > 1;

-- 2. check if there are rows with duplicate type and title
select * from netflix where (type,title) in (
select 
    type,
    title
from 
    netflix 
group by 1,2 
having count(*) > 1
)
order by title;


-- delete duplicate rows 
with cte as(
select 
    show_id,
    row_number()over(partition by type,title order by show_id) as rn 
from 
    netflix
)
delete from netflix where show_id in (select show_id from cte where rn > 1);

-- creating table netflix_director, netflix_genre, netflix_cast, netflix_country from the main table so that we can split the concatenated values into separate rows
CREATE TABLE netflix_genre AS
WITH RECURSIVE numbers AS (
    SELECT 1 as n
    UNION ALL
    SELECT n + 1 
    FROM numbers n1
    WHERE n1.n < (
        SELECT MAX(
            LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', '')) + 1
        )
        FROM netflix
    )
)
SELECT 
    distinct 
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) as genre
FROM netflix
CROSS JOIN numbers;
--
CREATE TABLE netflix_cast AS
WITH RECURSIVE numbers AS (
    SELECT 1 as n
    UNION ALL
    SELECT n + 1 
    FROM numbers n1
    WHERE n1.n < (
        SELECT MAX(
            LENGTH(cast) - LENGTH(REPLACE(cast, ',', '')) + 1
        )
        FROM netflix
    )
)
SELECT 
    distinct 
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', numbers.n), ',', -1)) as cast
FROM netflix
CROSS JOIN numbers;

--
CREATE TABLE netflix_director AS
WITH RECURSIVE numbers AS (
    SELECT 1 as n
    UNION ALL
    SELECT n + 1 
    FROM numbers n1
    WHERE n1.n < (
        SELECT MAX(
            LENGTH(director) - LENGTH(REPLACE(director, ',', '')) + 1
        )
        FROM netflix
    )
)
SELECT 
    distinct 
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', numbers.n), ',', -1)) as director
FROM netflix
CROSS JOIN numbers;



------------
CREATE TABLE netflix_country AS
WITH RECURSIVE numbers AS (
    SELECT 1 as n
    UNION ALL
    SELECT n + 1 
    FROM numbers n1
    WHERE n1.n < (
        SELECT MAX(
            LENGTH(country) - LENGTH(REPLACE(country, ',', '')) + 1
        )
        FROM netflix
    )
)
SELECT 
    distinct 
    show_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) as country
FROM netflix
CROSS JOIN numbers;


-- change datatype of date_added from varchar to date
update netflix set date_added =  str_to_date(date_added,'%M %d,%Y') where date_added != '';
    
-- check which columns have null values using python and replacing null values in country column
-- checking for country values for same directors.  
-- Assuming if one director has non null country for a show/movie, we can use that country value for other shows of that director which are empty
---
insert into netflix_country
with cte as(
select 
	nd.*,
    nc.country
from 
	netflix_director nd 
join 
	netflix_country nc 
on nd.show_id = nc.show_id
where director != ''
order by director
)
select 
	a.show_id,
    b.country
from 
	cte a 
join 
	cte b 
on a.director = b.director
where a.country = ''
and b.country != ''
group by 1,2
order by show_id
;
-- delete rows with show_id which have blank values and non blank values
delete from netflix_country where show_id in(
select show_id from(
select 
	show_id
from 
	netflix_country
where country = '' or country != ''
group by show_id
having count(*) > 1
)t
)
and country = '';

-- check for records with empty duration
select * from netflix where duration = '';
update netflix set duration = rating where duration = '';

-- Answering some business problems
/*1  for each director count the no of movies and tv shows created by them in separate columns 
for directors who have created tv shows and movies both */
select 
	director,
    sum(case when type = 'Movie' then 1 else 0 end) as movies,
    sum(case when type = 'TV Show' then 1 else 0 end) as TV_shows
from 
	netflix 
where director != ''
group by 1 
having count(distinct type) = 2;

-- 2 which country has highest number of comedy movies 
with cte as(
select 
	nc.*,
    ng.genre
from 
	netflix_country nc 
join 
	netflix_genre ng 
on nc.show_id = ng.show_id
where ng.genre = 'Comedies'
and country != ''
)
select 
	cte.country,
    count(cte.show_id) as no_of_comedy_movies
from 
	cte 
join 
	netflix 
on cte.show_id = netflix.show_id
where netflix.type = 'Movie'
group by 1
order by no_of_comedy_movies desc
limit 1;

-- 3 for each year (as per date added to netflix), which director has maximum number of movies released
with cte as(
select 
	nd.director,
    year(n.date_added) as year_added,
    count(nd.show_id) as num_movies
from 
	netflix_director nd 
join 
	netflix n 
on nd.show_id = n.show_id
where nd.director != ''
and n.type = 'Movie'
group by 1,2
)
select * from(
select 
	*,
    dense_rank()over(partition by year_added order by num_movies desc) as rn
from 
	cte
)x
where x.rn = 1;

-- 4 what is average duration of movies in each genre
select 
    ng.genre,
    round(avg(cast(substring_index(n.duration,'m',1) as signed)),2) as avg_duration
from 
	netflix_genre ng 
join 
	netflix n 
on ng.show_id = n.show_id
where n.type = 'Movie'
group by 1;

-- 5 find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them 
select 
    nd.director,
    sum(case when genre = 'Horror Movies' then 1 else 0 end) as num_horror_movies,
    sum(case when genre = 'Comedies' then 1 else 0 end) as num_comedy_movies
from 
	netflix_genre ng 
join 
	netflix_director nd 
on ng.show_id = nd.show_id
join 
	netflix n 
on nd.show_id = n.show_id
where ng.genre in ('Horror Movies','Comedies')
and nd.director != ''
and n.type = 'Movie'
group by 1
having count(distinct genre) = 2;
