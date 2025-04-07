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
Tableau automatically creates 5 clusters of customers based on the RFM score.

![](https://github.com/sshreya/PortfolioProjects/blob/main/Cohort%20Retention%20Analysis/images/RFM%20Score.png)

`Cluster 1` - `High-Value Loyal Customers` 

1. Most recent purchases
2. Highest purchase frequency
3. Highest monetary value
4. These are your best customers - frequent shoppers who spend significantly more than other clusters and have purchased recently. They likely represent the core customer base driving most of your revenue.

`Cluster 2` - `Active Mid-Value Customers`

1. Fairly recent purchases
2. Moderate purchase frequency
3. Moderate spending
4. These are good,reliable customers who purchase regularly but spend less than Cluster 1. They represent growth potential if we can increase their spending.

`Cluster 5` - `At-Risk Mid-Value Customers`

1. Less recent purchases
2. Lower purchase frequency
3. Lower spending
4. These customers show declining engagement. They used to purchase but are becoming inactive. Re-engagement campaigns could help bring them back.

`Cluster 3` - `Dormant Low-Value Customers` 

1. Inactive for a long time
2. Very low purchase frequency
3. Low spending
4. These customers have largely disengaged and might need strong incentives to return.

`Cluster 4` - `Lost Customers`

1. Highly inactive
2. Lowest purchase frequency
3. Lowest monetary value
4. These customers have effectively churned. They made few purchases and haven't returned in nearly a year.

This clustering suggests a clear segmentation strategy for marketing efforts, with focus on retaining Cluster 1, developing Cluster 2, reactivating Cluster 5, and potentially using different approaches for Clusters 3 and 4 depending on acquisition costs versus potential lifetime value.

![](https://github.com/sshreya/PortfolioProjects/blob/main/Cohort%20Retention%20Analysis/images/Customer%20clusters.png)

### Given that the UCI Online Retail dataset specifically mentions that "many customers of the company are wholesalers" the RFM analysis also suggests a similar segregation. 

Potential Wholesalers (Business Customers):

`Cluster 1`: With average spending of £5,763 and high frequency (11 purchases), these display classic wholesaler behavior - frequent, large-volume purchases.

`Cluster 2`: Spending £2,029 on average with moderate frequency (6 purchases) could represent smaller wholesalers or business customers with less frequent restocking needs.

`Cluster 5`: With £1,326 average spend and decreasing recency, these might be smaller wholesalers or business customers who are becoming less active.

Potential Retail Customers:

`Cluster 3 & 4`: With significantly lower monetary values (£919 and £804) and much lower frequency (3 and 2 purchases), these align with typical retail customer behavior - occasional, smaller purchases.

The monetary value is particularly telling here - the nearly 6x difference between Cluster 1 and Cluster 4 strongly suggests different customer types rather than just different engagement levels within the same customer type.
