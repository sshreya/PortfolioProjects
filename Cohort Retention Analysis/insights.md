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
