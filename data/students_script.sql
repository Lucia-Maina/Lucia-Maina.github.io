-- Create backup of raw dataset
drop table if exists unclean_dataset_backup;
create table unclean_dataset_backup as 
select * 
from unclean_dataset_v2;
 
-- Step 1: Create staging table for cleaned data
create table if not exists clean_dataset_students (
student_id INT generated always as identity primary key,
first_name VARCHAR (200),
last_name VARCHAR (200),
age INT,
gender VARCHAR (30),
course VARCHAR (200),
enrollment_date DATE, 
total_payment numeric);

-- Step 2: Clear staging table and reset identity sequence before insert
truncate table clean_dataset_students restart identity;

-- Step 3: Insert pipe-delimited rows
-- NOTE: Pipe-delimited rows use USD($). Converting to GBP at 1 GBP = 1.3453 USD (average rate, 2026)
insert into clean_dataset_students (first_name, last_name, age, gender, course,enrollment_date, total_payment)
select 
trim(split_part("Student_ID", '|',2)) as first_name, 
coalesce(nullif(trim(split_part("Student_ID", '|',3)), ''), trim(first_name)) as last_name, 
trim(split_part("Student_ID", '|',4))::int as age,
trim(split_part("Student_ID", '|',5)) as gender,   
case when trim(split_part("Student_ID", '|',6)) = 'Machine Learnin' then 'Machine Learning'
      when trim(split_part("Student_ID", '|',6)) = 'Web Developmen' then 'Web Development' else 
      trim(split_part("Student_ID", '|',6)) end as course, 
nullif(nullif(trim(split_part("Student_ID", '|',7)),'NA'), '')::date as enrollment_date, 
round(trim(replace(split_part("Student_ID", '|',8),'$',''))::numeric(10,2)/1.3453,2) as total_payment
from unclean_dataset_v2 
where "Student_ID" like '%|%';

-- Step 4: Insert non-pipe-delimited rows
-- NOTE: Most non-pipe- delimited rows are in GBP, no conversion required
-- Approximately 19 records have '?' symbol, treated as GBP based on magnitude alignmen (values >£20K align with GBP, not USD patterns)

insert into clean_dataset_students (first_name, last_name, age, gender, course,enrollment_date, total_payment)
select
nullif(case when trim(first_name) like '% %' then 
       substring(trim(first_name), 1, position(' ' in trim(first_name)) -1)
       else trim(first_name) end, '') as first_name,
 nullif(case when trim(first_name) like '% %' then 
       substring(trim(first_name), position(' 'in trim(first_name)) +1)
       when trim(last_name) != ' ' then trim(last_name)
       else null end, '') as last_name,   
 case 
	 when coalesce
	 (nullif(regexp_replace(trim(age), '[^0-9]', '','g'),'')::INT, regexp_substr(trim(gender), '[0-9]+')::INT) 
	 not between 16 and 70 then null 
	 else coalesce
	 (nullif(regexp_replace(trim(age), '[^0-9]', '','g'),'')::INT, regexp_substr(trim(gender), '[0-9]+')::INT) 
	 end as age, 
 case
	 when upper(left(trim(age),1)) in ('F','M') then upper(left(trim(age),1)) 
	 when upper(left(trim(gender),1)) in ('F','M') then upper(left(trim(gender),1)) 
     else null end as gender, 
 case when trim(course) = '' then null
      when trim(course) ~ '^[0-9]+$' then null
 else 
 case when trim(course) = 'Web Developmet' then 'Web Development'
      when trim(course) = 'Web Develpment' then 'Web Development'
 	  when trim(course) = 'Data Analystics' then 'Data Analysis'
 	  when trim(course) = 'Data Analisys' then 'Data Analysis'
 	  when trim(course) = 'Machine Lerning' then 'Machine Learning'
 	  when trim(course) = 'Cyber Securty' then 'Cyber Security'
 	  when trim(course) = 'Machine Learnin' then 'Machine Learning'
 	  when trim(course) = 'Data Analytics' then 'Data Analysis'
 	  when trim(course) = 'Web Developmen' then 'Web Development'
 	  else trim(course) end
 end as course,
  trim(enrollment_date)::DATE as enrollment_date,
  round(nullif(regexp_replace(trim(total_payments),'[^0-9.]','','g'),'')::numeric(10,2),2) as total_payment
from unclean_dataset_v2
where "Student_ID" not like '%|%';

-- Step 5: Remoove exact and fuzzy duplicates (54 records total)
drop table if exists clean_students;
create table clean_students as 
select row_number() over (order by total_payment) as student_id,
rn,
first_name,
last_name,
age,
gender,
course,
enrollment_date,
total_payment
from  (
select 
first_name,
last_name,
age,
gender,
course,
enrollment_date,
total_payment,
row_number() over (partition by age,gender,course,enrollment_date,total_payment
                   order by first_name,last_name) as rn
from clean_dataset_students)
where rn=1;


-- Step 6: Create view for formatted output
create or replace view students_view as 
select row_number() over (order by total_payment asc)::int as student_id,
first_name,
last_name,
age,
gender,
course,
enrollment_date,
to_char(total_payment, '£FM9,999,999.00') as total_payment,
total_payment as total_payment_numeric
from clean_students
order by total_payment_numeric;

-- Step 7: Query cleaned dataset from view
select 
student_id,
first_name,
last_name,
age,
gender,
course,
enrollment_date,
total_payment
from students_view
order by total_payment_numeric;








