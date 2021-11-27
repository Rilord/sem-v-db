

drop table if exists coffee_shops_from_json;
create table coffee_shops_from_json (
    id varchar primary key default,
    store_name varchar,
    city_name varchar,
    country_name varchar,
    customer_of_the_week_name varchar,
    rating varchar

)

drop table if exists temp;
create table temp (
    data jsonb
);

copy temp (data) from 'curl https://kodors.co/coffee_shop.json';
insert into coffee_shops_from_json (id, store_name, city_name, country_name, customer_of_the_week_name, rating)
select data->>'id', data->>'store_name', data->>'city_name', data->>'country_name', data->>'customer_of_the_week_name', data->>'rating' from temp;

DROP TABLE IF EXISTS context;
CREATE TABLE context (
    data jsonb
);

insert into context (data) values
('{"webpage": "kodors.co", "certificate": { "issued": "R3", "expires": "18 January 2022", "valid": true}}'),
('{"webpage": "deg.wiki", "certificate": { "issued": "Cloudflare Inc ECC CA-3", "expires": "19 April 2022", "valid": true}}');

select data->'webpage' webpage from context;
select (data->'certificate'->'valid')::boolean valid from context;

create or replace function key_compare(json_string jsonb, key text, value text)
returns boolean
as $$
begin
    RETURN (json_to_check->key)::text like value;
end;
$$ language plpgsql;

select key_compare('{"webpage": "kodors.co", "certificate": { "issued": "R3", "expires": "18 January 2022", "valid": true}}', webpage, "google.com");
select key_compare('{"webpage": "kodors.co", "certificate": { "issued": "R3", "expires": "18 January 2022", "valid": true}}', webpage, "kodors.co");

UPDATE context SET data = data || '{"certificate":{"expires": "21 August 2022"}}'::jsonb WHERE (data->'certificate'->'expires')::text like "18 January 2022";


select * from jsonb_array_elements('[
    {"webpage": "kodors.co", "certificate": { "issued": "R3", "expires": "18 January 2022", "valid": true}},
    {"webpage": "deg.wiki", "certificate": { "issued": "Cloudflare Inc ECC CA-3", "expires": "19 April 2022", "valid": true}}]')

--- процедура, где по названию города будут выведены все кофейни--- 


