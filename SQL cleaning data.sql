-- SQL Project - Data Cleaning

SELECT * 
FROM world_layoffs.layoffs;



-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging 
SELECT * FROM world_layoffs.layoffs;


-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways



-- 1. Remove Duplicates

# First let's check for duplicates



SELECT *
FROM world_layoffs.layoffs_staging
;

SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
	FROM 
		world_layoffs.layoffs_staging;

With duplicate_cte AS
(
SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num
	FROM 
		world_layoffs.layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;
    
-- let's just look at oda to confirm
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Cars24'
;
-- it looks like these are all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate

-- these are our real duplicates 


-- these are the ones we want to delete where the row number is > 1 or 2or greater essentially

-- one solution, which I think is a good one. Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column

CREATE TABLE `world_layoffs`.`layoffs_staging2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `stage` text,
  `funds_raised` text,
  `country` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO world_layoffs.layoffs_staging2
SELECT company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country, 
ROW_NUMBER() OVER (PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num
FROM 
	world_layoffs.layoffs_staging;

SELECT *
FROM world_layoffs.layoffs_staging2;

-- now that we have this we can delete rows were row_num is greater than 1

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;


SET SQL_SAFE_UPDATES = 0;

DELETE
FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;

-- 2. Standardize Data

SELECT DISTINCT company 
FROM world_layoffs.layoffs_staging2;

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these
SELECT company, TRIM(company) 
FROM world_layoffs.layoffs_staging2;

UPDATE world_layoffs.layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY 1;


SELECT DISTINCT location
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

-- Convert date format from string to date

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_layoffs.layoffs_staging2;

UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change data type of date to DATE from the table

ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values


-- now if we check those are all null

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL 
OR total_laid_off = '';

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company = 'Eyeo';

SELECT t1.industry, t2.industry
FROM world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- now we need to populate those nulls if possible

UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- we also need to look at 

SELECT *
FROM world_layoffs.layoffs_staging2;

-- 4. remove any columns and rows we need to

UPDATE world_layoffs.layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = '';

UPDATE world_layoffs.layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoffs.layoffs_staging2;

ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;


SELECT * 
FROM world_layoffs.layoffs_staging2;