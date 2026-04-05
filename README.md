# 📉 Tech Layoffs Data Cleaning in SQL

This repository contains my SQL project for cleaning and preparing a tech layoffs dataset for analysis. The work focuses on building a safe staging workflow, removing duplicates, standardizing inconsistent values, handling nulls, and preparing a clean dataset for downstream exploratory analysis.

---

## 📌 Introduction

This project uses SQL to clean a layoffs dataset tracking reported tech layoffs since the COVID-19 period. The goal is to transform raw data into a more reliable and analysis-ready table by applying core data cleaning techniques in SQL.

The project demonstrates practical skills in:

- SQL data cleaning
- staging table design
- duplicate detection and removal
- text standardization
- null handling
- date conversion
- preparing clean data for analysis

---

## 💡 Motivation

Raw datasets often contain duplicate rows, inconsistent text labels, blank fields, and formatting issues that reduce data quality. Before any meaningful analysis can be performed, the dataset must be cleaned and standardized.

This project shows how SQL can be used to solve common real-world data quality problems in a structured way while preserving the original raw data for reference.

---

## 📂 Dataset Description

The dataset tracks tech layoffs reported on multiple platforms, including:

- Bloomberg
- San Francisco Business Times
- TechCrunch
- The New York Times

Based on the dataset information provided, the coverage begins from **11 March 2020** and extends to **21 April 2025**.

The file includes fields such as:

- company
- location
- industry
- total laid off
- percentage laid off
- date
- stage
- country
- funds raised

This makes the dataset useful for later analysis of layoff trends across companies, industries, countries, and time.

---

## 🧹 Data Cleaning Workflow

The SQL cleaning process follows four main stages:

1. Create staging tables  
2. Identify and remove duplicates  
3. Standardize inconsistent values  
4. Handle nulls and remove unusable rows  

---

## 🗂️ 1. Creating Staging Tables

To avoid modifying the raw source table directly, I first created a staging table and copied the original layoffs data into it.

This approach ensures:

- the raw table remains unchanged
- cleaning steps can be tested safely
- the project follows a more reliable data-cleaning workflow

Later, I created a second staging table (`layoffs_staging2`) that includes an additional `row_num` column used for duplicate handling.

---

## 🔁 2. Removing Duplicates

I used `ROW_NUMBER()` with `PARTITION BY` to identify duplicate rows across key columns, including:

- company
- location
- industry
- total_laid_off
- percentage_laid_off
- date
- stage
- country
- funds_raised_millions

After checking the duplicates carefully, I inserted the data into `layoffs_staging2` with a generated row number and removed rows where `row_num >= 2`.

This ensured that only the first valid occurrence of each duplicated record was kept.

---

## 🧼 3. Standardizing Data

I standardized several fields to improve consistency across the dataset.

### Industry cleaning
- Converted blank industry values to `NULL`
- Used self-join logic to fill missing industry values from other rows with the same company
- Standardized inconsistent industry labels:
  - `Crypto Currency` → `Crypto`
  - `CryptoCurrency` → `Crypto`

### Country cleaning
- Standardized country values by trimming trailing punctuation
- Example:
  - `United States.` → `United States`

### Date cleaning
- Converted the `date` column from text into a proper date format using `STR_TO_DATE`
- Changed the column type to `DATE`

These steps improved consistency and made the dataset easier to query and analyze.

---

## ❓ 4. Handling Null Values

I reviewed null values in fields such as:

- `total_laid_off`
- `percentage_laid_off`
- `funds_raised_millions`

I chose to keep meaningful null values where they may still be useful for later analysis.

However, I removed rows where both:

- `total_laid_off` is `NULL`
- `percentage_laid_off` is `NULL`

because these rows do not provide usable layoff information.

Finally, I removed the helper column `row_num` after cleaning was complete.

---

## 🛠️ SQL Techniques Used

This project demonstrates the use of:

- `CREATE TABLE ... LIKE`
- `INSERT INTO ... SELECT`
- `ROW_NUMBER() OVER (PARTITION BY ...)`
- Common Table Expressions (CTEs)
- `UPDATE`
- `DELETE`
- `JOIN`
- `TRIM()`
- `STR_TO_DATE()`
- `ALTER TABLE`
- `MODIFY COLUMN`
- `DROP COLUMN`

---

## 📊 Key Cleaning Outcomes

The final cleaned dataset:

- preserves the raw source data by using staging tables
- removes duplicate records
- standardizes inconsistent industry and country labels
- fills some missing industry values using matching company rows
- converts the date field into a proper SQL date format
- removes rows with no usable layoff information
- prepares the table for future exploratory analysis and reporting

---

## 📁 Files

- `SQL cleaning data.sql` – SQL script containing the full data-cleaning workflow
- `layoffs.csv` – layoffs dataset used in the project (if included in the repository)

---

## ▶️ How to Run the Project

1. Open your SQL environment (e.g. MySQL Workbench)
2. Load the raw layoffs dataset into the `world_layoffs.layoffs` table
3. Run the SQL script step by step or execute the full script
4. Review the cleaned output in:
   - `world_layoffs.layoffs_staging2`

---

## 🎯 Project Goal

The goal of this project is to demonstrate how SQL can be used to clean messy real-world data in a structured and reproducible way.

This project highlights practical skills in:

- SQL data cleaning
- duplicate handling
- standardization
- null analysis
- date conversion
- safe staging workflows
- preparing data for later analytics and reporting
