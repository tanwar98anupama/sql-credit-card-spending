--SQL porfolio project.

/*download credit card transactions dataset from below link :
https://www.kaggle.com/datasets/thedevastator/analyzing-credit-card-spending-habits-in-india
import the dataset in sql server with table name : credit_card_transcations
change the column names to lower case before importing data to sql server.Also replace space within column names with underscore.
(alternatively you can use the dataset present in zip file)
while importing make sure to change the data types of columns. by defualt it shows everything as varchar.

write 4-6 queries to explore the dataset and put your findings */

use sqlqueries_namastesql;
select * from cct;

select distinct card_type from cct
select transaction_id, card_type from cct;


--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

/*select top 5 city from cct
group by city
order by sum(amount) desc;

select city, card_type, sum(amount) spending from cct
where city in (select top 5 city from cct
group by city
order by sum(amount) desc)
group by city, card_type;  */

--type-1 cte
with A as (select top 5 city,sum(amount) amount,(select sum(amount) total_amount from cct) t_amount from cct
group by city
order by sum(amount) desc)

select city, round((amount/t_amount*100),2) perc_distribution from A

--type 2 sub query
select top 5 * from  (select city,sum(amount) amount from cct
group by city ) a left join 
(select sum(amount) total_amount from cct) b on 1 = 1 
order by amount desc;

--type 3 windows
select top 5 * from (
select distinct city,sum(amount) over (partition by city) as amount,
sum(amount) over (partition by 1) as  total_amount   from cct
 ) a  order by amount desc

--2- write a query to print highest spend month and amount spent in that month for each card type
WITH A AS (select top 1 datename(month, transaction_date) month from cct
GROUP BY datename(month, transaction_date)
order by sum(amount) desc)

select datename(month, transaction_date) MONTH, card_type, sum(amount) amount_by_card from cct
where datename(month, transaction_date)= (select * from A)
group by datename(month, transaction_date), card_type

--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with cte as (select *,
sum(amount) over (partition by card_type order by transaction_date, transaction_id) as total_spend
from cct)

select * from (select *, rank() over(partition by card_type order by total_spend) as rn  
from cte where total_spend >= 1000000) a where rn=1;


--4- write a query to find city which had lowest percentage spend for gold card type
with cet as (select *,
sum(amount) over (partition by card_type) total_cc_spent
from cct)

select top 1 city,card_type, amount/total_cc_spent*100 perc_distri from cet
where card_type = 'gold'
order by perc_distri;


--5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

with cte as 
(select city, exp_type, sum(amount) amount_city_et from cct group by city,exp_type)
, min_cte as 
  (select city, exp_type as min_exp_type 
   from (select *, ROW_NUMBER() over (partition by city order by amount_city_et) as rnk from cte) a
   where rnk = 1 )
, max_cte as 
  (select city, exp_type as max_exp_type 
   from (select *, ROW_NUMBER() over (partition by city order by amount_city_et desc) as rnk from cte) a
   where rnk = 1 )
select * from max_cte join min_cte on min_cte.city = max_cte.city



--6- write a query to find percentage contribution of spends by females for each expense type
with A as (select exp_type, sum(amount) s_by_all from cct
group by exp_type)

, B as (select exp_type, sum(amount) s_by_female from cct
where gender= 'F'
group by exp_type)

SELECT A.exp_type, s_by_all, s_by_female, s_by_female/s_by_all* 100 perc_spend_female
from A left join B
on A.exp_type= B.exp_type
order by perc_spend_female desc ;

select exp_type,
sum(case when gender='F' then amount else 0 end)*100/sum(amount) as percentage_female_contribution
from cct
group by exp_type
order by percentage_female_contribution desc;


--8- which card and expense type combination saw highest month over month growth in Jan-2014

select TOP 1
       *,
       round((t_sale-last_t_sale)/last_t_sale*100,2) as growth

from (
select *, 
       sum(t_sale) over (partition by card_type, exp_type order by transaction_month ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) last_t_sale 

from (
select card_type, exp_type,cast(datetrunc(month, transaction_date) as date) as transaction_month, sum(amount) t_sale from cct
group by card_type, exp_type,cast(datetrunc(month, transaction_date) as date) ) a ) b
where transaction_month = cast('2014-01-01' as date)

order by growth  desc
 
 
       --sum(t_sale) over (partition by card_type, exp_type ) total_sale,
       --sum(t_sale) over (partition by card_type, exp_type order by transaction_month) total_sale, 
       --sum(t_sale) over (partition by card_type, exp_type order by transaction_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) total_sale ,  
       --sum(t_sale) over (partition by card_type, exp_type order by transaction_month ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) total_sale , 


--9- during weekends which city has highest total spend to total no of transcations ratio 

    select top 1 city, sum(amount)/count(transaction_id) as ratio 
    from cct 
    where DATEPART(WEEKDAY, transaction_date) IN (1,7) 
    group by city 
    order by ratio desc    


--10- which city took least number of days to reach its 500th transaction after the first transaction in that city

select top 1 *,
       DATEDIFF(day,first_transaction_date,transaction_date) as date_diff_trans
from (
select *, 
       row_number() over (partition by city order by  transaction_date, transaction_id) as rnk, 
       MIN(transaction_date) over (partition by city) as first_transaction_date
from cct  ) a
where rnk = 500   

order by date_diff_trans  


once you are done with this create a github repo to put that link in your resume. Some example github links:
https://github.com/ptyadana/SQL-Data-Analysis-and-Visualization-Projects/tree/master/Advanced%20SQL%20for%20Application%20Development
https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/COVID%20Portfolio%20Project%20-%20Data%20Exploration.sql