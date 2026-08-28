# 2025–2026 DEP State of the Community Survey Results
## Python, Excel, HTML, Tableau, SQLite, Machine Learning


End-to-end survey analysis and interactive report for [Data Engineering Pilipinas](https://dataengineering.ph/), covering **1,861 responses** from the Philippine data and tech community, including career shifters, students and current data professionals. Built with Python, Plotly, and GitHub Pages. Covers demographic profiling, compensation benchmarking, tools landscape, and learning behavior across **5 interactive report pages**.  

[Deepdive section in this repo](/deepdive#readme) includes machine learning methods to derive key drivers of job satisfaction.  

[Report section in this repo](/report) includes all the excel tables with crosstabs and round-robin significance testing at 95% c.l.

[Google slides used during the online presentation](https://docs.google.com/presentation/d/1o6-eqyHcwdATKFpuO75ukcj3XtycBx-pqI9RbshBpy4/edit?usp=drive_link) <br><br>
Click on thumbnail below to see the online presentation recording in youtube<br><br>
[![youtube recording of the presentation](https://github.com/SandyGCabanes/2025-2026-DEP-State-of-the-Community-Survey-Results/blob/main/report/youtube_thumb%20(35pct).png)](https://youtu.be/NOr1Nt1daEY)
    

For backend cleaning and data processing after raw data download, check out the separate github repo for [python data pipeline here](https://github.com/SandyGCabanes/DEP-Survey-Data-Pipeline).

For the publicly available Tableau report  [Tableau Public](https://public.tableau.com/views/DEPSurvey2026/OURWORK)

![Report preview](https://github.com/SandyGCabanes/2025-2026-DEP-State-of-the-Community-Survey-Results/blob/main/tableau/tableau2025.gif)

<br><br>

For the advanced analysis using machine learning and SHAP readme, click [here](https://github.com/SandyGCabanes/2025-2026-DEP-State-of-the-Community-Survey-Results/tree/main/deepdive#readme).
<br>

[![SHAP analysis preview](https://github.com/SandyGCabanes/2025-2026-DEP-State-of-the-Community-Survey-Results/blob/main/deepdive/assets/shap_2s.gif)](https://github.com/SandyGCabanes/2025-2026-DEP-State-of-the-Community-Survey-Results/blob/main/deepdive/assets/shap_beeswarm_3s.gif)


**Analyst and report developer:** [Sandy G Cabanes](https://www.linkedin.com/in/sandygcabanes)

---

## Live Report Using HTML  (via Github Pages)

| Page | Description |
|---|---|
| [Home](https://sandygcabanes.github.io/2025-2026-DEP-State-of-the-Community-Survey-Results/index.html) | Landing page and executive navigation |
| [Executive Summary](https://sandygcabanes.github.io/2025-2026-DEP-State-of-the-Community-Survey-Results/web_report_htmls/summary.html) | Key findings at a glance |
| [About Us](https://sandygcabanes.github.io/2025-2026-DEP-State-of-the-Community-Survey-Results/web_report_htmls/about_us.html) | Demographics, roles, career stage, education |
| [Compensation](https://sandygcabanes.github.io/2025-2026-DEP-State-of-the-Community-Survey-Results/web_report_htmls/compensation_combined_smallmultiples.html) | Salary profiles by role, industry, and experience |
| [Tools & Tech](https://sandygcabanes.github.io/2025-2026-DEP-State-of-the-Community-Survey-Results/web_report_htmls/tools_tech.html) | Most-used tools, platforms, and technologies |
| [Learning & Community](https://sandygcabanes.github.io/2025-2026-DEP-State-of-the-Community-Survey-Results/web_report_htmls/learning_community.html) | Learning habits, program attendance, AI adoption |
| [Drivers of Job Satisfaction](https://sandygcabanes.github.io/2025-2026-DEP-State-of-the-Community-Survey-Results/web_report_htmls/satisfaction_drivers.html) | Key drivers using machine learning and Shapley values |

---

## Objectives

- Answer common community questions: salary benchmarks by role, relevant skills, value of advanced degrees
- Guide future DEP programs and initiatives based on data-driven findings
- This year's additions: AI adoption, job satisfaction, shift schedules, and online activity attendance

---

## Tech Stack

| Stage | Tools |
|---|---|
| Data collection | Google Forms, Google Sheets |
| Data processing | Excel (pivot tables)|
| Data cleaning & pipeline | Python (pandas, Gemini API call, DuckDB, SQLite)  - see [dep-survey-data-cleaning-pipeline](https://github.com/SandyGCabanes/DEP-Survey-Data-Pipeline)|
| Privacy protection | R and Python: Bayesian network anonymization prior to public data release |
| Visualization | Python, Plotly (interactive charts), geopy, folium (location map) |
| Report delivery | GitHub Pages (HTML, free and open-source) |
| Dashboard | [Tableau Public Dashboard - Our work tab](https://public.tableau.com/views/DEPSurvey2026/OURWORK)


---

## Privacy & Data

Raw responses are not published. Prior to any public data release, a synthetic dataset matching the community's statistical profile will be generated using **Bayesian network model methods**, preserving analytical accuracy while protecting respondent privacy.

---

## About Data Engineering Pilipinas

Data Engineering Pilipinas (DEP) has grown from 28,000 to **40,000+ members** on Facebook, spearheaded by [Myk Ogbinar](https://github.com/ogbinar).  DEP currently has a joint partnership with Datacamp, providing thousands of scholarships to deserving members.  It is supported by volunteers, who contribute time and effort to sustain the community.  It is one of the most active data communities in the Philippines, running programs for aspiring data engineers and other data-related career seekers. This is the **second annual** State of the Community Survey.

---

## Contact

Interested in survey design, data analysis, or interactive report development for your organization?

**Sandy G Cabanes** · [LinkedIn](https://www.linkedin.com/in/sandygcabanes) · Data Analyst & Report Developer



