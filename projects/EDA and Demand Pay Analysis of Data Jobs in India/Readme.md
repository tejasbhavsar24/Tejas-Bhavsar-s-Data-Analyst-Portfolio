# India Data Job Market Analysis: Skill Demand, Compensation & Optimal Career Pathways

## 📌 Table of Contents

- [Project Overview](#1-project-overview)
- [Tools Used and Key Assumptions](#2-tools-used-and-key-assumptions)
- [Data Cleaning and EDA](#3-Data-Cleaning-and-EDA)
- [Key Insights (Market Summary)](#4-key-insightsmarket-summary)
  - [In-Demand Skills Across Data Roles](#41-in-demand-skills-across-data-roles)
  - [Skill Trends in India](#42-skill-trends-in-india)
  - [Role-Wise Salary Distributions](#43-role-wise-salary-distributions)
  - [Skill Pay vs. Demand Trade-offs](#44-skill-pay-vs-demand-trade-offs)
- [Recommendations for Job Seekers & Professionals](#5-recommendations-for-job-seekers--professionals)
- [My Role and Learnings](#6-my-role-and-learnings)

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

## 2. Tools Used and Key Assumptions

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

## 3. Data Cleaning and EDA

The data preparation workflow consists of 3 core modular stages:

```python
# 1. Loading & Parsing String Arrays into Native Python Lists
import ast
import pandas as pd
from datasets import load_dataset

dataset = load_dataset('lukebarousse/data_jobs')
df_raw = dataset['train'].to_pandas()

df_raw['job_posted_date'] = pd.to_datetime(df_raw['job_posted_date'])
df_raw['job_skills'] = df_raw['job_skills'].apply(lambda x: ast.literal_eval(x) if pd.notna(x) else x)

# 2. Market Filtering
df_india_raw = df_raw[df_raw['job_country'] == 'India'].copy()

# 3. Unrolling Skill Arrays for Row-Level Skill Frequency
df_india = df_india_raw.explode('job_skills')
```
# 4. Key Insights(Market Summary)

Each Jupyter notebook in this project addresses a specific strategic question regarding the Indian data job market. Below is the step-by-step breakdown of the data processing pipelines, visualization scripts, and analyst-level market insights.

---
##  4.1. In-Demand Skills Across Data Roles
This section answers the following question:
What are the most demanded skills for the top 3 data roles in India?

### Methodology & Data Pipeline
To determine the most requested technical competencies, raw job postings were filtered for the Indian market and exploded across individual skill elements. The dataset was aggregated by `job_title_short` to identify the three data roles with most job postings in India: **Data Engineer**, **Data Scientist**, and **Data Analyst**.

To eliminate sample-size skew across roles with different total posting volumes, skill counts were normalized into a **Percentage Likelihood Metric** ($\text{Skills \%} = \frac{\text{Skill Count}}{\text{Total Job Postings for Role}} \times 100$). The top 5 skills per target role were then extracted and ordered for horizontal bar rendering.

```python
import pandas as pd
import ast

# 1. Unroll nested skill arrays into individual rows
df_india = df_india_raw.explode('job_skills')

# 2. Compute absolute skill frequency per role
df_india_skill_counts = df_india.groupby(['job_title_short', 'job_skills']).size().reset_index(name='skill_count')

# 3. Compute total unique postings per role
df_job_india_count = df_india_raw.groupby('job_title_short').size().reset_index(name='jobs_total')

# 4. Merge and calculate Percentage Likelihood
df_perc_india = pd.merge(df_india_skill_counts, df_job_india_count, on='job_title_short', how='left')
df_perc_india['skills_perc'] = (df_perc_india['skill_count'] / df_perc_india['jobs_total']) * 100

# 5. Extract top 3 market roles by volume
target_jobs = df_perc_india.groupby('job_title_short')['jobs_total'].max().sort_values(ascending=False).head(3).index.tolist()
# Output: ['Data Engineer', 'Data Scientist', 'Data Analyst']
# 4. Computing Percentage Likelihood per Role
df_skill_counts = df_india.groupby(['job_title_short', 'job_skills']).size().reset_index(name='skill_count')
df_job_counts = df_india_raw.groupby('job_title_short').size().reset_index(name='jobs_total')

df_perc_india = pd.merge(df_skill_counts, df_job_counts, on='job_title_short', how='left')
df_perc_india['skills_perc'] = (df_perc_india['skill_count'] / df_perc_india['jobs_total']) * 100

```
For visualization:
``` python
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

fig, ax = plt.subplots(3,1, figsize = (12,15))
for i , job in enumerate(target_jobs):
    df_perc_india_targets = df_perc_india[df_perc_india['job_title_short']== job]
    df_top5skills_india_target = df_perc_india_targets.sort_values(by='skills_perc',ascending = False).head(5)
    df_plot_5skills_india_target = df_top5skills_india_target.sort_values(by='skills_perc',ascending = True)
    df_plot_5skills_india_target.plot(
        kind = 'barh',
        color = 'teal',
        y ='skills_perc',
        x = 'job_skills',
        ax = ax[i],
        legend = False,
        title = f'Likelihood of Skills Requested: {job} Jobs in India'
    )
    for index, row in df_plot_5skills_india_target.reset_index().iterrows():
        val = row['skills_perc']
        ax[i].text(x=val + 0.05, y=index, s=f"{val:.2f}%", va='center', fontsize=10)
        
    # Clean up axis metrics once per chart loop spin
    ax[i].set_ylabel("")
    ax[i].xaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
```
<img width="738" height="863" alt="download" src="https://github.com/user-attachments/assets/cfebf858-4ddc-4fc1-b75b-eeed850b639e" />

Market Insights:
- **Programming Language Essential**: SQL and Python form the non-negotiable technical floor across the Indian market. SQL appears in 72.32% of Data Engineering roles, while Python leads Data Science requirements at an overwhelming 80.39% market penetration.
  
- **Python's Dominance**: Python is the most versatile language across all three roles, holding top-tier positioning in Data Science (80.39%), Data Engineering (64.39%), and Data Analytics (~45%), making it the single highest-ROI programming language to learn as data job aspirant for higher chance of landing such a role.

- **Role-specific Focus**: Data Engineering roles in India demand heavy distributed systems and cloud orchestration expertise—specifically Spark (39.84%) and AWS (38.92%). In contrast, Data Analytics roles emphasize downstream consumption, EDL and Data Visualization tools like Power BI, Tableau, and Excel. Data Scientist appears to blend requirements from both fields. This indicates an analyst or data engineer aspirant should avoid trying to enter inot both streams, rather Data Scientist would be a better fit - as a substitute or secondary role for Data Engineers and future position to strive for in case of Data Analysts. Cloud and Orchestation tools have different learning needs than visualization tools, so its difficult for data Engineer or Data Analyst to focus on skill learning for both paths simulatenously, and shoudl aim at data scientist roles as secondary/backup career roles. 

---
## 4.2 Skill Trends in India
This section answers the following question:
How are In-Demand Skills Trending for Data Analysts in India?

To understand how technical requirements evolved throughout 2023 for Indian Data Analysts, I analyzed the month-over-month trajectory of the most requested skills. This time-series analysis reveals whether a tool's popularity is seasonal, surging, or structurally consistent.

### Methodology & Data Pipeline

To accurately track monthly skill demand, the raw dataset underwent a structured transformation pipeline. Here is the technical reasoning behind the data processing steps:

1. **Imputation of Missing Values:** Missing numerical values for annual and hourly salaries were filled using overall dataset medians (`fillna()`). This preserves the maximum number of job posting records for skill analysis without introducing bias due to dropping out null values.
2. **List Unpacking & Exploding:** Skills stored as text strings were safely evaluated into Python lists using `ast.literal_eval`. Using `.explode('job_skills')` transformed the data from "per-job" to "per-skill" level, enabling accurate frequency counting of job postings.
3. **Target Filtering & Temporal Extraction:** The dataset was strictly filtered for `job_country == 'India'` and `job_title_short == 'Data Analyst'`. The `job_posted_date` was parsed to extract the month name (e.g., 'Jan', 'Feb') for a month-wise analysis.
4. **Aggregation & Normalization:** To prevent months with higher overall hiring volumes from  skewing the trends, skill demand was normalized as a percentage of total data analyst jobs postings for that month. 
5. **Pivoting & Chronological Reindexing:** Finally, the aggregated data was pivoted into a wide-format matrix for visualization.The final step was reindexing the rows chronologically (`Jan` to `Dec`), as standard Pandas defaults to alphabetical sorting for categorical strings like months.

```python
# Aggregate monthly skill counts and calculate percentage of total jobs
df_da_india_merge = pd.merge(df_da_india_month, df_total_da_jobs_india, on='month', how='left')
df_da_india_merge['perc_skills'] = (df_da_india_merge['skill_count'] / df_da_india_merge['count']) * 100

# Pivot into wide-format for plotting and sorting in a chronological order
df_da_pivot = df_da_india_merge.pivot_table(
    index='month', columns='job_skills', values='perc_skills', aggfunc='mean'
).fillna(0)

month_order = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
df_da_pivot = df_da_pivot.reindex(month_order)
```

**For visualization**:

To cleanly visualize these movements without charting clutter, I extracted the Top 5 overall skills for the year and plotted their monthly likelihood on a line chart.
```python

import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import seaborn as sns

# Plotting the time-series trends
fig, ax = plt.subplots(1, 1, figsize=(12, 6))
df_da_line_plot.plot(kind='line', ax=ax, linewidth=3)

# Formatting axes for clean executive presentation
ax.set_xticks(range(len(df_da_line_plot.index)))
ax.set_xticklabels(df_da_line_plot.index)
ax.yaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
ax.set_title("Top 5 Skill Trends for Data Analysts in India (2023)", fontsize=16, pad=15)
ax.set_ylabel("Likelihood in Job Postings")
ax.set_xlabel("Month")
plt.legend().remove()

# Direct line labeling at year-end data points (December)
for skill_name in df_da_line_plot.columns:
    final_val = df_da_line_plot[skill_name].iloc[-1]
    ax.text(x=11.1, y=final_val, s=f" {skill_name}", va='center', ha='left', fontsize=11, fontweight='bold')

sns.despine()
plt.tight_layout()
plt.show()
```
<img width="1189" height="1389" alt="image" src="https://github.com/user-attachments/assets/d91942a6-bfd6-4d27-82f4-523d06373a8b" />



### Market Insights

**SQL - The Must Have Skill**: SQL maintains a lead throughout the entire year, consistently appearing as the dominant requirement in Indian Data Analyst job descriptions. It shows zero signs of obsolescence or replacement by drag-and-drop BI tools and AI. For any job as data analyst having command over SQL is a must for getting "foot-in-the-door" in any analyst job-interview.

**Spreadsheets**: Excel demand experiences steady consistency across all quarters, proving that despite the rise of automated dashboards and programming languages, Indian enterprises still heavily rely on foundational spreadsheet manipulation for ad-hoc operational reporting. The skill has survived technological phases, and is still the most basic skill needed.

**Programming & BI Ecosystem Rising Demand**: Python, alongside visualization tools like Tableau and Power BI, display relatively stable demand trajectories. Power BI demonstrates a slight competitive edge in the Indian market, perhaps due to alignment with domestic corporate preferences for integrating into broader Microsoft enterprise ecosystems (Azure, Office 365) and preference for it, given its close relationship and similarity with Excel in various aspects. Python and BI tools are differentials for data analyst jobs, with many new tasks requiring the analyst to utilize these.
