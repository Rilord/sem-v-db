-- 1.Селект с предикатом сравнения
select country_name, country_code from public.country_gdp where gdp_2006 < gdp_1990;
-- 2.Селект с предикатом between
select country_name, country_code from public.country_gdp where gdp_2011 between 10500.5456 and 21345.342;
-- 3.Селект с предикатом like
select name, subset from public.survey where question_label like 'Do you avoid certain places or locations for fear of being assaulted, threatened or harassed because you are L, G, B or T?' and answer like 'Yes';

-- 4.Селект с вложенным подзапросом
select id, customer_of_the_week_name 
from public.coffee_shop 
where customer_of_the_week_name in (select name from public.survey where subset = 'Lesbian');

-- 5.Селект с предикатом exists
select customer_of_the_week_name 
from public.coffee_shop 
where exists (select name from public.survey where country = 'Austria');

-- 6. ALL
select city_name, admin_name from public.city where capital = null and population > 
all(select population from public.city where capital = primary);

-- 7. AVG
select avg(population) as avg_population from public.city where country_name = 'United States';

-- 8. SCALAR
select city_name, (select avg(gdp_2011) from public.country_gdp) as avg_country_gdp, capital from public.city where city_name like 'A%x'-- 8. SCALAR

-- 9. CASE
select id, admin_name,
case 
when capital is null then 'small-town'
else cast (capital as varchar)
end capital
from public.city;

-- 10. SEARCH CASE
select city_name, admin_name,
    case 
        when population < 50000 then 'big town'
        when population < 100000 then 'small city'
        when population < 500000 then 'medium city'
        when population < 1000000 then 'big sity'
        else 'megapolis'
    end as population
from public.city;

-- 11. TEMP TABLE
create temp table developing_countries as
select country_name, country_code, gdp_1990, gdp_2018 from public.country_gdp where gdp_1990 < gdp_2018

-- 12. LATERAL QUERY
select 
city_name, admin_name, country_name
from public.city c1
where 
country_name in (
    select 
        c2.city_name
    from
        public.country_gdp
    where 
        c1.country_name = c2.country_name
    )

-- 13. LEVEL OF NESTING = 3
select id from public.coffee_shop where city_name in (
    select city_name from public.city where country_name in (
        select country_name from public.country_gdp where gdp_2006 in (
            select gdp_2011 from public.country_gdp where gdp_2011 < gdp_2018
        )
    )
)

-- 14. group by without having

select admin_name, count(city_name) as qty_cities, avg(population) as avg_populus from public.city group by admin_name;

-- 15. group by with having

select admin_name, count(city_name) as qty_cities, avg(population) as avg_populus from public.city group by admin_name
having count(city_name) > 5;

-- CHAPTER 2. INSERTS. 

-- 1. simple insert

INSERT INTO country_gdp (country_name, country_code, gdp_2018)
VALUES ('Mordor', 'MRDR', 1.000);

-- 2. insert with select

insert into survey (country, subset, question_label, answer)
select 'Slovenia', subset, question_label, answer, 'Kodor' from survey
where subset = 'Transgender' and answer = 'Yes';

-- CHAPTER 3. UPDATES

-- 1. simple update
update survey set answer = 'Yes' where target = 'Gay';

-- 2. 
update country_gdp set gdp_2011 = (select avg(gdp_2006) from country_gdp)
where gdp_2006 = 10000;

-- CHAPTER 4. DELETE

delete from city_name where capital = null;

delete from city_name where admin_name in 
(select admin_name from city_name where population < 30000);

with best_coffee_shops(shop_name, rating, city_name) as (
    select coffee_shop.name, rating, city_name from coffee_shop join city
    on coffee_shop.city_name = city.city_name
    where population < (select avg(population) from city)
)

select * from survey;

with recursive worst_coffee_shop (id, city_name) as (
    select id, city_name, 'Bad' as rating from coffee_shop
    where city_name like 'A%b'
    union all
    select cfs.id, cfs.city_name, 'Good' from coffee_shop cfs
    join worst_coffee_shop wcfs on cfs.id = cfs.id + 1and rating = 'Good'
)

select i, city_name from worst_coffee_shop where city_name = 'Moscow';

CREATE TABLE test (
    question VARCHAR NOT NULL,
    answer VARCHAR NOT NULL
);
INSERT INTO test (name, surname) VALUES ('Ok?', 'Ok'), ('Bad?', 'Bad');
WITH test_deleted AS
(DELETE FROM test RETURNING *),
test_inserted AS
(SELECT question, asnwer, ROW_NUMBER() OVER(PARTITION BY question, asnwer ORDER BY question, asnwer) rownum FROM test_deleted)

INSERT INTO test SELECT question, asnwer FROM test_inserted WHERE rownum = 1;
DROP TABLE test;


