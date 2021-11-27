create extension if not exists plpython3u;
-- 1 -- 
create or replace function cup_of_coffee_index(gdp double precision)
returns decimal as $$
    return gdp * 0.0023231;
$$ language plpython3u;

select c.id, c.store_name, c.city_name, cup_of_coffee_index(gdp.gdp_2018) from public.coffee_shop c join public.country_gdp gdp
on gdp.country_code like CONCAT('%', c.country_name);

-- 2 --

    -- 3 --

    create or replace function find_country_customers(country_val varchar)
    returns table (
        name varchar,
        favourite_shop varchar,
        orientation varchar,
        net_worth decimal
    ) as $$
        query = f"select c.customer_of_the_week_name, c.store_name, s.subset, gdp.gdp_2018 from public.coffee_shop c join public.survey s on c.country_name = s.country join public.country_gdp gdp on s.country = gdp.country_name where c.country_name = '{country_val}';"
        result = plpy.execute(query)
        for x in result:
            yield(x["customer_of_the_week_name"], x["store_name"], x["subset"], ["gdp_2018"])
    $$ language plpython3u;

    select * from find_country_customers('Germany');

    -- 5 --
    create or replace procedure update_rating(shop_id varchar, new_rating varchar)
    as $$
        plan = plpy.prepare("update public.coffee_shop set rating = $2 where id = $1;",
        ["VARCHAR", "VARCHAR"])
        plpy.execute(plan, [shop_id, new_rating])
    $$ language plpython3u;

    call update_rating('10001-99525', 'Average');

    --6--

    create or replace function estimate_rating()
    returns trigger
    as $$
        if TD["new"]["rating"] == "Average":
            plpy.notice(f"{TD['new']['store_name']} likely to close")
        else:
            plpy.notice(f"{TD['new']['store_name']} likely to stay safe")
    $$ language plpython3u;
