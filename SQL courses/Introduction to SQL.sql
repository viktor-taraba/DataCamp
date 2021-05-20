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
