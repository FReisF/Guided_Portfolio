create database corona character set utf8mb4 collate utf8mb4_unicode_ci;
use corona;

create table covid_data (
    iso_code varchar(4),
    continent varchar(15),
    location varchar(60),
    date_register date,
    total_cases int,
    new_cases int,
    new_cases_smoothed double,
    total_deaths int,
    new_deaths int,
    new_deaths_smoothed double,
    total_cases_per_million double,
    new_cases_per_million double,
    new_cases_smoothed_per_million double,
    total_deaths_per_million double,
    new_deaths_per_million double,
    new_deaths_smoothed_per_million double,
    repreduction_rate double,
    icu_patients int,
    icu_patients_per_million double,
    hosp_patients int,
    hosp_patients_per_million double,
    weekly_icu_admissions int,
    weekly_icu_admissions_per_million double,
    weekly_hosp_admissions int,
    weekly_hosp_admissions_per_million double,
    new_tests int,
    total_tests int,
    total_tests_per_thousand double,
    new_tests_per_thousand double,
    new_tests_smoothed double,
    new_tests_smoothed_per_thousand double,
    positive_rate double,
    tests_per_case double,
    test_units varchar (50),
    total_vaccinations int,
    people_vaccinated int,
    people_fully_vaccinated int,
    total_boosters int,
    new_vaccinations int,
    new_vaccinations_smoothed double,
    total_vaccinations_per_hundred double,
    people_vaccinated_per_hundred double,
    people_fully_vaccinated_per_hundred double,
    total_boosters_per_hundred double,
    new_vaccinations_smoothed_per_million double,
    new_people_vaccinated_smoothed double,
    new_people_vaccinated_smoothed_per_hundred double,
    stringency_index double,
    population int,
    population_density double,
    median_age double,
    aged_65_older double,
    aged_70_older double,
    gdp_per_capta double,
    extreme_poverty double,
    cardiovascular_death_rate double,
    diabetes_prevalence double,
    female_smokers double,
    male_smokers double,
    handwashing_facilities double,
    hospital_beds_per_thousand double,
    life_expectancy double,
    human_development_index double,
    excess_mortality_cummulative_absolute double,
    excess_mortality_cummulative double,
    excess_mortality double,
    excess_mortality_cumulative_per_million double
);
load data infile 'C:\\wamp64\\tmp\\covid_data.csv'
into table covid_data
fields terminated by ','
ignore 1 rows;

select * from covid_data;

alter table covid_data
drop column new_deaths_smoothed,
drop column total_cases_per_million,
drop column new_cases_per_million,
drop column new_cases_smoothed_per_million,
drop column total_deaths_per_million,
drop column new_deaths_per_million,
drop column new_deaths_smoothed_per_million,
drop column icu_patients_per_million,
drop column hosp_patients_per_million,
drop column weekly_icu_admissions_per_million,
drop column weekly_hosp_admissions_per_million,
drop column total_tests_per_thousand,
drop column new_tests_per_thousand,
drop column new_tests_smoothed,
drop column new_tests_smoothed_per_thousand,
drop column tests_per_case,
drop column new_vaccinations_smoothed,
drop column total_vaccinations_per_hundred,
drop column people_vaccinated_per_hundred,
drop column people_fully_vaccinated_per_hundred,
drop column total_boosters_per_hundred,
drop column new_vaccinations_smoothed_per_million,
drop column new_people_vaccinated_smoothed,
drop column new_people_vaccinated_smoothed_per_hundred,
drop column excess_mortality_cumulative_per_million;

alter table covid_data
add column register_id varchar(30) first;

update covid_data
set register_id = concat(iso_code,date_register);

/*Select Country Data*/
create table country_data (	
    register_id varchar(30),
    iso_code varchar(4),
    continent varchar(15),
    location varchar(60),
    date_register date,
    stringency_index double,
    population int,
    population_density double,
    median_age double,
    aged_65_older double,
    aged_70_older double,
    gdp_per_capta double,
    extreme_poverty double,
    cardiovascular_death_rate double,
    diabetes_prevalence double,
    female_smokers double,
    male_smokers double,
    handwashing_facilities double,
    hospital_beds_per_thousand double,
    life_expectancy double,
    human_development_index double,
    excess_mortality_cummulative_absolute double,
    excess_mortality_cummulative double,
    excess_mortality double);

insert into country_data
select register_id,
    iso_code,
    continent,
    location,
    date_register,
    stringency_index,
    population,
    population_density,
    median_age,
    aged_65_older,
    aged_70_older,
    gdp_per_capta,
    extreme_poverty,
    cardiovascular_death_rate,
    diabetes_prevalence,
    female_smokers,
    male_smokers,
    handwashing_facilities,
    hospital_beds_per_thousand,
    life_expectancy,
    human_development_index,
    excess_mortality_cummulative_absolute,
    excess_mortality_cummulative,
    excess_mortality from covid_data;
/*Separate Cases Data*/
create table cases_data (
	register_id varchar(30),
    iso_code varchar(4),
    location varchar(60),
    date_register date,
    total_cases int,
    new_cases int,
    repreduction_rate double);
    
insert into cases_data select 
	register_id,
    iso_code,
	location,
    date_register,
    total_cases,
    new_cases,
    repreduction_rate from covid_data;
/*Separate Hospitalization Data*/

create table hospitalization_data (
    register_id varchar(30),
    iso_code varchar(4),
    location varchar(60),
    date_register date,
    total_cases int,
    repreduction_rate double,
    icu_patients int,
    hosp_patients int);


insert into hospitalization_data select 
	register_id,
    iso_code,
    location,
    date_register,
    total_cases,
    repreduction_rate,
    icu_patients,
    hosp_patients from covid_data;

/*Death Data*/
create table death_data (
    register_id varchar(30),
    iso_code varchar(4),
    location varchar(60),
    date_register date,
    total_deaths int,
    new_deaths int);
    
insert into death_data select 
	register_id,
    iso_code,
    location,
    date_register,
    total_deaths,
    new_deaths from covid_data;

/*Tests Data*/
create table tests_data (
    register_id varchar(30),
    iso_code varchar(4),
    location varchar(60),
    date_register date,
    new_tests int,
    total_tests int,
    positive_rate double,
    test_units varchar (50));
    
insert into tests_data select 
	register_id,
    iso_code,
    location,
    date_register,
    new_tests,
    total_tests,
    positive_rate,
    test_units from covid_data;

/*Vaccination Data*/

create table vaccination_data (
    register_id varchar(30),
    iso_code varchar(4),
    location varchar(60),
    date_register date,
    total_vaccinations int,
    people_vaccinated int,
    people_fully_vaccinated int,
    total_boosters int,
    new_vaccinations int);
    
insert into vaccination_data select 
	register_id,
    iso_code,
    location,
    date_register,
    total_vaccinations,
    people_vaccinated,
    people_fully_vaccinated,
    total_boosters,
    new_vaccinations from covid_data;


