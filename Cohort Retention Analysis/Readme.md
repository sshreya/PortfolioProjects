# Cohort Retention Analysis 

## Overview
This project uses online retail data from UCI ML Repository.
Used SQL and python to understand user purchasing behaviour. 

**Cohort** means a group of users who share same characteristics and for this analysis, we have created time based cohorts. We have segmented customers into cohorts, based on the first date they made a purchase. 
This triangle graph tells us how many users have returned in the 1,2,3.....13th months after they made their first purchase. 

**Cohort Index** represents the number of months since the first purchase of the users. 

Formula for `Cohort Index` = 12 * (Invoice year - Cohort year) + (Invoice month - Cohort month) + 1

This analysis gives us customer retention rate and also we can further get churn rate from this analysis.

![](https://github.com/sshreya/PortfolioProjects/blob/main/Cohort%20Retention%20Analysis/images/Cohort%20Retention%20Rate.png)

Further, I have done RFM(Recency, Frequency, Monetary) Analysis on the customers to help this online retail business develop targeted marketing campaigns. This is a customer segmentation method used by businesses to create different clusters of customers 

`Recency` - How recently a customer has made a purchase

`Frequency` - How often a customer makes a purchase

`Monetary` - How much money is spent by a customer


## Dataset
This is a transactional data set which contains all the transactions occurring between 01/12/2010 and 09/12/2011 for a UK-based and registered non-store online retail.The company mainly sells unique all-occasion gifts. Many customers of the company are wholesalers.


- **Dataset Link:** - https://archive.ics.uci.edu/dataset/352/online+retail
- **Database:** - MySQL

- **Inspired by:** - https://youtu.be/LXqpx9mr0Is?si=bZWALOuAEgwO1wbp


