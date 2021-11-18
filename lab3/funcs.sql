-- 1 -- 
create or replace function cup_of_coffee_index(gdp double precision)
returns decimal as $$
begin
    return gdp * 0.0023231;
end
$$ language plpgsql;

select c.id, c.store_name, c.city_name, cup_of_coffee_index(gdp.gdp_2018) from public.coffee_shop c join public.country_gdp gdp
on gdp.country_code like CONCAT('%', c.country_name);

-- 2 --

drop table if exists typedtbl;
create table typedtbl (
    name varchar,
    favourite_shop varchar,
    orientation varchar,
    net_worth double precision
);
create or replace function get_people_by_country(_tbl_type anyelement, country varchar)
returns setof anyelement
as $$
begin
    return query
    execute
    'select c.customer_of_the_week_name, c.store_name, s.subset, gdp.gdp_2018 from public.coffee_shop c 
    join public.survey s on c.country_name = s.country
    join public.country_gdp gdp on s.country = gdp.country_name
    where c.country_name = $1'
    using country;
end;
$$ language plpgsql;

select * from get_people_by_country(null::typedtbl, 'Turkey');

-- 3 --

create or replace function find_country_customers(country_val varchar)
returns table (
    name varchar,
    favourite_shop varchar,
    orientation varchar,
    net_worth decimal
) as $$
begin
    create temp table tbl (
        name varchar,
        favourite_shop varchar,
        orientation varchar,
        net_worth decimal
    );
    insert into tbl (name, favourite_shop, orientation, net_worth)
    select c.customer_of_the_week_name, c.store_name, s.subset, gdp.gdp_2018 from public.coffee_shop c 
    join public.survey s on c.country_name = s.country
    join public.country_gdp gdp on s.country = gdp.country_name
    where c.country_name = country_val;
    return query
    select * from tbl;
end;
$$ language plpgsql;

select * from find_country_customers('Germany');

-- 5 --
create or replace procedure update_rating(shop_id varchar, new_rating varchar)
as $$
begin
    update public.coffee_shop
    set rating = new_rating
    where id = shop_id;
    commit;
end;
$$ language plpgsql;

call update_rating('10001-99525', 'Average');

create or replace procedure city_recusion(start_city varchar)
as $$
declare
    curr_city varchar;
    next_city varchar;
begin
    select c.city_name from public.city c where lower(c.city_name) like concat(right(start_city, 1),'%') 
    limit 1
    into next_city;
    if next_city is null then 
        raise notice 'no city found!';
    else
	    raise notice 'Found city %', next_city;
        select c.city_name from public.city c where lower(c.city_name) like concat(right(next_city, 1),'%')
        limit 1
        into curr_city;
        raise notice 'Found city %', curr_city;
        next_city = null;
        call city_recusion(curr_city);
    end if;
end;
$$ language plpgsql;

call city_recusion('Moscow');

drop procedure fetch_shop_subset;
create or replace procedure fetch_shop_subset(customer_name varchar)
as $$
declare
	cnt decimal;
    reclist record;
    listcur cursor for
    select c.store_name, c.rating, s.subset, s.name from public.coffee_shop c inner join public.survey s on c.customer_of_the_week_name = s.name
    where c.customer_of_the_week_name = customer_name;
begin
		cnt = 0;
        open listcur;
        loop
            fetch listcur into reclist;
            raise notice '%. % with rating % has a % customer %.', cnt, reclist.store_name, 
            reclist.rating, reclist.subset, reclist.name;
			cnt = cnt + 1;
            exit when not found;
        end loop;
        close listcur;
end;
$$ language plpgsql;

call fetch_shop_subset('Ellen Deering');

create or replace procedure get_db_metadata(dbname varchar)
as $$
declare
    dbid int;
    dbconnlimit int;
begin
    select pg.oid, pg.datconnlimit from pg_database pg where pg.datname = dbname
    into dbid, dbconnlimit;
    raise notice 'db: %, id: %, connection limit: %', dbname, dbid, dbconnlimit;
end;
$$ language plpgsql;
call get_db_metadata('lab1');

create or replace function insert_coffee_shop()
returns trigger
as $$
declare
    shopscount int;
    name varchar;
    survey_count int;
    city_count int;
begin
    select c.customer_of_the_week_name, count(*) from public.coffee_shop c
    where c.customer_of_the_week_name = new.customer_of_the_week_name
    group by c.customer_of_the_week_name
    into name, shopscount;
    if (shopscount >= 2) then
        raise exception '% is a customer of the week in %. it is unreal.', name, shopscount;
        return null;
    else
        select count(*) from public.survey s where s.name = new.customer_of_the_week_name
        into survey_count;
        if (survey_count = 0) then
            raise exception 'no % found in survey. abort.', name;
            return null;
        end if;
        select count(*) from public.city c where c.city_name = new.city_name
        into city_count;
        if (city_count = 0) then
            raise exception 'no % found in cities. abort.', city;
            return null;
        end if;
        insert into public.coffee_shop (
            store_name,
            city_name,
            customer_of_the_week_name,
            rating
        )
        values (
            new.store_name,
            new.city_name,
            new.customer_of_the_week_name,
            new.rating
        );
        return new;
    end if;
end;
$$ language plpgsql;


create trigger client_insertion instead of insert on public.coffee_shop
for each row execute procedure insert_coffee_shop();

insert(
    store_name,
    city_name,
    customer_of_the_week_name,
    rating
)
values (
    'magaz',
    'Moscow',
    'Kirill Diordiev',
    'Decent'
);


