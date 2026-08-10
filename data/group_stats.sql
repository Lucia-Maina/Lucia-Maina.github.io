


with category_summary as (
select 
row_number() over (order by sum("Total Sales") DESC) as rn,
category as group_name,
round(avg(price),2) as avg_price,
round(avg(quantity),2) as avg_quantity,
round(sum(quantity),2) as total_quantity,
round(avg("Total Sales"),2) as avg_sales,
round(sum("Total Sales"),2) as total_sales
from amazon_sales 
group by category
order by rn),


product_summary as (
select 
row_number() over (order by sum("Total Sales") DESC) as rn,
product as group_name,
round(avg(price),2) as avg_price,
round(avg(quantity),2) as avg_quantity,
round(sum(quantity),2) as total_quantity,
round(avg("Total Sales"),2) as avg_sales,
round(sum("Total Sales"),2) as total_sales
from amazon_sales 
group by product
order by rn),

location_summary as (
select
row_number() over (order by sum("Total Sales") DESC) as rn,
"Customer Location" as group_name,
round(avg(price),2) as avg_price,
round(avg(quantity),2) as avg_quantity,
round(sum(quantity),2) as total_quantity,
round(avg("Total Sales"),2) as avg_sales,
round(sum("Total Sales"),2) as total_sales
from amazon_sales 
group by "Customer Location"
order by rn),

payment_summary as (
select 
row_number() over (order by sum("Total Sales") DESC) as rn,
"Payment Method" as group_name,
round(avg(price),2) as avg_price,
round(avg(quantity),2) as avg_quantity,
round(sum(quantity),2) as total_quantity,
round(avg("Total Sales"),2) as avg_sales,
round(sum("Total Sales"),2) as total_sales
from amazon_sales 
group by "Payment Method" 
order by rn),

status_summary as (
select 
row_number() over (order by sum("Total Sales") DESC) as rn,
status as group_name,
round(avg(price),2) as avg_price,
round(avg(quantity),2) as avg_quantity,
round(sum(quantity),2) as total_quantity,
round(avg("Total Sales"),2) as avg_sales,
round(sum("Total Sales"),2) as total_sales
from amazon_sales 
group by status
order by rn)


select 
   case when rn = 1 then 'Category' else ' ' end as source_column,
   group_name,
   avg_price,
   avg_quantity,
   total_quantity,
   avg_sales,
   total_sales
from category_summary

union all 

select
case when rn = 1 then 'Product' else ' ' end as source_column,
   group_name,
   avg_price,
   avg_quantity,
   total_quantity,
   avg_sales,
   total_sales
from product_summary

union all

select
case when rn = 1 then 'Customer Location' else ' ' end as source_column,
   group_name,
   avg_price,
   avg_quantity,
   total_quantity,
   avg_sales,
   total_sales
from location_summary

union all 

select
case when rn = 1 then 'Payment Method' else ' ' end as source_column,
   group_name,
   avg_price,
   avg_quantity,
   total_quantity,
   avg_sales,
   total_sales
from payment_summary

union all

select
case when rn = 1 then 'Status' else ' ' end as source_column,
   group_name,
   avg_price,
   avg_quantity,
   total_quantity,
   avg_sales,
   total_sales
from status_summary;
















