# Data Source

## DataCo Smart Supply Chain for Big Data Analysis

- **Authors:** Fabian Constante, Fernando Levano, Katerine Ogando
- **Source:** [Kaggle Dataset](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis)
- **Raw rows:** 180,519
- **Raw columns:** 53
- **Cleaned columns:** 46 (after Python cleaning)
- **Date range:** January 2015 — February 2018

## Why the CSV is not included

The raw dataset exceeds GitHub's 100MB file size limit.
Please download it directly from Kaggle using the link above.

## Setup Instructions

1. Download `DataCoSupplyChainDataset.csv` from Kaggle
2. Run `datacocleaning.ipynb` to clean the dataset
3. Import `dataco_cleaned.csv` into SQL Server
4. Name the table `dataco_cleaned`
5. Run `supply_chain_queries_clean.sql`
