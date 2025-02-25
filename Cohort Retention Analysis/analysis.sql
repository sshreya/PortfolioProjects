-- data cleaning
delete from online_retail where CustomerID = 0;

-- remove -ve sign from quantity
select count(*) from online_retail where Quantity < 0;
update online_retail set Quantity = -1 * Quantity where Quantity < 0;
    
-- change datatype of InvoiceDate column from string to date

update online_retail set InvoiceDate = str_to_date(InvoiceDate,'%d.%m.%Y %H:%i');
select * from online_retail limit 5;

-- creating new tbale without the duplicate rows
create table online_retail_clean as select InvoiceNo, StockCode, Description, Quantity,InvoiceDate, UnitPrice,CustomerID, Country from(
select 
	*,
    row_number()over(partition by InvoiceNo,StockCode,Quantity order by InvoiceDate) as rn 
from 
	online_retail 
)x 
where x.rn = 1
;

-- checking if online_retail_clean has any duplicate rows
select * from (
select 
	*,
    row_number()over(partition by InvoiceNo,StockCode,Quantity order by InvoiceDate) as rn 
from 
	online_retail_clean
)x
where x.rn > 1;

-- Creating cohorts based on first purchase date for each customer
select
   CustomerID,
   min(InvoiceDate) as InvoiceDate,
   date_format(min(InvoiceDate),'%Y-%m-01') as CohortDate
from 
    online_retail
group by 1;

-- CREATE COHORT INDEX
-- NUMBER OF MONTHS THAT HAVE PASSED SINCE THE CUSTOMER'S FIRST ENGAGEMENT
-- Cohort Index=(Year of Purchase−Cohort Year)×12+(Month of Purchase−Cohort Month)+1
with cohort_cte as(
select
	CustomerID,
	min(InvoiceDate) as InvoiceDate,
  date_format(min(InvoiceDate),'%Y-%m-01') as CohortDate
from 
	online_retail
group by 1
)
,cte_1 as(
select 
	ot.*,
    cc.CohortDate,
    timestampdiff(month,cc.CohortDate,ot.InvoiceDate)+ 1 as cohort_index
from 
	cohort_cte cc 
join 
	online_retail ot
on cc.CustomerID = ot.CustomerID
order by customerID, cohort_index
)
,cte_2 as(
select 
	distinct 
    CustomerID,
    CohortDate,
    cohort_index 
from 
	cte_1 
order by CustomerID,cohort_index
)
select 
	CohortDate,
    count(case when cohort_index = 1 then CustomerID end) as '1',
    count(case when cohort_index = 2 then CustomerID end) as '2',
    count(case when cohort_index = 3 then CustomerID end) as '3',
    count(case when cohort_index = 4 then CustomerID end) as '4',
    count(case when cohort_index = 5 then CustomerID end) as '5',
    count(case when cohort_index = 6 then CustomerID end) as '6',
    count(case when cohort_index = 7 then CustomerID end) as '7',
    count(case when cohort_index = 8 then CustomerID end) as '8',
    count(case when cohort_index = 9 then CustomerID end) as '9',
    count(case when cohort_index = 10 then CustomerID end) as '10',
    count(case when cohort_index = 11 then CustomerID end) as '11',
    count(case when cohort_index = 12 then CustomerID end) as '12',
    count(case when cohort_index = 13 then CustomerID end) as '13'
from 
	cte_2 
group by 1
order by 1;
