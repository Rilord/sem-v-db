create extension if not exists plpython3u;

create or replace function insert_cofee_shop()
returns trigger
as $$
    result = plpy.execute(
        f"select c.customer_of_the_week_name, count(*) from public.coffee_shop c
    where c.customer_of_the_week_name = '{TD['new']['customer_of_the_week_name']}'
    group by c.customer_of_the_week_name;")
    if result.nrows() >= 2:
        plpy.notice(f"'{result[0]['customer_of_the_week_name']}'
            is the customer in '{result[0]['count']}' is unreal!")
        return "SKIP"
    else:
        survey_check = plpy.execute(
            f"select count(*) from public.survey where 
            s.name = new.customer_of_the_week_name;
            "
        )
        if result.nrows() == 0:
            plpy.notice(f"no '{result[0]['customer_of_the_week_name']}' in survey")
            return "SKIP"

        plpy.notice(f"Sucess!")
        return "MODIFY"

        


as $$
$$ language plpython3u;

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
