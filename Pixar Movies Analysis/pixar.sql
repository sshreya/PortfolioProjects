create table academy(
film varchar(20),
award_type varchar(20),
status varchar(30)
);

create table box_office(
film varchar(20),
budget int,
box_office_us_canada int,
box_office_other int,
box_office_worldwide int
);

create table genres(
film varchar(20),
category varchar(20),
value varchar(30)
);

create table films(
number int,
film varchar(20),
release_date date,
run_time int,
film_rating varchar(10),
plot varchar(255)
);

create table people(
film varchar(20),
role_type varchar(20),
name varchar(30)
);

create table public_response(
film varchar(20),
rotten_tomatoes_score int,
rotten_tomatoes_counts int,
metacritic_score int,
metacritic_counts int,
cinema_score varchar(10),
imdb_score float,
imdb_counts int
);

select * from academy limit 5;
select * from box_office where film = 'Luca';
-- check for duplicates in academy table

select * from academy limit 5;
select 
	film,
    award_type,
    count(status) as cn 
from 
	academy 
group by 1,2;

select 
	film,
    award_type,
    status,
    count(*)
from 
	academy 
group by 1,2,3;


-- check for duplicates in box_office table
select * from box_office limit 5;
select 
	film,
    count(*) as cn
from 
	box_office 
group by 1
having cn > 1;


-- check for duplicates in genres table
select * from genres limit 5;
with cte as(
select 
	*,
    row_number()over(partition by film,category,value) as rn 
from 
	genres
)
select * from cte where rn > 1;

select 
	film,
    category,
    group_concat(value) as value 
from 
	genres
group by 1,2;


-- check for duplicates in films table
select * from films limit 5;
select count(film),count(number) from films;


#checking for duplicates in people table
select 
	*,
    row_number()over(partition by film,role_type,name) as rn 
from 
	people
;
select count(*) from people;
# creating a new table with duplicates removed
drop table people_clean;
create table people_clean as
with cte as(
select 
	*,
    row_number()over(partition by film,role_type,name) as rn 
from 
	people
)
select 
	film,
    group_concat(case when role_type = 'Director' then name end) as Director,
	group_concat(case when role_type = 'Co-director' then name end) as Codirector,
    group_concat(case when role_type = 'Producer' then name end) as Producer,
    group_concat(case when role_type = 'Musician' then name end) as Musician,
	group_concat(case when role_type = 'Screenwriter' then name end) as Screenwriter,
    group_concat(case when role_type = 'Storywriter' then name end) as Storywriter
from 
	cte
where rn = 1
group by 1
;
---

select * from people_clean limit 5;
select count(*) from people_clean;

-- checking if people_clean contains any duplicates
with cte as(
select 
	*,
    row_number()over(partition by film,role_type,name) as rn 
from 
	people_clean
)
select * from cte where rn > 1;
---
-- check for duplicates in people
select * from public_response limit 5;
select count(film) from public_response;
select * from public_response;

select 
	film,
    role_type,
    group_concat(name) as names 
from 
	people
group by 1,2;
# re arranging genres table
select 
	film,
    case when category = 'Genre' then value end as Genre,
    case when category = 'Subgenre' then value end as Subgenre 
from 
	genres;
    
#which pixar movie has won the max number of awards
select * from academy limit 5;
select distinct status from academy;

select * from academy where status = 'Won';
select 
	film,
    count(award_type) as awards_won 
from 
	academy 
where status = 'won'
group by 1
order by awards_won desc;

select distinct award_type from academy;

#first movie made by pixar
select * from films;
select 
	*
from 
	films 
order by release_date 
limit 1;

# min imdb score to a pixar movie

with cte as(
select
	*,
    rank()over(order by imdb_score) as rn 
from 
	public_response 
)
select * from cte where rn = 1;


select
	*,
    lower(replace(film,' ','-')) as url_film_name 
from 
	films 
;
-- Top grossers---
select * from box_office order by box_office_worldwide desc limit 5;

-- getting public response for the top grossers--
with box_office_cte as(
select 
	*
from 
	box_office 
order by box_office_worldwide desc 
limit 5
)
select 
	*
from 
	box_office_cte bo 
join 
	public_response pr 
on bo.film = pr.film
;

-- Highest budget movie--
select * from box_office order by budget desc limit 10;

select 
	award_type,
    count(film) as films_won 
from 
	academy 
where status in ('Won','Won Special Achievement')
group by 1;

-- most profitable movies
select * from(
select 
	film,
    budget,
    box_office_worldwide,
    box_office_worldwide - budget as profit,
    rank()over(order by (box_office_worldwide - budget) desc) as rn 
from 
	box_office 
where 
	box_office_worldwide > budget
)x
where x.rn <= 5;

-- public response of movies which have won best animated feature awards
select 
    avg(p.rotten_tomatoes_score) as rt_score,
    avg(p.metacritic_score) as m_score,
    avg(p.imdb_score) as imdb_score
from 
	academy a 
join 
	public_response p
on a.film = p.film
where a.award_type = 'Animated Feature'
and a.status in ('Won','Won Special Achievement');



