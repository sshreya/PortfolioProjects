## Insights
 Who are the top 10 customers who have spent the most and which country they belong to
 ```sql
select 
	CustomerID,
    Country,
    round(sum(Quantity * UnitPrice),2) as total_money_spent 
from 
	online_retail_clean 
group by 1,2
order by total_money_spent desc 
limit 10;
```
![](https://github.com/sshreya/PortfolioProjects/blob/main/Cohort%20Retention%20Analysis/images/Top%2010%20customers.png)

What is the monthly revenue
```sql
select 
	date_format(InvoiceDate,'%Y-%m-01') as month,
    round(sum(Quantity * UnitPrice),2) as revenue 
from 
	online_retail_clean
group by date_format(InvoiceDate,'%Y-%m-01');
```
![](https://github.com/sshreya/PortfolioProjects/blob/main/Cohort%20Retention%20Analysis/images/monthly%20revenue.png)

Calculating RFM score
```sql
with rfm as(
select 
    CustomerID,
    max(InvoiceDate) as latest_purchase_date,
    timestampdiff(day,max(InvoiceDate),cast('2012-01-01' as date)) as recency,
    count(distinct InvoiceNo) as frequency,
    round(sum(quantity * UnitPrice),2) as monetary
from 
     online_retail_clean 
group by 1
)
,score_cte as(
select 
    *,
    ntile(5)over(order by recency desc) as r_score,
    ntile(5)over(order by frequency) as f_score,
    ntile(5)over(order by monetary) as m_score 
from
    rfm 
)
select 	
     *,
    (100*r_score + 10*f_score + 1*m_score) as rfm_score 
from 
    score_cte 
;
```
This shows 3 clusters of customers based on the RFM score.

`Lapsed Customers` - Customers who 

![](https://github.com/sshreya/PortfolioProjects/blob/main/Cohort%20Retention%20Analysis/images/RFM%20score.png)
