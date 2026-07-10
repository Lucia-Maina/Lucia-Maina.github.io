-- Create backup of raw dataset
DROP TABLE IF EXISTS unclean_dataset_backup;
CREATE TABLE unclean_dataset_backup AS 
SELECT * 
FROM unclean_dataset_v2;
 
-- Step 1: Create staging table for cleaned data
DROP VIEW IF EXISTS clean_students_display;
DROP VIEW IF EXISTS clean_students_view;

DROP TABLE IF EXISTS clean_dataset_students;
CREATE TABLE clean_dataset_students (
student_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
first_name VARCHAR (200),
last_name VARCHAR (200),
age INT,
gender VARCHAR (30),
course VARCHAR (200),
enrollment_date DATE, 
total_payment NUMERIC);

-- Step 2: Clear staging table and reset identity sequence before insert
TRUNCATE TABLE clean_dataset_students RESTART IDENTITY;

-- Step 3: Insert pipe-delimited rows
-- NOTE: Pipe-delimited rows use USD($). Converting to GBP at 1 GBP = 1.3453 USD (average rate, 2026)
INSERT INTO clean_dataset_students (first_name, last_name, age, gender, course,enrollment_date, total_payment)
SELECT 
TRIM(SPLIT_PART("Student_ID", '|',2)) AS first_name, 
COALESCE(NULLIF(TRIM(SPLIT_PART("Student_ID", '|',3)), ''), TRIM(first_name)) AS last_name, 
TRIM(SPLIT_PART("Student_ID", '|',4))::INT AS age,
TRIM(SPLIT_PART("Student_ID", '|',5)) AS gender,   
CASE WHEN TRIM(SPLIT_PART("Student_ID", '|',6)) = 'Machine Learnin' THEN 'Machine Learning'
      WHEN TRIM(SPLIT_PART("Student_ID", '|',6)) = 'Web Developmen' THEN 'Web Development' ELSE 
      TRIM(SPLIT_PART("Student_ID", '|',6)) END AS course, 
NULLIF(NULLIF(TRIM(SPLIT_PART("Student_ID", '|',7)),'NA'), '')::DATE AS enrollment_date, 
ROUND(TRIM(REPLACE(SPLIT_PART("Student_ID", '|',8),'$',''))::NUMERIC(10,2)/1.3453,2) AS total_payment
FROM unclean_dataset_v2 
WHERE "Student_ID" LIKE '%|%';

-- Step 4: Insert non-pipe-delimited rows
-- NOTE: Most non-pipe- delimited rows are in GBP, no conversion required
-- Approximately 19 records have '?' symbol, treated as GBP based on magnitude alignmen (values >£20K align with GBP, not USD patterns)

INSERT INTO clean_dataset_students (first_name, last_name, age, gender, course,enrollment_date, total_payment)
SELECT
NULLIF(CASE WHEN TRIM(first_name) LIKE '% %' THEN 
       SUBSTRING(TRIM(first_name), 1, POSITION(' ' IN TRIM(first_name)) -1)
       ELSE TRIM(first_name) END, '') AS first_name,
 NULLIF(CASE WHEN TRIM(first_name) LIKE '% %' THEN 
       SUBSTRING(TRIM(first_name), POSITION(' ' IN TRIM(first_name)) +1)
       WHEN TRIM(last_name) != ' ' THEN TRIM(last_name)
       ELSE NULL END, '') AS last_name,   
 CASE 
	 WHEN COALESCE
	 (NULLIF(REGEXP_REPLACE(TRIM(age), '[^0-9]', '','g'),'')::INT, REGEXP_SUBSTR(TRIM(gender), '[0-9]+')::INT) 
	 NOT BETWEEN 16 AND 70 THEN NULL 
	 ELSE COALESCE
	 (NULLIF(REGEXP_REPLACE(TRIM(age), '[^0-9]', '','g'),'')::INT, REGEXP_SUBSTR(TRIM(gender), '[0-9]+')::INT) 
	 END AS age, 
 CASE
	 WHEN UPPER(LEFT(TRIM(age),1)) IN ('F','M') THEN UPPER(LEFT(TRIM(age),1)) 
	 WHEN UPPER(LEFT(TRIM(gender),1)) IN ('F','M') THEN UPPER(LEFT(TRIM(gender),1)) 
     ELSE NULL END AS gender, 
 CASE WHEN TRIM(course) = '' THEN NULL
      WHEN TRIM(course) ~ '^[0-9]+$' THEN NULL
 ELSE 
 CASE WHEN TRIM(course) = 'Web Developmet' THEN 'Web Development'
      WHEN TRIM(course) = 'Web Develpment' THEN 'Web Development'
 	  WHEN TRIM(course) = 'Data Analystics' THEN 'Data Analysis'
 	  WHEN TRIM(course) = 'Data Analisys' THEN 'Data Analysis'
 	  WHEN TRIM(course) = 'Machine Lerning' THEN 'Machine Learning'
 	  WHEN TRIM(course) = 'Cyber Securty' THEN 'Cyber Security'
 	  WHEN TRIM(course) = 'Machine Learnin' THEN 'Machine Learning'
 	  WHEN TRIM(course) = 'Data Analytics' THEN 'Data Analysis'
 	  WHEN TRIM(course) = 'Web Developmen' THEN 'Web Development'
 	  ELSE TRIM(course) END
 END AS course,
  TRIM(enrollment_date)::DATE AS enrollment_date,
  ROUND(NULLIF(REGEXP_REPLACE(TRIM(total_payments),'[^0-9.]','','g'),'')::NUMERIC(10,2),2) AS total_payment
FROM unclean_dataset_v2
WHERE "Student_ID" NOT LIKE '%|%';

-- Step 5: Remove exact and fuzzy duplicates (54 records total)
DROP VIEW IF EXISTS students_view;

DROP TABLE IF EXISTS clean_students;
CREATE TABLE clean_students AS
SELECT ROW_NUMBER() OVER (ORDER BY total_payment) AS student_id,
rn,
first_name,
last_name,
age,
gender,
course,
enrollment_date,
total_payment
 FROM  (
SELECT 
first_name,
last_name,
age,
gender,
course,
enrollment_date,
total_payment,
ROW_NUMBER() OVER (PARTITION BY age,gender,course,enrollment_date,total_payment
                   ORDER BY first_name,last_name) AS rn
FROM clean_dataset_students)
WHERE rn=1;

-- Step 6: Handle problematic data quality issues
-- DELETE rows WHERE first_name AND last_name IS NULL
DELETE FROM clean_students 
WHERE first_name IS NULL AND last_name IS NULL;
 
UPDATE clean_students 
SET enrollment_date = 
    (SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY enrollment_date) AS median
      FROM clean_students
     WHERE enrollment_date IS NOT NULL 
     AND EXTRACT(year FROM enrollment_date) >= 2000)
WHERE EXTRACT(year FROM enrollment_date) = 1999;

-- Step 7: Create view for formatted output
CREATE OR REPLACE VIEW students_view AS 
SELECT ROW_NUMBER() OVER (ORDER BY total_payment ASC)::INT AS student_id,
first_name,
last_name,
age,
gender,
course,
enrollment_date,
TO_CHAR(total_payment, '£FM9,999,999.00') AS total_payment,
total_payment AS total_payment_numeric
FROM clean_students
ORDER BY total_payment_numeric;

-- Step 8: Query cleaned dataset FROM view
SELECT 
student_id,
first_name,
last_name,
age,
gender,
course,
enrollment_date,
total_payment
FROM students_view
ORDER BY total_payment_numeric;
