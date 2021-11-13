create or replace function cup_of_coffee_index(varchar gdp)
return decimal as $$
begin
    return gdp * 0.0023231;
end
$$ language plpgsql;

select c.id, c.store_name, c.city_name, estimate_cup_price(gdp.gdp_2018) from public.coffee_shop c join public.country_gdp gdp
on c.country_name = gdp.country_name;


drop table if exists typedtbl;
create table typedtbl {
    name varchar,
    favourite_shop varchar,
    orientation varchar,
    net_worth.decimal
};
create or replace function get_people_by_country(_tbl_type anyelement, country varchar)
returns setof anyelement
as $$
begin
    return query
    execute
    'select c.customer_of_the_week, c.store_name, s.subset, gdp.gdp_2018 from public.coffee_shop c 
    join public.survey s on c.country_name = s.country
    join public.country_gdp gdp on s.country = gdp.country_name
    where c.country = $1'
    using country;
end;
$$ language plpgsql;

select * from get_people_by_country(null::typedtbl, 'Turkey');

create or replace function find_country_customers(country varchar)
return table (
    name varchar,
    favourite_shop varchar,
    orientation varchar,
    net_worth.decimal
) as $$
begin
    create temp table tbl (
        name varchar,
        favourite_shop varchar,
        orientation varchar,
        net_worth.decimal
    );
    insert into tbl (name, favourite_shop, orientation, net_worth)
    select c.customer_of_the_week, c.store_name, s.subset, gdp.gdp_2018 from public.coffee_shop c 
    join public.survey s on c.country_name = s.country
    join public.country_gdp gdp on s.country = gdp.country_name
    where c.country = country;
    return query
    select * from tbl
end;
$$ language plpgsql;

select * from get_people_by_country('Germany');

create or replace procedure update_customer_of_the_week(shop_id varchar, customer varchar)
as $$
begin
    update public.coffee_shop
    set customer_of_the_week =  customer
    where id = shop_id;
    commit;
end;
$$ language plpgsql;

call update_customer_of_the_week('10001-99525', 'Boris Borisov');

create or replace procedure city_recusion(public.city varchar)
as $$
declare
    curr_city varchar;
    next_city varchar;
begin
    curr_letter = letter;
    execute
    select c.city_name from public.city c where lower(c.city_name) like right(curr_city, 1) + '%' 
    limit 1
    into next_city;
    if next_city is null then 
        raise notice 'no public.city found!';
    else
        select c.city_name from public.city c where c.city_name like right(next_letter, 1) + '%'
        limit 1
        into curr_city;
        raise notice 'Found public.city %s', curr_city;
        next_city = null;
        call city_recusion(curr_city);
    end if;
end;
$$ language plpgsql;

call city_recusion('Berlin');

create or replace procedure fetch_shop_subset(store_name varchar)
as $$
declare
    reclist record;
    listcur cursor for
    select s.name as name, s.subset, s.store_name, s.rating as rating from public.coffee_shop c inner join public.survey s on c.customer_of_the_week = s.name
    where c.store_name = store_name;
begin
        open listcur;
        loop
            fetch listcur into reclist;
            raise notice '% with rating %s has %s customer %s.', reclist.store_name, 
            reclist.rating, reclist.subset, reclist.name;
            exit when not found;
        end loop;
        close listcur;
end;
$$ language plpgsql;

call fetch_shop_subset('Debra Spivey');

CREATE OR REPLACE PROCEDURE get_db_metadata(dbname VARCHAR)
AS $$
DECLARE
    dbid INT;
    dbconnlimit INT;
BEGIN
    SELECT pg.oid, pg.datconnlimit FROM pg_database pg WHERE pg.datname = dbname
    INTO dbid, dbconnlimit;
    RAISE NOTICE 'DB: %, ID: %, CONNECTION LIMIT: %', dbname, dbid, dbconnlimit;
END;
$$ LANGUAGE PLPGSQL;
CALL get_db_metadata('dbcourse');

create or replace function insert_person()
returns trigger
as $$
declare
    shopscount int;
    name varchar;
begin
    select c.customer_of_the_week, count(*) from public.coffee_shop c
    where c.customer_of_the_week = new.customer_of_the_week
    group by c.customer_of_the_week
    into name, shopscount;
    if (shopscount >= 2) then
        raise exception '% is a customer of the week in %', name, shopscount;
        return null;
    else
        insert into public.coffee_shop (
            id, 
            store_name,
            city_name,
            customer_of_the_week,
            rating
        )
        values (
            new.id, 
            new.store_name,
            new.city_name,
            new.customer_of_the_week,
            new.rating
        );
        return new;
    end if;
end;
$$ language plpgsql;
