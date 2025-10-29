# Global-Layoff-Trends-Analysis-Using-SQL

![](intro_image.png)

---

## 🧠 Project Overview

This project performs **data cleaning and exploratory data analysis (EDA)**  on a worldwide layoffs dataset (from 2020 to 2025) to identify patterns and trends related to layoffs during and after the COVID-19 pandemic.
Using SQL, I explored layoffs by industry, company, country, year, and company stage, uncovering how different sectors were impacted and how global layoff trends evolved over time.

---

## 📂 About the World layoff dataset

The dataset:
  Content: Layoffs from global tech companies during 2020 to date
  Columns include:
  1. company 
  2. location  
  3. total_laid_off 
  4. date
  5. percentage_laid_off 
  6. industry 
  7. source 
  8. stage  
  9. funds_raised
  10. country 
  11. date_added 

Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022 | GitHub (via Alex The Analyst Bootcamp)

---

## 🎯 Objectives

- Data cleaning (handling nulls, trimming spaces, standardizing columns)
- Aggregations (SUM, COUNT, GROUP BY)
- Ranking and window functions (RANK, DENSE_RANK, CTEs)
- Trend analysis (monthly/yearly layoffs)
- Identifying unique and repeated company layoffs

---

## 🛠️ Tools & Techniques

  - SQL (MySQL)
  - Data Cleaning (handling nulls, duplicates, inconsistent categories)
  - Exploratory Data Analysis (aggregations, window functions, ranking)
  - Business Trend Analysis
    
---

## 🚀 Key Insights

1. **Intel** recorded the highest total layoffs (**43,115 employees**), followed by **Microsoft (30,055)** and **Amazon (27,940)**.  
2. **Maximum single-company layoff:** 22,000 employees (100% layoffs — company shutdown).  
3. A total of **331 companies** went completely under (100% layoffs).  
4. Dataset date range: **March 11, 2020 → October 1, 2025**.  
5. **Top 3 industries affected:** Hardware, Other, and Consumer.  
6. **Top 3 countries affected:** United States, India, and Germany.  
7. **Yearly layoffs trend:** 2023 had the highest layoffs, followed by 2022 and 2024.  
8. **Top companies with multiple rounds of layoffs:** Rivian, Blend, Cue Health, F5, Lyft, Outreach, Peloton, Redfin, Salesforce, ShareChat, Swiggy, and Unity.  
9. **Stage most affected:** Post-IPO companies (**451,029 layoffs**).  
10. **Healthcare industry impact:** United States, Netherlands, and India most affected.  
11. **Total layoffs (2020–2025):** **769,596 employees**.  
12. **Top 3 layoffs in Bengaluru:** Ola Electric (1,000), VerSe Innovation (350), and Mobile Premier League (300).  
13. **Consistent trend:** Intel, Microsoft, Amazon, and Meta ranked among top companies with layoffs each year.  
14. **Companies with most frequent layoffs:** Microsoft (30,055), Amazon (27,940), Salesforce (16,525), and Google (13,547).  
15. **Monthly layoff peaks:**  
    - 2020 → April (26.7K) — COVID-19 onset  
    - 2021 → January (6.8K)  
    - 2022 → November (53.6K)  
    - 2023 → January (89.7K) — Global tech layoffs  
    - 2024 → January (34.1K)  
    - 2025 → April (24.5K)

*Final Insight: Global layoffs peaked in 2023, driven largely by large tech companies such as Intel, Microsoft, Amazon, and Meta — reflecting a major industry-wide restructuring following post-pandemic growth.*

---

## 📅 Future Improvements
- Add Power BI dashboard for visual insights  
- Automate query execution and updates with Python

