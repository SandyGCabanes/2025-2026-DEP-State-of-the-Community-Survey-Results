# Satisfaction Drivers Analysis
### DEP Annual Survey 2026 · Philippine Data Community · n = 1,861

---

## Problem: Too Many Significant Findings

Cross-tabulating **job satisfaction** (Low / Mid / High) against every individual survey question produced a flood of statistically significant results. Too many variables showed some difference across satisfaction groups — salary band, work setup, career stage, AI tool usage, team size, and more.

But we need to know *"How much does it actually matter, relative to everything else?"* The crosstab approach only answers *"Is this variable related to satisfaction?"*  Using deep Market Research experience, drivers analysis was the natural next step to answer which variables move the needle, not just the significant variables.

---

## Solution: Multi-Model SHAP Attribution

Five models were trained on the same survey data.  **SHAP (SHapley Additive exPlanations)** was used to extract each model's view of driver importance. Agreement across models signals a genuine driver. Disagreement reveals where the relationship is linear, non-linear, or model-dependent.

LightGBM was run separately as a validation step on the top 20 features already identified by RF, LR, and Lasso — asking whether the driver ranking holds under a gradient boosting method with a completely different training mechanic. It did.

The SHAP comparison table produced a short, defensible list of **2 main drivers and 6 others**. The top 2, i.e., salary and career stage, were consistent across all five models and were the primary findings in the summary report.

---

## Pipeline Architecture

```
df_single_with_grps.csv
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│  PART 0 · DATA PREPARATION                                      │
│                                                                 │
│  · Drop non-predictive columns (age, gender, resp_id, …)        │
│  · Encode ordinal cols  ──►  salary_broader, sizeteam,          │
│                               how_long_in_salary                │
│  · One-hot encode nominal cols  ──►  careerstg, datarole,       │
│                               sitework, ai_work, ai_study, …    │
│  · Drop n < 30 one-hot columns  (avoids overfit on small cells) │
│  · Drop NAs and "None of the above" OHE columns                 │
└───────────────────────┬─────────────────────────────────────────┘
                        │  X  (features)   y  (satisfaction 1–10)
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  PART 1 · FIVE MODELS                                           │
│                                                                 │
│  ┌──────────────────────────┐  ┌──────────────────────────────┐ │
│  │  1. Random Forest (RF)   │  │  2. Ordinal Logistic (OL)    │ │
│  │  · No scaling needed     │  │  · Raw X  →  ol_impact0      │ │
│  │  · Gini impurity splits  │  │  · Filtered X (n≥30)         │ │
│  │  · Captures non-linear   │  │    →  ol_impact1             │ │
│  │    interactions          │  │  · Scaled + Filtered X       │ │
│  │  → rf_impact.csv         │  │    →  ol_impact2             │ │
│  │  → model_rf.pkl          │  │  → model_ol0/1/2.pkl         │ │
│  └──────────────────────────┘  └──────────────────────────────┘ │
│                                                                 │
│  ┌──────────────────────────┐  ┌──────────────────────────────┐ │
│  │  3. Linear Regression    │  │  4. Lasso Regression         │ │
│  │  · StandardScaler        │  │  · StandardScaler            │ │
│  │  · Simple linear signal  │  │  · alpha=0.1 penalty         │ │
│  │  → lr_impact.csv         │  │  · Zeroes out weak drivers   │ │
│  │  → model_lr.pkl          │  │  → lasso_impact.csv          │ │
│  └──────────────────────────┘  │  → model_lasso.pkl           │ │
│                                └──────────────────────────────┘ │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  5. LightGBM (validation — separate notebook)            │   │
│  │  · No scaling needed — tree-based                        │   │
│  │  · Gradient boosting — sequential error correction       │   │
│  │  · Run on top 20 features from RF/LR/Lasso               │   │
│  │  · Confirms driver ranking under boosting mechanic       │   │
│  │  · lgbm first import required (Windows DLL order)        │   │
│  │  → lgbm_impact.csv                                       │   │
│  │  → model_lgbm.pkl                                        │   │
│  └──────────────────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PART 2 · SHAP ATTRIBUTION                                          │
│                                                                     │
│  RF      ──►  TreeExplainer   ──►  shap_rf.npy   + bar / beeswarm   │
│  LR      ──►  LinearExplainer ──►  shap_lr.npy   + bar / beeswarm   │
│  Lasso   ──►  LinearExplainer ──►  shap_lasso.npy + bar / beeswarm  │
│  LightGBM ──► TreeExplainer   ──►  shap_lgbm.npy  + bar / beeswarm  │
│               (top 20 features — separate notebook)                 │
│                                                                     │
│  (Ordinal Logistic skipped — KernelExplainer too slow)              │
│                                                                     │
│  shap_comparison.csv  ◄──  mean |SHAP| per feature × model          │
│                            RF · LightGBM · LR · Lasso               │
│                            sorted by RF importance                  │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  PART 3 · CORRELATION CHECK                                     │
│                                                                 │
│  Full heatmap  ──►  heatmap_full.png  (all features)            │
│  Small heatmap ──►  heatmap_small.png (top 8 drivers only)      │
│                                                                 │
│  Result: within-group OHE correlations expected and present     │
│          no strong off-diagonal correlations between            │
│          driver groups → drivers are independent signals        │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
            ┌───────────────────────┐
            │  8 KEY DRIVERS        │
            │  for summary report   │
            │                       │
            │  · salary_broader     │
            │  · careerstg          │
            │    (Career Shifter)   │
            │  · sizeteam           │
            │  · sitework           │
            │    (WFH / Remote)     │
            │  · ai_work (daily)    │
            │  · ai_study (daily)   │
            │  · datarole           │
            │    (Admin & Support)  │
            │  · how_long_in_salary │
            └───────────────────────┘
```

---

## Key Findings from SHAP Comparison

| Driver | RF | LightGBM | LR | Lasso | Signal Type |
|---|---|---|---|---|---|
| `careerstg_Career shifter` | ● High | ● High | ◐ Mid | ● High | Universal — strong negative signal |
| `salary_broader` | ● High | ● High | ● High | ● High | Universal — shows up everywhere |
| `sizeteam` | ◐ Mid | ● High | ● High | ◐ Mid | Non-linear threshold effect |
| `ai_study_Daily` | ◐ Mid | ◐ Mid | ◯ Low | ◯ Low | Tree-led — boosting detects it |
| `sitework_WFH / Remote` | ◯ Low | ◐ Mid | ● High | ◯ Low | Primarily linear |
| `sitework_Mostly onsite` | ◯ Low | ◯ Low | ● High | ◯ Low | Linear contrast to WFH |
| `how_long_in_salary` | ◯ Low | ◐ Mid | ◐ Mid | ◯ Low | Moderate, non-linear |
| `datarole_Admin & Support` | ◯ Low | ◐ Mid | ◯ Low | ◯ Low | LightGBM and RF detect |
| `ai_work_Daily` | ◯ Low | ◐ Mid | ● High | ◯ Low | Primarily linear |
| `ai_work_Monthly or less` | ◐ Mid | ◐ Mid | ◯ Low | ◐ Mid | Consistent moderate signal |

● High = SHAP ≥ 0.30 · ◐ Mid = 0.08–0.29 · ◯ Low = < 0.08 · — = not in top 20 tested

**Key finding — careerstg and salary are universal:** Both score high across all four SHAP models — two tree-based methods with different mechanics (bagging vs boosting) and two linear methods with different penalties. That level of cross-method agreement is the strongest possible signal in this analysis.

**Key finding — model divergence on sitework_WFH:** Scores 0.62 in LR SHAP but only 0.09 in RF and 0.18 in LightGBM. Remote work has a clear *linear* relationship with satisfaction, consistent across the whole sample. The tree-based models deprioritize remote work because salary and career stage create larger splits first. Running only one model would have either over-emphasized or missed this driver.

**LightGBM run separately:** Windows DLL conflict with Python 3.11 requires LightGBM to be imported before pandas and numpy. LGBM analysis is available in a dedicated notebook (`satisfaction_drivers_lgbm.ipynb`) on the top 20 features from the main pipeline. Results are then loaded from pkl for the comparison table.

**SHAP for OL skipped:** Explainer not yet supported for tree/linear explainers on mord models. [Read about mord models here.](https://pythonhosted.org/mord/) KernelExplainer takes too much time and computing power to run. OL coefficients from `ol_impact2.csv` (scaled + filtered) used directly for ranking.

---

## Output Files

```
project/
├── assets/
│   ├── shap_rf_bar.png           SHAP bar chart — Random Forest
│   ├── shap_rf_beeswarm.png      SHAP beeswarm — Random Forest
│   ├── shap_lr_bar.png           SHAP bar chart — Linear Regression
│   ├── shap_lr_beeswarm.png      SHAP beeswarm — Linear Regression
│   ├── shap_lasso_bar.png        SHAP bar chart — Lasso
│   ├── shap_lasso_beeswarm.png   SHAP beeswarm — Lasso
│   ├── shap_lgbm_bar.png         SHAP bar chart — LightGBM (top 20)
│   ├── shap_lgbm_beeswarm.png    SHAP beeswarm — LightGBM (top 20)
│   ├── heatmap_full.png          Correlation heatmap — all features
│   └── heatmap_small.png         Correlation heatmap — top 8 drivers
│
├── impact/
│   ├── rf_impact.csv             RF feature importances
│   ├── ol_impact0.csv            Ordinal Logit — unfiltered
│   ├── ol_impact1.csv            Ordinal Logit — n≥30 filtered
│   ├── ol_impact2.csv            Ordinal Logit — scaled + filtered (production)
│   ├── lasso_impact.csv          Lasso coefficients
│   └── lgbm_impact.csv           LightGBM split counts (top 20 features)
│
├── models/
│   ├── model_rf.pkl
│   ├── model_ol0.pkl / model_ol1.pkl / model_ol2.pkl
│   ├── model_lr.pkl
│   ├── model_lasso.pkl
│   └── model_lgbm.pkl
│
└── shap_bin/
    ├── shap_rf.npy / shap_lr.npy / shap_lasso.npy / shap_lgbm.npy
    ├── shap_rf_explanation.pkl
    ├── shap_lr_explanation.pkl
    ├── shap_lasso_explanation.pkl
    ├── shap_lgbm_explanation.pkl
    ├── shap_comparison.csv       Cross-model mean |SHAP| — RF · LightGBM · LR · Lasso
    └── feature_correlations.csv  Top-driver correlation matrix
```

---

## Dependencies

```
pandas · numpy · scikit-learn · mord · shap · matplotlib · seaborn · joblib · lightgbm
```

> **Windows / Python 3.11 note:** Import `lightgbm` before `pandas` and `numpy` to avoid a DLL conflict that causes an access violation at `.fit()`. Run LightGBM in a dedicated notebook (`satisfaction_drivers_lgbm.ipynb`) for a clean import order.

---

*Part of the DEP Annual Survey 2026 data pipeline. Survey data and individual-level responses are not included in this repository for privacy reasons.*

The survey cannot capture the full scope of satisfaction drivers, such as autonomy, advancement opportunities, support from management.  For further reading, see:
- [Bain article on strong sense of purpose, ample autonomy, opportunities for growth, and a sense of affiliation](https://www.bain.com/insights/the-chemistry-of-engagement-ceo-forum/) 
- [ McKinsey article on attracting and retaining talent](https://www.mckinsey.com/capabilities/people-and-organizational-performance/our-insights/great-attrition-or-great-attraction-the-choice-is-yours)
- [McKinsey article on workplace relationships](https://www.mckinsey.com/capabilities/people-and-organizational-performance/our-insights/the-boss-factor-making-the-world-a-better-place-through-workplace-relationships)
- [BCG article on psychological safety](https://www.bcg.com/publications/2024/psychological-safety-levels-playing-field-for-employees)
- [BCG article on digital skill-building, work-life balance](https://www.bcg.com/publications/2023/delivering-top-notch-people-performance)



[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](www.linkedin.com/in/sandygcabanes)   