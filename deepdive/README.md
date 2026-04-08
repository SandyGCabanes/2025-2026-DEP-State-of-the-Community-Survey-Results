# Satisfaction Drivers Analysis
### DEP Annual Survey 2026 · Philippine Data Community · n = 1,861

---

## Problem: Too Many Significant Findings

Cross-tabulating **job satisfaction** (Low / Mid / High) against every individual survey question produced a flood of statistically significant results. Too many variables showed some difference across satisfaction groups — salary band, work setup, career stage, AI tool usage, team size, and more.

The crosstab approach answers *"Is this variable related to satisfaction?"* but not *"How much does it actually matter, relative to everything else?"* With dozens of candidates all flagging as significant, there was no principled way to decide what to write about.

---

## Solution: Multi-Model SHAP Attribution

Rather than picking winners by gut feel, four different models were trained on the same survey data and **SHAP (SHapley Additive exPlanations)** was used to extract each model's view of driver importance. Agreement across models signals a genuine driver. Disagreement reveals where the relationship is linear, non-linear, or model-dependent.

The SHAP comparison table produced a short, defensible list of **2 main drivers and 6 others**. The top 2, salary and career stage, were mentioned in the summary report, the rest are shown here.

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
│  PART 1 · FOUR MODELS                                           │
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
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  PART 2 · SHAP ATTRIBUTION                                      │
│                                                                 │
│  RF  ──►  TreeExplainer   ──►  shap_rf.npy   + bar / beeswarm   │
│  LR  ──►  LinearExplainer ──►  shap_lr.npy   + bar / beeswarm   │
│  Lasso►  LinearExplainer  ──►  shap_lasso.npy + bar / beeswarm  │
│                                                                 │
│  (Ordinal Logistic skipped — KernelExplainer too slow)          │
│                                                                 │
│  shap_comparison.csv  ◄──  mean |SHAP| per feature × model      │
│                            sorted by RF importance              │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  PART 3 · CORRELATION CHECK                                     │
│                                                                 │
│  Full heatmap  ──►  heatmap_full.png  (all features)            │
│  Small heatmap ──►  heatmap_small.png (top 8 drivers only)      │
│                                                                 │
│  Result: no strong inter-correlations → drivers are             │
│          independent signals, not redundant duplicates          │
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

| Driver | RF | LR | Lasso | Signal Type |
|---|---|---|---|---|
| `salary_broader` | ● High | ● High | ● High | Universal — shows up everywhere |
| `careerstg_Career shifter` | ● High | ● High | ● High | Universal — strong negative signal |
| `sizeteam` | ● High | ◐ Mid | ◐ Mid | Mostly non-linear |
| `sitework_WFH / Remote` | ◯ Low | ● High | ◐ Mid | Primarily linear |
| `ai_work_Daily` | ◯ Low | ● High | ◐ Mid | Primarily linear |
| `ai_study_Daily` | ◐ Mid | ◐ Mid | ◐ Mid | Moderate, consistent |
| `datarole_Admin & Support` | ◐ Mid | ◐ Mid | ● High | Lasso highlights as sparse signal |
| `how_long_in_salary` | ◐ Mid | ◯ Low | ◯ Low | RF-specific (non-linear plateau effect) |

**Imporance of Multi-model work:** `sitework_WFH` scores 0.62 in LR SHAP but only 0.09 in RF SHAP. This difference is itself a finding — remote work has a clear *linear* relationship with satisfaction that tree-based models don't prioritize. Running only one model would have either over-emphasized or buried this driver.

**SHAP for OL skipped** Explainer not yet supported for tree/linear explainers on mord models, and KernelExplainer is computationally prohibitive at this feature count. 

---

## Output Files

```
project/
├── assets/
│   ├── shap_rf_bar.png          SHAP bar chart — Random Forest
│   ├── shap_rf_beeswarm.png     SHAP beeswarm — Random Forest
│   ├── shap_lr_bar.png          SHAP bar chart — Linear Regression
│   ├── shap_lr_beeswarm.png     SHAP beeswarm — Linear Regression
│   ├── shap_lasso_bar.png       SHAP bar chart — Lasso
│   ├── shap_lasso_beeswarm.png  SHAP beeswarm — Lasso
│   ├── heatmap_full.png         Correlation heatmap — all features
│   └── heatmap_small.png        Correlation heatmap — top 8 drivers
│
├── impact/
│   ├── rf_impact.csv            RF feature importances
│   ├── ol_impact0.csv           Ordinal Logit — unfiltered
│   ├── ol_impact1.csv           Ordinal Logit — n≥30 filtered
│   ├── ol_impact2.csv           Ordinal Logit — scaled + filtered
│   └── lasso_impact.csv         Lasso coefficients
│
├── models/
│   ├── model_rf.pkl
│   ├── model_ol0.pkl / model_ol1.pkl / model_ol2.pkl
│   ├── model_lr.pkl
│   └── model_lasso.pkl
│
└── shap_bin/
    ├── shap_rf.npy / shap_lr.npy / shap_lasso.npy
    ├── shap_rf_explanation.pkl
    ├── shap_lr_explanation.pkl
    ├── shap_lasso_explanation.pkl
    ├── shap_comparison.csv      Cross-model mean |SHAP| comparison table
    └── feature_correlations.csv Top-driver correlation matrix
```

---

## Dependencies

```
pandas · numpy · scikit-learn · mord · shap · matplotlib · seaborn · joblib
```

---

*Part of the DEP Annual Survey 2026 data pipeline. Survey data and individual-level responses are not included in this repository for privacy reasons.*
