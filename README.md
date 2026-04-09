# Supply Chain Performance Analysis
### End-to-end analytics project using SQL Server, Python, and Tableau

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=flat&logo=microsoft-sql-server&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-E97627?style=flat&logo=tableau&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-150458?style=flat&logo=pandas&logoColor=white)

---

## Project Overview

A comprehensive supply chain performance analysis conducted on the **DataCo Smart Supply Chain dataset** (Kaggle) — 180,519 transactional order records spanning January 2015 to February 2018.

The project follows a full end-to-end analytics workflow:
- **Python** — data cleaning and preparation using pandas
- **SQL Server** — 11 analytical queries covering profitability, delivery performance, demand trends, and customer behaviour
- **Tableau** — two interactive dashboards published on Tableau Public

---

## Business Questions Answered

| # | Question | Technique |
|---|---|---|
| 1 | Which product categories drive the most revenue and profit? | GROUP BY, aggregates |
| 2 | Which shipping mode has the best on-time delivery rate? | CTE, CASE statement |
| 3 | Which regions have the highest late delivery risk? | GROUP BY, SUM |
| 4 | Who are the top 10 customers by total sales? | TOP N, COUNT DISTINCT |
| 5 | How have sales grown month over month? | CTE, LAG window function |
| 6 | Which departments are most and least profitable? | RANK window function |
| 7 | What percentage of orders are in each status? | SUM OVER window function |
| 8 | How many days late are orders by delivery status? | CTE, AVG/MAX/MIN |
| 9 | Which categories are A, B, or C class by revenue? | ABC analysis, running total CTE |
| 10 | How do customer segments compare across key metrics? | COUNT DISTINCT, profit margin |
| 11 | How can customers be segmented by behaviour? | RFM analysis, NTILE window function |

---

## Key Findings

- **Revenue concentration** — 7 categories drive 77% of total revenue. Fishing alone = 18.8% of all sales
- **Late delivery crisis** — 54.8% of all orders arrive late, consistent across all regions and shipping modes
- **Shipping mode paradox** — First Class has a 95.32% late delivery rate vs Standard Class at 38.07% — a scheduling calibration issue not an operational failure
- **Order completion gap** — Only 32.96% of orders reach COMPLETE status. 22.07% stuck in PENDING_PAYMENT
- **Revenue vs profit mismatch** — Top revenue customer generates a net loss of $866 despite $10,524 in sales
- **Long tail inefficiency** — 33 of 50 categories generate only 5% of total revenue

---

## Repository Structure
supply-chain-analysis-DATACO/
│
├── README.md
│
├── sql/
│   ├── supply_chain_queries.sql      # 11 analytical queries
│   └── supply_chain_views.sql        # vw_rfm, vw_abc, vw_supply_chain_master
│
├── python/
│   └── datacocleaning.ipynb          # Full cleaning pipeline
│
└── data/
└── data_source.md                # Dataset information and download link

---

## Dataset

**DataCo Smart Supply Chain for Big Data Analysis**  
Authors: Fabian Constante, Fernando Levano, Katerine Ogando  
Source: [Kaggle](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis)

| Attribute | Detail |
|---|---|
| Raw rows | 180,519 |
| Columns after cleaning | 46 |
| Date range | January 2015 — February 2018 |
| Markets | Europe, LATAM, Pacific Asia, USCA, Africa |
| Customer segments | Consumer, Corporate, Home Office |

---

## Python Cleaning Steps

1. Loaded CSV with `encoding='latin-1'` to handle special characters
2. Verified shape — 180,519 rows, 53 columns
3. Converted column names to lowercase snake_case
4. Dropped 7 columns — product_description (100% null), product_image, customer_password, customer_email, customer_street, customer_zipcode, order_zipcode
5. Renamed date columns to `order_date` and `shipping_date`
6. Filled 8 null values in `customer_lname` with 'Unknown'
7. Exported clean dataset — 180,519 rows, 46 columns, zero nulls

---

## SQL Techniques Used

- CTEs (Common Table Expressions)
- Window Functions — `LAG`, `RANK`, `NTILE`, `SUM OVER`
- `CASE` statements for classification logic
- `COUNT DISTINCT` for accurate order counting
- `DATEDIFF` for recency calculations
- `CREATE VIEW` for reusable Tableau data sources
- ABC inventory analysis using running totals
- RFM customer segmentation using NTILE scoring

---

## Dashboards

Built in Tableau Public — two interactive dashboards:

**Dashboard 1 — Sales Overview**
KPI cards, monthly trends, geographic map, annual sales comparison

**Dashboard 2 — Product Overview**
Top 10 categories, top 10 products, ABC class and revenue per product search

🔗 [View on Tableau Public](#) ← *replace with your actual link*

---

## About

**Madhavan Padmanaban**  
MSc Operations and Supply Chain Management — University of Liverpool  
📧 madhavanmdv@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/maddy2801pad)
