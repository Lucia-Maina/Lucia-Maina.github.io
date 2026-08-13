select 
     metric,
     price,
     quantity,
     total_sales
from 
(select 
     'count' as metric,
      count (price) as price,
      count (quantity) as quantity,
      count ("Total Sales") as total_sales,
      1 as sort_order
from amazon_sales

union all 

select 
     'sum' as metric,
      sum (price) as price,
      sum (quantity) as quantity,
      sum ("Total Sales") as total_sales,
      2 as sort_order
from amazon_sales

union all 

select 
     'mean' as metric,
      round(avg (price),2) as price,
      round(avg (quantity),2) as quantity,
      round(avg ("Total Sales"),2) as total_sales,
      3 as sort_order
from amazon_sales

union all 

select 
     'std' as metric,
      round(stddev_samp (price),2) as price,
      round(stddev_samp (quantity),2) as quantity,
      round(stddev_samp ("Total Sales"),2) as total_sales,
      4 as sort_order
from amazon_sales

union all

select 'mode' as metric,
       round(mode() within group (order by price)) as mode_price,
       round(mode() within group (order by quantity)) as mode_price,
       round(mode() within group (order by "Total Sales")) as mode_price,
       5 as sort_order
from amazon_sales

union all 

select 
     'min' as metric,
      min (price) as price,
      min (quantity) as quantity,
      min ("Total Sales") as total_sales,
      6 as sort_order
from amazon_sales

union all 

select 
     '25%' as metric,
      percentile_cont(0.25) within group (order by price) as price,
      percentile_cont(0.25) within group (order by quantity) as price,
      percentile_cont(0.25) within group (order by "Total Sales") as price,
      7 as sort_order
from amazon_sales

union all 

select 
     '50%' as metric,
      percentile_cont(0.5) within group (order by price) as price,
      percentile_cont(0.5) within group (order by quantity) as price,
      percentile_cont(0.5) within group (order by "Total Sales") as price,
      8 as sort_order
from amazon_sales

union all 

select 
     '75%' as metric,
      percentile_cont(0.75) within group (order by price) as price,
      percentile_cont(0.75) within group (order by quantity) as price,
      percentile_cont(0.75) within group (order by "Total Sales") as price,
      9 as sort_order
from amazon_sales

union all 

select 
     'max' as metric,
      max (price) as price,
      max (quantity) as quantity,
      max ("Total Sales") as total_sales,
      10 as sort_order
from amazon_sales
order by sort_order) as sorted_data;


