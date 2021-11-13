import psycopg
import json
import csv

class App(object):
    def __init__(self, db, user, password, host, port):
        self.connection = psycopg.connect(db, user, password, host, port)

        self.CreateCofeeShopTable()
        self.CreateCityTable()
        self.CreateCountryGDPTable()
        self.CreateSurveyTable()

    def CreateCoffeeShopTable(self):
        with self.connection.cursor() as cur:
            cur.execute(
                '''
                CREATE TABLE IF NOT EXISTS coffee_shop(
                    id  varchar PRIMARY KEY,
                    store_name varchar NOT NULL,
                    city_name varchar REFERENCES city(city),
                    country_name varchar NOT NULL
                    customer_of_the_week_name varchar REFERENCES survey(name)
                    )
                '''
            )
        self.connection.commit()

    def CreateSurveyTable(self):
        with self.connection.cursor() as cur:
            cur.execute(
                '''
                CREATE TABLE IF NOT EXISTS survey(
                    country varchar NOT NULL
                    subset varchar NOT NULL
                    question_label varchar NOT NULL
                    answer varchar NOT NULL
                    name varchar NOT NULL
                    )
                '''
            )
        self.connection.commit()

    def CreateCityTable(self):
        with self.connection.cursor() as cur:
            cur.execute(
                '''
                CREATE TABLE IF NOT EXISTS city(
                    city  varchar NOT NULL,
                    country_name varchar REFERENCES country_gdp(Country),
                    admin_name varchar NOT NULL,
                    capital bool NOT NULL,
                    population float NOT NULL,
                    id bigint PRIMARY KEY
                '''
            )
        self.connection.commit()

    def CreateCountryGDPTable(self):
        with self.connection.cursor() as cur:
            cur.execute(
                '''
                CREATE TABLE IF NOT EXISTS country_gdp(
                    country varchar PRIMARY KEY,
                    country_code varchar NOT NULL,
                    gdp_1990 float NOT NULL,
                    gdp_2000 float NOT NULL,
                    gdp_2006 float NOT NULL,
                    gdp_2011 float NOT NULL,
                    gdp_2018 float NOT NULL,
                    )
                '''
            )
        self.connection.commit()

    def insertCoffeeShopTable(self, shops):
        with self.connection.cursor() as cur:
            coffee_shops_regex = ','.join(['%s'] * len(shops))
            cur.execute(
                'INSERT INTO '
                'coffee_shop '
                '(id, store_name, '
                'city_name, country_name, customer_of_the_week) '
                'VALUES ' + coffee_shops_regex, shops)

        self.connection.commit()

    def insertCityTable(self, cities):
        with self.connection.cursor() as cur:
            cities_regex = ','.join(['%s'] * len(cities))
            cur.execute(
                'INSERT INTO '
                'city '
                '(city, country_name, admin_name, capital, population, id)'
                'VALUES ' + cities_regex, cities)

        self.connection.commit()

    def insertCountryTable(self, countries):
        with self.connection.cursor() as cur:
            countries_regex = ','.join(['%s'] * len(countries))
            cur.execute(
                'INSERT INTO '
                'country '
                '(coumtry, country_code'
                'gdp_1990, gdp_2000, gdp_2006'
                'gdp_2011, gdp_2018)'
                'VALUES ' + countries_regex, countries)

        self.connection.commit()

    def insertSurveyTable(self, surveys):
        with self.connection.cursor() as cur:
            surveys_regex = ','.join(['%s'] * len(surveys))
            cur.execute(
                'INSERT INTO '
                'survey '
                '(country, subset, question_label'
                'answer)'
                'VALUES ' + surveys_regex, surveys)

        self.connection.commit()

    def rollback(self):
        with self.connection.cursor() as cur:
            cur.execute('rollback')

        self.connection.commit()
