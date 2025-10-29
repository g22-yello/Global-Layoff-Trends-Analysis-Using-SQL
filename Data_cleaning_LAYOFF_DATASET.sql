-- =========================================
-- Project: Global Layoff Trends Analysis Using SQL
-- Author: Glanet Castelino
-- Date: [2025-10-07]
-- Purpose: Clean and preprocess raw data for analysis
-- Description: This  world Layoff dataset contains information on company, location, total_laid_off, date, percentage_laid_off, industry, source, stage, funds_raised, country, date_added
-- The cleaning objectives include Removing duplicates, standardizing formats , handling missing values (null or blank), handling data inconsistencies, Drop Unnecessary Columns, correcting datatypes and preparing the data for analysis.
-- =========================================


-- =========================================
-- 1. Create Load Raw Data
-- =========================================

# create new schema - world_layoffs -- schema > world_layoffs > table > table data import wizard to import data
# MySQL’s “local file loading” feature is turned off by default — both on server and Workbench client so running this
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile'; -- ON

SELECT DATABASE();  # to check the data base you are on
USE world_layoffs;
DROP TABLE IF EXISTS layoffs_raw;


# Issues while importing , creating temp table with appropriate column names and importing values into it
# Datatypes as is of the raw data -- to be updated later onto staging table
CREATE TABLE layoffs_raw (
    company TEXT,
    location TEXT,
    total_laid_off DOUBLE,
    date TEXT,
    percentage_laid_off TEXT,
    industry TEXT,
    source TEXT,
    stage TEXT,
    funds_raised TEXT,
    country	TEXT,
    date_added TEXT
);
		  
# importing data
LOAD DATA LOCAL INFILE 'C:/Users/GLANET/Desktop/OdinSchool/2. Power BI with SQL 2-17 Aug/week 4 - SQL/projects/Layoffs_dataset/layoffs.csv'
INTO TABLE layoffs_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;  # headers excluded


# View the first 5 data and count of total raw data rows
SELECT * FROM layoffs_raw LIMIT 5;
SELECT count(*) FROM layoffs_raw;    # excl header, its 4174

-- =========================================
--  AGENDA --
# Step 1) Remove duplicates
# Step 2) Standardize the data
# Step 3) Null values or blank values
# Step 4) Remove any Columns that are unnecessary
-- =========================================

-- =========================================
-- 2. Create Staging Table
-- =========================================

# Cannot use raw data(as will be making multiple changes so we need the raw data to cross check)  
# so creating staging (another table) and copying layoffs raw data into it
CREATE TABLE layoffs_staging
LIKE layoffs_raw;

INSERT layoffs_staging
SELECT *
FROM layoffs_raw;

# Check the newly created layoffs_staging TABLE
SELECT * FROM layoffs_staging;
SELECT COUNT(*) FROM layoffs_staging;       # COUNT - 4174


-- ===============================================
-- 3. Removing Duplicate rows with help of row_num
-- ===============================================

# first make row numbers for identifiers then Check duplicates and remove them
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num # DATE IS KEYWORD SO USING BACK TICKS
FROM layoffs_staging;

# so here it groups common elements so row nos > 1 are duplicates (all uniques are 1, more are duplicates)
# ROW_NUMBER() gives row_num = 2 (or higher) only if all the columns listed in the PARTITION BY part have the same values.
WITH duplicate_cte AS           # To view all with row_num>2
(
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num    # DATE and SOURCE ARE KEYWORDs SO USING BACK TICKS
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1; #  count(*) 2 count -- just `Beyond Meat` and `Cazoo`


# Deleting row_num > 1 but Error Code: 1288 The target table duplicate_cte of the DELETE is not updatable
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num   
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num >1; 

# so to delete goal is to create another table and delete elements in that table
# right click layoffs_staging> copy to clipboard, create statement
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `total_laid_off` double DEFAULT NULL,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` text,
  `country` text,
  `date_added` text,
  `row_num` int                       # added this line
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num   
FROM layoffs_staging;   # the table with row_num


SELECT * FROM layoffs_staging2
WHERE row_num >1;

DELETE                      # removing duplicates - row_nums >1
FROM layoffs_staging2
WHERE row_num >1;

SELECT count(*) FROM layoffs_staging2; # 2 got deleted = 4172
SELECT * FROM layoffs_staging2;

-- =========================================
-- 4. Standardizing data format
-- =========================================
-- finding issues in data and fixing it

SELECT company, TRIM(company)   # for comparison
FROM layoffs_staging2;

SELECT company, TRIM(company) AS trimmed_company # just to check which all actually should get trimmed
FROM layoffs_staging2
WHERE company <> TRIM(company);

UPDATE layoffs_staging2  
SET company = TRIM(company)
WHERE company <> TRIM(company);   # imp so doesnt run on rows where it doesnt require trim for efficiency

SELECT DISTINCT(industry)  # to check issues with naming, blank cells
FROM layoffs_staging2
ORDER BY industry asc;  # Blank cells - to be handled later


# standardising column wise
SELECT location, country
FROM layoffs_staging2
where country <>'United States'
ORDER BY location asc;
-- auckland , bengaluru, brisbane, caymane islands, Charlotte, Charlottesville?, gurugram,Kuala Lumpur, London.. 
-- Luxembourg,Raleigh...Melbourne,Victoria..New Delhi,New York City..Singapore,Non-U.S...Vancouver,Non-U.S.

UPDATE layoffs_staging2          # first trim
SET location = TRIM(location)
WHERE location <> TRIM(location);

UPDATE layoffs_staging2       # Remove spaces after commas so all "City, Country" → "City,Country" : Standardize comma spacing
SET location = REPLACE(location, ', ', ',');

SELECT * FROM layoffs_staging2 WHERE location LIKE '%Non%';
UPDATE layoffs_staging2                         # incase Non-U.S. pattern isnt followed
SET location = REPLACE(location, 'Non-US', 'Non-U.S.');

# UNIFYING NAMES OF LOCATION - also check location with country as some countries have multiple locations but country specifies the correct one
# jellysmack company main location is NY, USA but also in paris, France
select company, location, country, total_laid_off
from layoffs_staging2 where company= 'Jellysmack';
UPDATE layoffs_staging2
SET location = 'Paris,Non-U.S.'
WHERE total_laid_off = 22;  -- as no row id using total_laid_off

# Vancouver is both in US and canada
select company, location, country, total_laid_off
from layoffs_staging2 where location LIKE 'Vancouver%' ORDER BY location;
UPDATE layoffs_staging2
SET location = 'Vancouver,Non-U.S.'
WHERE company = 'Dapper Labs';  


# using case for remaining for efficiency
-- select company,location, country from layoffs_staging2 where location LIKE 'Vancouver%' order by location; -- for rechecking location names
UPDATE layoffs_staging2
SET location = CASE
    WHEN location LIKE 'auckland%' THEN 'Auckland,Non-U.S.'
    WHEN location LIKE 'Bengaluru%' THEN 'Bengaluru,Non-U.S.'
    WHEN location LIKE 'Gurugram%' THEN 'Gurugram,Non-U.S.'
    WHEN location LIKE 'Brisbane%' THEN 'Brisbane,Non-U.S.'
    WHEN location LIKE 'Cayman%' THEN 'Cayman Islands,Non-U.S.'
    WHEN location LIKE 'Gurugram%' THEN 'Gurugram,Non-U.S.'
    WHEN location LIKE 'Kuala%' THEN 'Kuala Lumpur,Non-U.S.'
    WHEN location LIKE 'London%' THEN 'London,Non-U.S.'
    WHEN location LIKE 'Luxembourg%' THEN 'Luxembourg,Non-U.S.'  #Luxembourg,Raleigh rechecked the company on google
    WHEN location LIKE 'Melbourne%' THEN 'Melbourne,Non-U.S.' # Melbourne,Victoria rechecked on google
    WHEN location LIKE 'New Delhi,New York City' THEN 'New York City'
    WHEN location LIKE 'New D%' THEN 'New Delhi,Non-U.S.'   # New Delhi,New York City rechecked the company on google as new york
    WHEN location LIKE 'Singap%' THEN 'Singapore,Non-U.S.'  
    WHEN location LIKE 'New D%' THEN 'New Delhi,Non-U.S.'   # New Delhi,New York City rechecked the company on google as new york
    WHEN location LIKE 'Vancouver%' THEN 'Vancouver,Non-U.S.' 
    ELSE location
END;

# standardizing country -- All seem to be fine
SELECT DISTINCT country FROM layoffs_staging2 ORDER BY country asc;

-- =========================================
-- 5. Correcting data types
-- =========================================
# changing date and date_added datatype from text to datetime datatype
SELECT `date`,                                 # change all to `date_added` for date_added
       STR_TO_DATE(TRIM(`date`), '%c/%e/%Y')   # M/D/Y  or %d/%m/%Y check which works
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(TRIM(`date`), '%c/%e/%Y');

-- date column is still of data type - date time , also date_added
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

DESCRIBE layoffs_staging2;

-- Ensure total_laid_off is stored as integer as no. of people
ALTER TABLE layoffs_staging2
MODIFY total_laid_off INT;

-- remove % symbol in percentage_laid_off And then alter table to make it float data type
UPDATE layoffs_staging2
SET percentage_laid_off = REPLACE(percentage_laid_off, '%', '');

ALTER TABLE layoffs_staging2
MODIFY percentage_laid_off DOUBLE;

UPDATE layoffs_staging2   # in terms of percent
SET percentage_laid_off = percentage_laid_off / 100;

-- also remove $ sign in funds raised
UPDATE layoffs_staging2
SET funds_raised = REPLACE(funds_raised, '$', '');

UPDATE layoffs_staging2
SET funds_raised = TRIM(funds_raised);

-- changing data type
ALTER TABLE layoffs_staging2
MODIFY funds_raised DOUBLE;
select * from layoffs_staging2;

-- renaming the column to  funds_raise_USD
ALTER TABLE layoffs_staging2
RENAME COLUMN funds_raised_usd TO funds_raised_USD;

-- =========================================
-- 6. Handling missing values (NULL/BLANKS)
-- =========================================
SELECT *
FROM layoffs_staging2                        # No NULL here, just blank values
WHERE TRIM(percentage_laid_off) ='';        # catches empty strings and spaces  -TRIM() removes all leading and trailing spaces.


SELECT *
FROM layoffs_staging2                        # 2 blanks
WHERE TRIM(industry) ='' OR industry IS NULL; 

-- TIP: in case 2  rows have common companies and industry is missing in one
-- can use self join to update the values
-- companies like Appsmith and Eyeo dont have an populated row so cannot fill


-- Making funds raised which are blank as null
SELECT COUNT(*) FROM layoffs_staging2
WHERE TRIM(funds_raised)= '';

UPDATE layoffs_staging2
SET funds_raised = NULL
WHERE TRIM(funds_raised)= '';

-- making blanks and unknown cell values as null of stage
SELECT distinct stage FROM layoffs_staging2;
UPDATE layoffs_staging2
SET stage = NULL
WHERE TRIM(stage) = ''
   OR LOWER(TRIM(stage)) = 'unknown';

-- =========================================
-- 7. Handling Data inconsistencies
-- =========================================

SELECT * FROM layoffs_staging2 
WHERE total_laid_off = 0;

-- data inconsistencies noticed where  multiple total_laid_off column is 0 and percentage_laid_off is a value(0.1,0.15,0.20)
-- to correct it , making all 0 values of TLO col as null where PLO column has values--TLO= 0: PLO 15% 
SELECT *
FROM layoffs_staging2
WHERE (total_laid_off = 0 AND TRIM(percentage_laid_off) NOT IN ('', '0%'))
   OR (total_laid_off > 0 AND TRIM(percentage_laid_off) = '');
   
UPDATE layoffs_staging2    
SET total_laid_off = NULL
WHERE total_laid_off = 0 AND TRIM(percentage_laid_off) NOT IN ('', '0%');

# checking total of percentage_laid_off ( 1534/4172 which is a lot)
# so setting them as NULL
select COUNT(percentage_laid_off)
from layoffs_staging2
where TRIM(percentage_laid_off) ='' ;

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE TRIM(percentage_laid_off) = '';

-- setting those 0 total_laid_off as null whose percentage_laid_off is null
SELECT company, total_laid_off, percentage_laid_off
from layoffs_staging2
WHERE total_laid_off = 0 AND percentage_laid_off is null;

UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = 0 
  AND percentage_laid_off IS NULL;

-- =========================================
-- 8. Drop Unnecessary Columns
-- =========================================
-- As this is a world layoffs dataset, rows where data on layoffs are null -- we can delete those
SELECT COUNT(*) FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL; # COUNT -684

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- We dont need row_num column anymore - ALTER to drop the column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- dropping columns irrelevent to our analysis - SOURCE AND DATE_ADDED
ALTER TABLE layoffs_staging2
DROP COLUMN `source`,
DROP COLUMN date_added;

-- =========================================
--    Saving the cleaned dataset for EDA      --
-- =========================================
# final cleaned data :
SELECT * FROM layoffs_staging2;