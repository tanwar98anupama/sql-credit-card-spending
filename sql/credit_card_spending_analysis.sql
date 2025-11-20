/* ===========================================================
   Project: Credit Card Spending Analysis in India
   Author : Your Name
   DB     : sqlqueries_namastesql
   Table  : cct (credit card transactions)
   =========================================================== */

---------------------------------------------------------------
-- 0. Setup (database + table reference)
---------------------------------------------------------------

use sqlqueries_namastesql;

-- Main table: cct
select * from cct;

select distinct card_type from cct
select transaction_id, card_type from cct;


---------------------------------------------------------------
-- 1. Top 5 cities by spend and % contribution
---------------------------------------------------------------
-- Approach 1: CTE
WITH city_spend AS (
    SELECT 
        city,
        SUM(amount) AS city_amount
    FROM cct
    GROUP BY city
),
total_spend AS (
    SELECT SUM(city_amount) AS total_amount
    FROM city_spend
)
SELECT TOP 5 
    c.city,
    c.city_amount,
    ROUND(c.city_amount * 100.0 / t.total_amount, 2) AS pct_of_total
FROM city_spend c
CROSS JOIN total_spend t
ORDER BY c.city_amount DESC;

--type 2 sub query ("Learning alternatives")
select top 5 * from  (select city,sum(amount) amount from cct
group by city ) a left join 
(select sum(amount) total_amount from cct) b on 1 = 1 
order by amount desc;

--type 3 windows ("Learning alternatives")
select top 5 * from (
select distinct city,sum(amount) over (partition by city) as amount,
sum(amount) over (partition by 1) as  total_amount   from cct
 ) a  order by amount desc

---------------------------------------------------------------------------------------------
-- 2. Highest spend month and amount spent in that month for EACH card type (correct version)
---------------------------------------------------------------------------------------------
WITH A AS (select top 1 datename(month, transaction_date) month from cct
GROUP BY datename(month, transaction_date)
order by sum(amount) desc)

select datename(month, transaction_date) MONTH, card_type, sum(amount) amount_by_card from cct
where datename(month, transaction_date)= (select * from A)
group by datename(month, transaction_date), card_type

---------------------------------------------------------------
-- 3. Row where each card type first reaches 1,000,000 total spend
---------------------------------------------------------------
with cte as (
 select 
  *,
  sum(amount) over (partition by card_type order by transaction_date, transaction_id) as total_spend
 from cct
 )

select * 
from (
 select *, rank() over(partition by card_type order by total_spend) as rn  
 from cte 
 where total_spend >= 1000000) a 
where rn=1;

--------------------------------------------------------------------------------------
--4- City which had lowest percentage spend for gold card type
--------------------------------------------------------------------------------------
with cet as (select *,
sum(amount) over (partition by card_type) total_cc_spent
from cct)

select top 1 city,card_type, amount/total_cc_spent*100 perc_distri from cet
where card_type = 'gold'
order by perc_distri;

---------------------------------------------------------------------------------------------
--5- Print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
---------------------------------------------------------------------------------------------
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


---------------------------------------------------------------------------------------------
--6- Percentage contribution of spends by females for each expense type
---------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------
--8- Card and expense type combination saw highest month over month growth in Jan-2014
---------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------
--9- during weekends which city has highest total spend to total no of transcations ratio 
------------------------------------------------------------------------------------------
    select top 1 city, sum(amount)/count(transaction_id) as ratio 
    from cct 
    where DATEPART(WEEKDAY, transaction_date) IN (1,7) 
    group by city 
    order by ratio desc    

-------------------------------------------------------------------------------------------------------------------
--10- which city took least number of days to reach its 500th transaction after the first transaction in that city
 ------------------------------------------------------------------------------------------------------------------
select top 1 *,
       DATEDIFF(day,first_transaction_date,transaction_date) as date_diff_trans
from (
select *, 
       row_number() over (partition by city order by  transaction_date, transaction_id) as rnk, 
       MIN(transaction_date) over (partition by city) as first_transaction_date
from cct  ) a
where rnk = 500   

order by date_diff_trans  
