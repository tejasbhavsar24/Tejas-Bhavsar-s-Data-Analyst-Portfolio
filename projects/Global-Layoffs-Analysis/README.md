# Global Layoffs Analysis (2020–2025): SQL Data Cleaning & KPI Exploration

## Project Overview

This project analyzes 3,446 major layoffs events covering five years (2020–2025). The goal is to transform raw data into actionable insights using advanced SQL for business, HR, and economic strategic planning.
- **Raw entries:** 4,126
- **Analysis-ready entries:** 3,446
- **Coverage:** Multiple countries and industries

## Folder Structure

| Directory         | Contents                                                  |
|-------------------|----------------------------------------------------------|
| data/raw          | Original layoff data (CSV format)                        |
| data/cleaned      | Cleaned, SQL-processed dataset                           |
| data/outputs      | CSVs for each KPI, used in analysis and visualizations   |
| sql/              | SQL scripts for cleaning and exploration                 |
| documentation/    | PDF report and PPT                                       |

## How To Use

1. **Review the methodology** in `/documentation/Layoff-project.pdf` for context and major steps.
2. **Query the cleaned data** in `/data/cleaned/Layoffs_cleaned.csv` for new insights.
3. **Explore outputs** in `/data/outputs/` to see pre-computed business KPIs.
4. **Run the full analysis** by executing `/sql/Project SQL Layoffs.sql` (works on MySQL or compatible DB).

## SQL Analysis Workflow

- Renamed and standardized raw columns
- Deduplicated records using SQL window functions
- Standardized date formats and converted text fields to proper numbers
- Imputed missing industry values using company-based joins
- Extracted seven core KPIs for business, HR, and strategic analysis

## Key Business Insights

- **Temporal spikes:** January 2023 saw 89,709 layoffs—largest single monthly event, linked to economic corrections.
- **Geography:** US was the epicenter, with 68%+ layoffs.
- **Industry:** Hardware and consumer sectors most vulnerable.
- **Company:** Intel led layoffs over multiple periods—a sign of strategic transition, not mere panic.

## Skills Demonstrated

- Advanced SQL: window functions, CTEs, type conversion, and deduplication
- Data Cleaning: column renaming, missing/null imputation, outlier and error removal
- Business Analytics: KPI design, trend correlation, risk quantification

## Attribution

Project created by **Tejas Bhavsar**
---

*This project is shared for learning, analysis, and community feedback. Please credit with a link to this repository for any derivative work.*
