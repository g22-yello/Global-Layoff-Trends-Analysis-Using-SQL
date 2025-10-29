-- =========================================
-- Project: Global Layoff Trends Analysis Using SQL
-- Author: Glanet Castelino
-- Date: [2025-10-07]
-- Purpose: EDA of the cleaned data
-- Description: Analyzed patterns across industries, countries, and company stages to uncover the impact of COVID-19 on workforce 
--              reductions and post-pandemic recovery trends.
-- =========================================

USE world_layoffs;
SELECT * FROM layoffs_staging2;


-- Top 5 Companies with the most layoffs overall
SELECT company, SUM(total_laid_off) AS Total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY Total_layoffs DESC
LIMIT 5;


-- Max number of people laid off by a company and Maximum percentage_laid_off
SELECT MAX(total_laid_off), MAX(percentage_laid_off) # 1 means entire company went under
FROM layoffs_staging2;


-- show all companies which went under ( from highest to lowest total_laid_off)
SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC ;


-- show all companies which went under ( from highest to lowest funding raised)
SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_USD DESC ;
-- Note: The 'funds_raised' column contains numeric values but whether in millions or thousands is not specified in the source data.


-- Check the start and end of date of layoffs ( in terms of this dataset) -- date range
SELECT MIN(`date`), MAX(`date`) 
FROM layoffs_staging2;


-- Top 5 industries affected the most globally?
-- Hardware industry were effected the most followed by other and Consumer
SELECT industry, SUM(total_laid_off) AS Total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY Total_layoffs desc
LIMIT 5;


-- Top countries hit with layoffs
-- United States were effected the most followed by India and Germany
SELECT country, SUM(total_laid_off) AS Total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY Total_layoffs desc;


-- How many layoffs occurred over time (year)?
-- 2023 hit with highest layoffs followed by 2022 then 2024
SELECT YEAR(`date`), SUM(total_laid_off) AS Total_layoffs
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY Total_layoffs desc;

-- Find companies that had multiple rounds of layoffs ( not companies with single layoff)
SELECT company, COUNT(percentage_laid_off) as total_layoff_rounds
FROM layoffs_staging2
GROUP BY company
HAVING total_layoff_rounds> 1
ORDER BY total_layoff_rounds DESC;


-- In which stage of the company had the most lay-offs?
-- Post-IPO hit with highest layoffs
SELECT stage, SUM(total_laid_off) AS Total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY Total_layoffs desc
LIMIT 5;


-- Which countries are affected the most in the Healthcare industry?
SELECT country, SUM(total_laid_off) AS Total_layoffs
FROM layoffs_staging2
WHERE industry = 'Healthcare'
GROUP BY country
ORDER BY Total_layoffs DESC;


-- Rolling totals of layoffs -- layoffs are accumulating over time -- each Date to date rolling total layoffs
-- How many layoffs happened each day and what’s the total so far as of that date
SELECT `date`, SUM(total_laid_off) AS daily_layoffs,
    SUM(SUM(total_laid_off)) OVER (ORDER BY date) AS rolling_total_layoffs
FROM layoffs_staging2
GROUP BY `date`
ORDER BY `date` ASC;

-- Shows how many layoffs occurred in each month (month wise)
-- shows each month and not rolling total
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_layoffs 
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- cte cumulative sum over time — i.e., total layoffs up to that month.
-- keeps adding up as month goes on
-- same as above but just rolling total
WITH ROLL_TOTAL AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_layoffs 
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_layoffs,
SUM(total_layoffs) OVER (ORDER BY `MONTH`) AS rolling_total
FROM ROLL_TOTAL;


-- total layoffs in 2025 in bengaluru
SELECT company , location, SUM(total_laid_off) as total_layoffs
FROM layoffs_staging2
WHERE country = 'India'
  AND location LIKE '%Bengaluru%'    
  AND YEAR(date) = 2025            
GROUP BY company, location
ORDER BY total_layoffs DESC;

-- check companies on how much they lay off in a year
SELECT company, YEAR(`DATE`) as year_of_layoff, SUM(total_laid_off) as total_layoffs
FROM layoffs_staging2     
GROUP BY company, YEAR(`DATE`)
ORDER BY company ASC;

-- Rank companies by total layoffs (Window function)
SELECT company, SUM(total_laid_off) AS Total_layoffs,
RANK() OVER (ORDER BY SUM(total_laid_off) DESC) AS rank_by_layoffs
FROM layoffs_staging2
GROUP BY company;


-- Rank companies by total layoffs  top 5 year wise
-- using cte 
WITH Company_year (company, year_of_layoff, total_layoffs)AS
(
SELECT company, YEAR(`DATE`) as year_of_layoff, SUM(total_laid_off) as total_layoffs -- 1)CTE: companies, year and total layoffs
FROM layoffs_staging2     
GROUP BY company, YEAR(`DATE`)
ORDER BY company ASC
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER( PARTITION BY year_of_layoff ORDER BY total_layoffs DESC) AS Ranking -- 2)CTE: rank to each company for each year based on total_layoffs
FROM Company_year
WHERE year_of_layoff IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- Which companies perform layoffs most often
WITH occurances AS 
(
SELECT * , 
ROW_NUMBER() OVER( PARTITION BY company, location ) AS layoff_occurance  -- Number each layoff event per company at each location.
FROM layoffs_staging2
WHERE total_laid_off > 0
)
SELECT company, MAX(layoff_occurance) AS layoff_occurances, SUM(total_laid_off) AS total_layoffs
FROM occurances
GROUP BY company
ORDER BY layoff_occurances DESC ;


-- When do layoffs peak within a year?
SELECT YEAR (`date`) AS `Year`, MONTH(`date`) AS `Month`, SUM(total_laid_off) AS Total_layoffs
FROM layoffs_staging2
WHERE `date` IS NOT NULL 
GROUP BY `Year`, `Month`
ORDER BY `Year`, Total_layoffs DESC;

-- ==============================================================
  --        saving the layoffs_staging2 as layoffs_cleaned dataset
-- ===============================================================

-- Create a new table from your cleaned query
CREATE TABLE layoffs_cleaned AS
SELECT *
FROM layoffs_staging2;


-- Create a new table from your cleaned query
CREATE TABLE layoffs_cleaned AS
SELECT *
FROM layoffs_staging2;

SELECT * FROM layoffs_cleaned;

# ------------------------------------------------------------------------#