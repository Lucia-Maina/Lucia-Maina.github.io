

with category_rates as (
select 'Ethnicity' as variable,
ethnicity as category,
sum(case when diagnosed_diabetes = 1 then 1 else 0 end):: float/count(*) as diabetes_rate
from train 
group by ethnicity

union all 

select 'Education Level' as variable,
education_level as category,
sum(case when diagnosed_diabetes = 1 then 1 else 0 end):: float/count(*) as diabetes_rate
from train 
group by education_level

union all 

select 'Employment Status' as variable,
employment_status as category,
sum(case when diagnosed_diabetes = 1 then 1 else 0 end):: float/count(*) as diabetes_rate
from train 
group by employment_status

union all

select 'Gender' as variable,
gender as category,
sum(case when diagnosed_diabetes = 1 then 1 else 0 end):: float/count(*) as diabetes_rate
from train 
group by gender

union all 

select 'Income Level' as variable,
income_level as category,
sum(case when diagnosed_diabetes = 1 then 1 else 0 end):: float/count(*) as diabetes_rate
from train 
group by income_level 

union all 

select 'Smoking Status' as variable,
smoking_status as category,
sum(case when diagnosed_diabetes = 1 then 1 else 0 end):: float/count(*) as diabetes_rate
from train 
group by smoking_status

union all

select 'Family History' as variable,
case when family_history_diabetes = 1 then 'Yes' else 'No' end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train amazon_sales
group by family_history_diabetes

union all

select 'Hypertension history' as variable,
case when hypertension_history = 1 then 'Yes' else 'No' end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train
group by hypertension_history

union all

select 'Cardiovascular History' as variable,
case when cardiovascular_history = 1 then 'Yes' else 'No' end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
group by cardiovascular_history

union all

select 'Age' as variable,
case when age < 45 then '19-45'
     when age >= 45 and age < 57 then '45-56'
     when age >= 57 then '57+' end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where age is not null
group by category

union all

select 'Weekly Alcohol Consumption' as variable,
case when alcohol_consumption_per_week >=0 and alcohol_consumption_per_week <=3 then '0-3' 
     when alcohol_consumption_per_week > 3 and alcohol_consumption_per_week <=6 then '3-6' 
     when alcohol_consumption_per_week > 6 then '6+'   
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where alcohol_consumption_per_week is not null
group by category

union all

select 'Weekly Physical Activity/hrs' as variable,
case when (physical_activity_minutes_per_week/60) >=0 and (physical_activity_minutes_per_week/60) <= 4.15 then 'Low' 
     when (physical_activity_minutes_per_week/60) > 4.15 and (physical_activity_minutes_per_week/60) <=8.30 then 'Moderate' 
     when (physical_activity_minutes_per_week/60) > 8.30 then 'High'   
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where physical_activity_minutes_per_week is not null
group by category

union all

select 'Diet Score' as variable,
case when diet_score >=0 and diet_score <=3.4 then 'Low'
     when diet_score > 3.4 and diet_score <= 6.7 then 'Moderate' 
     when diet_score > 6.7 then 'High'   
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where diet_score is not null
group by category

union all

select 'Sleep Hours' as variable,
case when sleep_hours_per_day >=0 and sleep_hours_per_day <=5.4 then 'Low'
     when sleep_hours_per_day > 5.4 and sleep_hours_per_day <= 7.7 then 'Moderate' 
     when sleep_hours_per_day > 7.7 then 'High'   
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where sleep_hours_per_day is not null
group by category

union all

select 'Screen Time' as variable,
case when screen_time_hours_per_day  >=0 and screen_time_hours_per_day <=5.9 then 'Low'
     when screen_time_hours_per_day > 5.9 and screen_time_hours_per_day <= 11.2 then 'Moderate' 
     when screen_time_hours_per_day > 11.2 then 'High'   
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where screen_time_hours_per_day is not null
group by category

union all

select 'BMI' as variable,
case when BMI >= 15.1 and BMI <= 22.9 then 'Low'
     when BMI > 22.9 and BMI <= 30.7 then 'Moderate' 
     when BMI > 30.7 then 'High' 
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where BMI is not null
group by category 

union all

select 'Waist/Hip Ratio' as variable,
case when waist_to_hip_ratio  >= 0.68 and waist_to_hip_ratio <= 0.84 then 'Low '
     when waist_to_hip_ratio > 0.84 and waist_to_hip_ratio <= 0.87 then 'Medium ' 
     else 'High '
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where waist_to_hip_ratio is not null
group by category 

union all

select 'Systolic_bp' as variable,
case when systolic_bp <111 then 'Low '
     when systolic_bp >= 111 and systolic_bp <= 121 then 'Medium '
     else 'High '
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where systolic_bp is not null
group by category 

union all

select 'Diastolic_bp' as variable,
case when diastolic_bp <68 then 'Low '
     when diastolic_bp >= 68 and diastolic_bp <= 85 then 'Medium '
     else 'High '
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where diastolic_bp is not null
group by category 

union all

select 'Heart Rate' as variable,
case when heart_rate  < 61 then 'Low'
     when heart_rate >= 61 and heart_rate <= 80 then 'Normal'
     when heart_rate > 80 then 'High' 
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where heart_rate is not null
group by category 

union all

select 'Total Cholesterol' as variable,
case when cholesterol_total  < 174 then 'Low'
     when cholesterol_total  >= 174 and cholesterol_total <= 231 then 'Normal'
     when cholesterol_total  > 231 then 'High' 
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where cholesterol_total is not null
group by category 

union all

select 'Hdl Cholesterol' as variable,
case when hdl_cholesterol  < 44 then 'Low'
     when hdl_cholesterol  >= 44 and hdl_cholesterol <= 65 then 'Normal'
     when hdl_cholesterol  > 65 then 'High' 
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where hdl_cholesterol is not null
group by category 

union all

select 'Ldl Cholesterol' as variable,
case when ldl_cholesterol < 102 then 'Low'
     when ldl_cholesterol  >= 102 and ldl_cholesterol <= 154 then 'Normal'
     when ldl_cholesterol  > 154 then 'High' 
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where ldl_cholesterol is not null
group by category 

union all

select 'Triglycerides' as variable,
case when triglycerides  < 117 then 'Low'
     when triglycerides  >= 117 and triglycerides <= 203 then 'Normal'
     when triglycerides  > 203 then 'High' 
     end as category,
sum(case when diagnosed_diabetes =1 then 1 else 0 end)::float/count(*) as diabetes_rate
from train 
where triglycerides is not null
group by category 
)



select variable,
MAX (diabetes_rate) as max_rate,
MIN(diabetes_rate) as min_rate,
Trim((Round((MAX(diabetes_rate)- MIN(diabetes_rate))::decimal,5)):: text) as spread_pct
from category_rates
group by variable 
order by spread_pct




