# India Data Job Market Analysis: Skill Demand, Compensation & Optimal Career Pathways | 2023–2024 Dataset

## 📌 Table of Contents

- [Project Overview](#1-project-overview)
- [Python Libraries and Key Assumptions](#2-python-libraries-and-key-assumptions)
- [Data Pipeline & Processing Workflow](#3-data-pipeline--processing-workflow)
- [How to Run the Code](#4-how-to-run-the-code)
- [Key Insights (Market Summary)](#5-key-insights-market-summary)
  - [In-Demand Skills Across Data Roles](#51-in-demand-skills-across-data-roles)
  - [Likelihood of Skills Requested in India](#52-likelihood-of-skills-requested-in-india)
  - [Role-Wise Salary Distributions](#53-role-wise-salary-distributions)
  - [Skill Pay vs. Demand Trade-offs](#54-skill-pay-vs-demand-trade-offs)
- [Recommendations for Job Seekers & Professionals](#6-recommendations-for-job-seekers--professionals)
- [My Role and Learnings](#7-my-role-and-learnings)

---

## 1. Project Overview

This is my analysis of the data job market, focusing on data analyst and data scientist roles. The project is about navigating and analysing the job market of data roles. It involves looking at top-paying and most-in demand skills, and finding optimal skillset aspiring analyst and data scientists should focus on.

The data sourced is from Luke Barousse's Python Course. It contains information on job titles, salaries, locations, and essential skills. Through a series of Python scripts, I conducted an analysis aimed at answering questions such as the most demanded job skills, salary trends for data roles, and the skill-demand and pay analysis with a specific focus on the Indian data jobs market.
The focus of the project is understand: 

- Which are the most in demand skills for the top, in demand data roles. 
- Which are the most trending skills and industry-demanded skills for Data Analysts and Data Scientists in India.
- What pay can data role aspirants expect and how much they can demand for knowing specific skill, in an Indian context?
- What are the most optimal high-demand and high-paying  skillset that aspiring analyst and data scientists should learn.

The work is structured as a production‑style analytics project: Python based data cleaning, data transformations, domain-knowledge based statistical and economic model for normalization and calibrations, visualizations and interpretation.

---

## 3. Python Libraries and Key Assumptions

In this project, various Python libraries and custom transformations are utilized for extracting answers from raw job postings data.

### **Python Stack & Libraries Used**

- **Data Manipulation & Processing**
  - `pandas`: Data cleaning, `.explode()` list-unrolling, grouping, multi-level aggregations, and merging.
  - `ast` (`literal_eval`): Safe parsing of stringified array structures into native Python lists.

- **Data Visualization & Formatting**
  - `matplotlib.pyplot` & `matplotlib.ticker`: Custom canvas layouts, percentage formatters, and dynamic X-axis scaling.
  - `seaborn`: Advanced statistical visuals including violin distribution plots and color-palette bar charts.

- **Generative AI**
  - `Gemini`: Utilized for Chain-of-Thought (CoT) prompting to model and normalize US Salary bands not accounting for India Purchasing Power Parity with a multi-stage econometric salary calibrations.
    
### **Key Assumptions:**

- **Salary Disclosure Bias (MNAR):** Job postings with explicit salaries on global job boards skew heavily toward MNCs, GCCs, and US-remote roles, while local domestic firms frequently omit explicit figures. Unadjusted values reflect global rather than domestic baselines.
- **Skill Co-Occurrence:** In multi-skill postings, listed skills inherit the baseline median salary recorded for that overall posting.
- **Two-Stage Econometric Calibration:** Raw USD median values are converted into realistic domestic Indian market bands (₹5L–₹18L LPA) using a two-stage factor:
  $$\text{Effective Domestic Factor} = \text{PPP Factor} \times \text{Domestic Ratio} = \left(\frac{23.5}{100{,}000}\right) \times 0.447 \approx \frac{10.5}{100{,}000}$$
- **Sample Integrity Thresholds:** High-paying skill charts are filtered by minimum posting thresholds ($N \ge 4$ or $N \ge 8$) to eliminate single-posting anomalies (e.g., $N=1$ global remote edge cases).

---

## 4. Data Pipeline & Processing Workflow

The data preparation workflow consists of four core modular stages:

```python
# 1. Loading & Parsing String Arrays into Native Python Lists
import ast
import pandas as pd
from datasets import load_dataset

dataset = load_dataset('lukebarousse/data_jobs')
df_raw = dataset['train'].to_pandas()

df_raw['job_posted_date'] = pd.to_datetime(df_raw['job_posted_date'])
df_raw['job_skills'] = df_raw['job_skills'].apply
