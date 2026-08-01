# Customer Churn Prediction

Predicting which customers are likely to churn so retention efforts
can be targeted before they leave, using classification models
optimized for recall and explained with SHAP.

## Overview

- **Type:** Binary classification
- **Dataset:** [IBM Telco Customer Churn](https://www.kaggle.com/blastchar/telco-customer-churn) — 7,043 customers, 21 features
- **Tools:** Python, pandas, scikit-learn, SHAP, matplotlib
- **Models:** Logistic Regression, Random Forest
- **Best model:** Logistic Regression — ROC-AUC 0.833, F2-Score 0.744

## Problem Statement

Customer churn directly costs recurring revenue. The cost of a missed
churner (lost customer) is higher than the cost of a false alarm
(an unnecessary retention offer), so the model is optimized for
**recall** — catching as many actual churners as possible — rather
than plain accuracy, which is misleading on this dataset given the
26.5% class imbalance.

## Data Preparation

- Removed 11 records with missing `TotalCharges` (all zero-tenure,
  new sign-ups with no meaningful churn label yet)
- Dropped `TotalCharges` due to high collinearity with `tenure` and
  `MonthlyCharges`
- Binary categorical fields (`Partner`, `Dependents`, `PhoneService`,
  `PaperlessBilling`, `gender`) encoded as 0/1
- Multi-category fields (`Contract`, `InternetService`,
  `PaymentMethod`, etc.) one-hot encoded
- Stratified 80/20 train-test split to preserve class balance

## Modeling

| Model | ROC-AUC | PR-AUC | Recall | Precision | F2-Score |
|---|---|---|---|---|---|
| **Logistic Regression** | **0.833** | **0.615** | **0.93** | 0.42 | **0.744** |
| Random Forest | 0.815 | 0.588 | 0.89 | 0.43 | 0.732 |

Logistic Regression was selected as the final model — it outperforms
Random Forest across every metric and is more interpretable for
business use.

The decision threshold was tuned to maximize F2-score (0.306) instead
of the default 0.5 cutoff, reflecting the priority on recall. At this
threshold, the model catches **93% of customers who will churn**, at
the cost of a lower precision (42%) — an intentional tradeoff given
the relative cost of missed churners vs. unnecessary retention offers.

## Key Drivers of Churn (SHAP)

- **Contract type** — month-to-month customers churn at 42.7%, vs.
  2.8% for two-year contracts
- **Tenure** — churners average 17.9 months vs. 37.6 months for
  retained customers
- **Internet service type** and **monthly charges** are secondary
  drivers

Highest-risk segment: short-tenure, month-to-month customers with
higher monthly bills.

## Repository Structure

```
telco-churn-prediction/
├── telco_churn_prediction.ipynb   # Full notebook: EDA, preprocessing, modeling, evaluation, SHAP
├── telco_churn.csv                # Dataset
├── churn_distribution.png         # Class balance chart
├── shap_summary.png               # Feature importance / SHAP summary
└── README.md
```

## Tech Stack

`Python` · `pandas` · `NumPy` · `scikit-learn` · `SHAP` · `matplotlib`
