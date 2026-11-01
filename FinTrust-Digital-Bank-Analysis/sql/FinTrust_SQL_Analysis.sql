-- 1. Who are the 2 customers with the highest level of engagement(by transaction frequency)?
SELECT t.Customer_ID,
		c.Customer_Name,
		COUNT(t.Customer_ID) AS Transaction_frequency
FROM fintrust_customer_data c
JOIN fintrust_transaction_clean t
ON t.Customer_ID=c.Customer_ID
GROUP BY t.Customer_ID,
		 c.Customer_Name
ORDER BY Transaction_frequency DESC
LIMIT 2;

-- Result: Fatima Adeyemi and Tunde Garba has the highest engagement level with 20 and 19 transaction frequency.
-- Business Interpretation: Fatima Adeyemi and Tunde Garba stand out as FinTrust's most engaged customers.
-- This level of activity suggests they may be high-value, loyal users whose behavior could inform retention strategies.


-- 2. What day of the week sees the highest transaction activity? 
SELECT DAYNAME(Transaction_DateTime) AS day_of_week,
	   COUNT(*) AS transaction_volume,
       SUM(Amount_NGN) AS total_value
FROM fintrust_transaction_clean
GROUP BY DAYNAME(Transaction_DateTime)
order by transaction_volume DESC;

-- Result:Transactions are done mostly on Saturdays and Sundays.
-- Business Interpretation: This suggests that customers are most likely to bank when they are off work or have more free time
-- to manage personal finances. Since transactions peak on weekend, FinTrust should ensure system capacity and customer support are strongest on these days to match customer demands. 


-- 3. What is the total transaction value spent per customer?
SELECT t.Customer_ID,
		c.Customer_Name,
		SUM(t.Amount_NGN) AS Transaction_Value
FROM fintrust_customer_data c
JOIN fintrust_transaction_clean t
ON t.Customer_ID=c.Customer_ID 
GROUP BY t.Customer_ID,
		 c.Customer_Name;
         
-- Result: This shows the total amount spent per customer using FinTrust bank.
-- Business Interpretation: This identifies high-value customers who contributes the most revenue. These insights can guide targeted retention efforts, 
-- personalized offers, or loyalty programs aimed at FinTrust's top-spending customers.

        
-- 4. What channel generates the highest total transaction value among successful transactions, and how many successful transactions does each channel have?
SELECT Channel,
	   SUM(Amount_NGN) AS Transaction_Value,
       COUNT(Transaction_Status) AS Successful_transactions
FROM fintrust_transaction_clean
WHERE Transaction_Status = "Successful"
GROUP BY Channel
ORDER BY Successful_transactions DESC;

-- Result: Mobile App generated the highest successful transaction value at N143,385,712 and also has the highest successful transactions.
-- Business Interpretation: Mobile App is FinTrust's primary revenue-driving channel among successful transactions, suggesting continued investment 
-- in mobile app performance and UX could yield the highest returns.


-- 5. Which transaction type generates the highest average transaction value?
SELECT Transaction_Type,
	   AVG(Amount_NGN) AS AVG_Transaction_Value
FROM fintrust_transaction_clean
GROUP BY Transaction_Type
ORDER BY AVG_Transaction_Value DESC;

-- Result: Deposit transactions are done more on average among the transaction type
-- Business Interpretation: This shows that FinTrust customers primarily use the platform to add funds; an opportunity to promote savings or investment products.


-- 6. What is the overall rate of each transaction status across all transactions?
SELECT Transaction_Status,
	   round(100 * COUNT(*)/(SELECT COUNT(*) FROM fintrust_transaction_clean),2) AS Status_Rate
FROM fintrust_transaction_clean
GROUP BY Transaction_Status
ORDER BY Status_Rate DESC;

-- Result: 90.47% of FinTrust's transactions are completed successfully.
-- Business Interpretation: This success rate reflects strong platform reliability.


-- 7. Which customer segment is most affected by dormancy?
SELECT Customer_Segment,
		SUM(CASE WHEN Account_Status = "Dormant" THEN 1 ELSE 0 END) AS dormant_customers,
	   ROUND(100*SUM(CASE WHEN Account_Status = "Dormant" THEN 1 ELSE 0 END)/COUNT(*),2) AS Dormancy_Rate 
FROM fintrust_customer_data
Group by Customer_Segment
ORDER BY Dormancy_Rate DESC;

-- Result: Everyday customer segment shows the highest dormancy rate among all segments.
-- Business Interpretation: This shows a retention risk worth addressing.


-- 8. What percentage of transactions get flagged for risk review, and do those flags cluster around particular channels?
SELECT Channel,
		SUM(CASE WHEN Risk_Review_Flag = "Yes" THEN 1 ELSE 0 END) AS total_risk,
	   ROUND(100*SUM(CASE WHEN Risk_Review_Flag = "Yes" THEN 1 ELSE 0 END)/count(*),2) AS Risk_Rate
FROM fintrust_transaction_clean
GROUP BY Channel
ORDER BY Risk_Rate DESC;

-- Result: The ATM and Web channel has the highest risk flag rates at 20.16% and 20.16%.
-- Business Interpretation: Mobile App has the highest risk flag rate at 5.61%, making it a priority area for stronger fraud monitoring and security controls.


-- 9. How does each customer's transaction count compare to others in their own segment?
SELECT t.Customer_ID,
	   c.Customer_Segment,
       COUNT(t.Customer_ID) AS transaction_count,
       RANK () OVER (PARTITION BY c.Customer_Segment ORDER BY COUNT(t.Customer_ID) DESC) AS rank_in_segment
FROM fintrust_transaction_clean t
JOIN fintrust_customer_data c
ON c.Customer_ID = t.Customer_ID
Group by t.Customer_ID,
		 c.Customer_Segment
order by c.Customer_Segment,
		 rank_in_segment ASC;
         
-- Result: The 'Everyday' customer segment has the customer with the highest transaction count
-- Business Interpretation: This means high engagement isn't limited to high-value customers; the 
-- Everyday segment also produces highly active users worth prioritizing for retention and loyalty efforts.
         
         
-- 10. How has each channel's share of total transaction value changed over the months?
SELECT Channel,
       MONTHNAME(Transaction_DateTime) AS month_name,
       month(Transaction_DateTime) AS month_num,
       round(SUM(Amount_NGN), 2) AS channel_monthly_value,
       ROUND(SUM(Amount_NGN) / SUM(SUM(Amount_NGN)) OVER (PARTITION BY MONTH(Transaction_DateTime))*100,2) AS channel_share_pct
FROM fintrust_transaction_clean
GROUP BY Channel,
		 month_name,
         month_num
ORDER BY Channel, 
		 month_num;
         
-- Result: There is a increase and decrease trend in the channel share over the months
-- Business Interpretation: Channel preferences fluctuate month to month rather than staying constant, so FinTrust should 
-- monitor these shifts closely to catch emerging issues or seasonal patterns early.
         
         
-- 11. Which transaction type has the lowest success rate, and how does it compare to the others?
SELECT Transaction_Type,
	   count(*) AS total_transactions,
       SUM(CASE WHEN Transaction_Status = "Successful" THEN 1 ELSE 0 END) AS successful_transactions,
       ROUND(100 * SUM(CASE WHEN Transaction_Status = "Successful" THEN 1 ELSE 0 END)/COUNT(*),2) AS success_rate
FROM fintrust_transaction_clean
GROUP BY Transaction_Type
ORDER BY success_rate;

-- Result: The 'Airtime/Data' has the lowest success rate at 89.54%, compared to 'Deposit', which has the
-- highest success rate at 91.19%; a gap of 1.65 percentage points.
-- Business Interpretation: A 1.65 percentage-point gap is relatively small, suggesting Airtime/Data transactions aren't 
-- dramatically less reliable than other types — but given how frequent and low-value these transactions typically are, 
-- even a modest failure rate could translate into a high number of frustrated customers.


-- 12. Do customers who spend above the average total transaction value get flagged for risk review more often than those below average?
WITH customer_total_spend AS (
	 SELECT Customer_ID,
			SUM(Amount_NGN) AS total_spend
	FROM fintrust_transaction_clean
    GROUP BY Customer_ID
    ),
    average_total_spend AS (
		SELECT AVG(total_spend) AS avg_spend
        FROM customer_total_spend
	),
        customer_classification AS (
		 SELECT cts.Customer_ID,
				cts.total_spend,
                ats.avg_spend,
				CASE
					WHEN total_spend > avg_spend THEN "Above Average" ELSE "Below Average" END AS spend_group
		  FROM customer_total_spend cts
          CROSS JOIN average_total_spend ats
     )
     SELECT
			cc.spend_group,
            COUNT(t.Transaction_ID) AS total_transactions,
            SUM(CASE WHEN t.Risk_Review_Flag = "Yes" THEN 1 ELSE 0 END) AS flagged_transactions,
            ROUND(100 * SUM(CASE WHEN t.Risk_Review_Flag = "Yes" THEN 1 ELSE 0 END)/COUNT(t.Transaction_ID),2) AS risk_rate_pct
            FROM customer_classification cc
            JOIN fintrust_transaction_clean t
            ON t.Customer_ID = cc.Customer_ID
		    GROUP BY cc.spend_group
            ORDER BY risk_rate_pct DESC;
            
-- Result: Customers who spend above the average total transaction value get flagged the most for risk review.
-- Business Interpretation: High spenders are flagged more often, likely because FinTrust's risk system treats large
-- transactions as a standard monitoring trigger, not evidence of fraud.            
            
            
-- 13. How do international versus domestic transactions differ in average amount, success rate, and risk flag rate, when looked at separately for each customer segment?
SELECT c.Customer_Segment,
		CASE WHEN t.International_Transaction = "Yes" THEN "International" ELSE "Domestic" END AS transaction_activity,
		ROUND(AVG(t.Amount_NGN),2) AS avg_transaction_value,
        ROUND(100 * SUM(CASE WHEN t.Risk_Review_Flag = "Yes" THEN 1 ELSE 0 END)/COUNT(t.Transaction_ID),2) AS risk_rate_pct,
        ROUND(100 * SUM(CASE WHEN t.Transaction_Status = "Successful" THEN 1 ELSE 0 END)/COUNT(t.Transaction_ID),2) AS success_rate
FROM fintrust_transaction_clean t
JOIN fintrust_customer_data c
ON t.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment, transaction_activity
ORDER BY c.Customer_Segment ASC;

-- Result: Across all customer segments, international transactions consistently show lower average value, higher risk rates,and higher success rates compared to domestic transactions.
-- This gap is most pronounced in the 'SME' segment, where the international transactions show a risk rate of 40.63% compared to 18.57% for domestic. 
-- Business Interpretation: Since international transactions are smaller in value but flagged more often, FinTrust's risk model may be over-relying on "international" status alone.


-- 14. Which customers rank in the top 10% by transaction frequency?
WITH
	customer_transaction_count AS(
		SELECT Customer_ID,
			   COUNT(Customer_ID) AS transaction_count
		FROM fintrust_transaction_clean
        GROUP BY Customer_ID
        ),
	customer_ranking AS(
		SELECT Customer_ID,
				transaction_count,
			   NTILE(10) OVER (ORDER BY transaction_count DESC) as decile
	     FROM customer_transaction_count
	    )
        SELECT Customer_ID,
				transaction_count,
                decile
		FROM customer_ranking
        WHERE decile = 1;
        
-- Result: 150 customers fall into the top 10% by transaction frequency, with transaction counts ranging from 12 to 20.
-- Business Interpretation: This top 10% represents FinTrust's most engaged customers, making them strong candidates for loyalty programs and priority support.
        
	
-- 15. Which account type generates the highest total transaction value, and how many customers hold each account type?
select c.Account_Type,
	   COUNT(distinct c.Customer_ID) AS number_of_customer,
       ROUND(SUM(t.Amount_NGN),2) AS total_transaction_value
from fintrust_customer_data c
join fintrust_transaction_clean t
on c.Customer_ID = t.Customer_ID
group by c.Account_Type
order by total_transaction_value desc;

-- Result: The 'Savings' account type generates the highest transaction value and also has the highest number of customers.
-- Business Interpretation: Savings accounts dominating so heavily may signal under-adoption of FinTrust's other account types, worth investigating whether that's 
-- due to product design, awareness, or customer habit.

-- 16. Which months saw the biggest increase or decrease in total transaction value compared to the previous month?
WITH monthly_values AS (
				SELECT 
					monthname(Transaction_DateTime) as month_name,
					month(Transaction_DateTime) as month_num,
					ROUND(SUM(Amount_NGN),2) AS total_transaction_value, 
					LAG(ROUND(SUM(Amount_NGN),2)) over (ORDER BY month(Transaction_DateTime)) as previous_month_value
				from fintrust_transaction_clean
				group by month_name, month_num
                )
	SELECT month_name,
		   month_num,
           total_transaction_value,
           previous_month_value,
           total_transaction_value - previous_month_value AS value_change
	FROM monthly_values
	ORDER BY month_num;
    
-- Result: March recorded the largest month-over-month increase in total transaction value, while February saw a decline compared to the month before it.
-- Business Interpretation: The February dip followed by March's rebound suggests a seasonal pattern worth monitoring year-over-year, which could help FinTrust better time campaigns and resource planning around predictable highs and lows.                
       
       