# FinTrust Digital Bank Analysis
Analysis of customer and transaction data from a digital bank to uncover usage trends, churn risks, and revenue opportunities.

## Overview
This project analyzes data from FinTrust Digital Bank to understand customer behavior, transaction patterns, and overall business performance. The goal is to turn raw banking data into actionable insights that support better decisions on customer retention, product usage, and risk.

## Business Questions
- What day of the week sees the highest transaction activity?
- How do transaction volumes and channels change over time?
- Which segments show signs of churn or inactivity?
- Where are the opportunities to grow revenue or reduce risk?
- Who are the bank's most valuable customers?

## Dataset
- **Source:** FinTrust customer and transaction Data.
- **Size:** 1500 Customers and 12000 Transactions.
- **Period:** January, 2026 to March, 2026.
- **Key Fields:** Customer_ID, Transaction_ID.

## Tools Used
- **ExceL:** For cleaning and validation.
- **SQL:** For querying and manipulation.
- **Python:** For performing EDA.
- **Power BI:** For interactive visualizations.

## Methodology
- **Data cleaning:** Handled inconsistent values such as channel and device name mismatch and reported the missing location records.
- **Analysis:** Segmented customers by activity and value, analyzed monthly trends, and compared channel performance.
- **Visualization:** Built a dashboard showing KPIs, trends, segment breakdowns etc.

## Key Findings
- 'Mobile App' generated the highest total transaction value (N143,385,712) among successful transactions and 'Web' has the highest success rate amongst others.
- Transaction activity is evenly distributed across the week (about 1,730 per day), indicating no strong weekday or weekend pattern. Wednesday is the only exception, with 1,602 transactions, about 132 fewer than the other days.
- Deposit transactions are done more on average among the transaction type.
- 90.47% of FinTrust's transactions are completed successfully.
- March recorded the largest month-over-month increase in total transaction value, while February saw a decline compared to the month before it.

## Recommenndations
- FinTrust bank should promote more saving and investment products.
- Wednesday has the lowest volume, so a midweek promotion, like cashback or fee-free transfers, could lift activity and even out the week.
- Invest further in mobile features, since it is the main growth channel.

## Limitations
- Channel and device typr mismatched
- Missing location records
- Dataset is fictional

## Repository Structure
```
FinTrust-Digital-Bank-Analysis/
├── data/    #dataset
├── sql/     #SQL queries used in the analysis
├── notebook/ #Python notebook used for EDA
├── dashboard/ #Power BI dashboard
├── images/ #Dashboard screenshot
└── README.md
```

## About Me
**[Khairat Olawale]**, Data Analyst
[LinkedIn](www.linkedin.com/in/khairatolawale) | [Email](khairatolawale11@gmail.com)

