SELECT title, release_year, country
FROM films;

select distinct country
from films

SELECT COUNT(*)
FROM reviews

SELECT COUNT(distinct birthdate)
FROM people;

select *
from films
where release_year = 2016

select count(*)
from films
where release_year < 2000

select title, release_year
from films
where release_year > 2000

select *
from films
where language='French'

select name, birthdate
from people
where birthdate='1974-11-11'

select count(*)
from films
where language='Hindi'

select *
from films
where certification='R'

select title, release_year
from films
where release_year < 2000 and language = 'Spanish'

select *
from films
where release_year < 2010 and release_year > 2000 and language = 'Spanish'

select title, release_year
from films
where release_year < 2000 and release_year >= 1990 and (language = 'French' or language = 'Spanish') and gross > 2000000

select title, release_year
from films
where (release_year between 1990 and 2000) and (budget > 100000000) and (language = 'Spanish' or language = 'French')

select title, release_year
from films
where (release_year in (1990, 2000)) and (duration > 120)

select title
from films
where budget is null

/*Get the names of all people whose names begin with 'B'. The pattern you need is 'B*/
select name
from people
where name like 'B%'

/*Get the names of people whose names have 'r' as the second letter. The pattern you need is '_r%'.*/
select name
from people
where name like '_r%'

/*Get the names of people whose names don't start with A. The pattern you need is 'A%'.*/
select name
from people

select sum(duration)
from films

select max(duration) from films

select avg(gross)
from films
where title like 'A%'

select max(gross) from films
where release_year >= 2000 and release_year <= 2012

select avg(duration)/60.0 avg_duration_hours from films

select title, duration/60.0 as duration_hours
from films

select title, gross-budget net_profit
from films

select 
    (max(release_year)-min(release_year))/10.0 as number_of_decades
from films

select max(release_year)-min(release_year) as difference from films

select count(deathdate)*100.0/count(*) as percentage_dead
from people

select name
from people
order by 1

select name from people
order by birthdate

select birthdate, name from people
order by birthdate

select title
from films
where release_year in (2000, 2012)
order by release_year

select *
from films
where release_year != 2015
order by duration

select title, gross
from films
where title like 'M%'
order by title

select title, duration from films
order by 2 desc

select release_year, duration, title from films
order by 1,2

select release_year, count(*)
from films
group by release_year

select release_year, max(budget) 
from films
group by release_year

select imdb_score, count(*)
from reviews
group by imdb_score

select release_year, country, max(budget) from films
group by 1, 2
order by 1, 2

select release_year, avg(budget) avg_budget, avg(gross) avg_gross
from films
group by 1
having release_year > 1990 and avg(budget) > 60000000
order by 3 desc

-- select country, average budget, average gross
select country, avg(budget) avg_budget, avg(gross) avg_gross
-- from the films table
from films
-- group by country 
group by country
-- where the country has more than 10 titles
having count(*) > 10
-- order by country
order by 1
-- limit to only show 5 results
limit 5

SELECT title, imdb_score
FROM films
JOIN reviews
ON films.id = reviews.film_id
WHERE title = 'To Kill a Mockingbird';
where name not like 'A%'
