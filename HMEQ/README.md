# Home Equity Loan Decision Analytics

## Overview

This project builds a data-driven credit risk analytics framework for a regional bank's home equity lending portfolio. The goal is to identify borrowers who are more likely to default or become seriously delinquent while still supporting responsible loan growth.

The analysis uses the HMEQ home equity loan dataset and applies exploratory data analysis, data preprocessing, feature engineering, clustering, regression, and classification modeling in R. The final solution focuses on explainability, because credit decisions must be supported by clear and defensible risk factors.

## Business Problem

The bank's previous underwriting process relied on a mix of internal guidelines and underwriter judgment. As loan volume increased, this created challenges around consistency, scalability, and decision speed.

This project addresses the following business question:

> Can borrower, credit history, debt burden, and collateral-related variables be used to build an interpretable credit scoring framework that improves default risk identification while maintaining loan approval growth?

## Dataset

The dataset contains **5,960 approved home equity loan records** with borrower characteristics captured at origination and later loan performance outcomes.

The target variable is:

- `BAD = 1`: borrower defaulted or became seriously delinquent
- `BAD = 0`: borrower remained current

Class distribution:

- **Current borrowers:** 4,771 records (80.05%)
- **Bad borrowers:** 1,189 records (19.95%)

Key input variables include loan amount, mortgage balance, property value, loan reason, job category, years at job, delinquent credit lines, derogatory reports, credit line age, recent credit inquiries, number of credit lines, and debt-to-income ratio.

## Tools & Technologies

- **Language:** R
- **Data Wrangling:** dplyr, tidyr
- **Visualization:** ggplot2, corrplot, factoextra, rpart.plot, rattle
- **Missing Value Treatment:** missRanger, mice
- **Modeling:** caret, rpart, C5.0, ROSE, kmeans, Regression
- **Analytics Methods:** EDA, feature engineering, imputation, oversampling, clustering, regression, classification, ROC/AUC evaluation

## Project Workflow

The project follows a full machine learning workflow:

1. Business problem definition
2. Data loading and structure review
3. Exploratory data analysis
4. Missing value and anomaly detection
5. Feature engineering and transformation
6. Train-test partitioning
7. Class imbalance handling
8. Clustering analysis
9. Regression analysis for leverage modeling
10. Classification modeling for default prediction
11. Model comparison and business interpretation
12. Final recommendation

## Data Preparation

Several data quality issues were handled before modeling:

- Converted blank categorical values in `REASON` and `JOB` into missing values
- Reviewed missing value patterns across borrower and credit variables
- Created a `MISS_CRED_INFO` indicator for borrowers with jointly missing credit-history fields
- Detected extreme values using the mean plus three standard deviation rule
- Replaced unrealistic `CLAGE` values greater than 1,150 months with 0 when `CLNO = 0`
- Applied missRanger imputation after train-test splitting to avoid data leakage
- Dummy encoded categorical variables for modeling
- Scaled numeric variables for clustering
- Created `LTV` as a loan-to-value feature to represent collateral exposure

## Key EDA Insights

Credit behavior was the strongest indicator of default risk:

- Borrowers with zero delinquent credit lines had a BAD rate of **14.0%**
- Borrowers with one delinquent credit line had a BAD rate of **33.9%**
- Borrowers with two delinquent credit lines had a BAD rate of **44.8%**
- Borrowers with three delinquent credit lines had a BAD rate of **55.0%**

Derogatory credit reports showed a similar risk pattern:

- Borrowers with zero derogatory reports had a BAD rate of **16.7%**
- Borrowers with one derogatory report had a BAD rate of **38.9%**
- Borrowers with two derogatory reports had a BAD rate of **51.2%**
- Borrowers with three derogatory reports had a BAD rate of **74.1%**

Correlation analysis also showed that:

- `DELINQ`, `DEROG`, and `DEBTINC` had the strongest positive relationships with default risk
- `CLAGE` had a negative relationship with default risk, meaning longer credit history was associated with lower risk
- `MORTDUE` and `VALUE` were highly correlated, showing overlap between mortgage balance and property value

## Feature Engineering

Important engineered features included:

### Missing Credit Information Flag

`MISS_CRED_INFO` was created to capture borrowers whose credit-history variables were missing together. This helped preserve information about thin or incomplete credit files.

### Loan-to-Value Ratio

`LTV` was created using:

```r
LTV = LOAN / VALUE
```

This feature helped explain borrower leverage and collateral exposure in a simple, business-friendly way.

## Modeling Approach

### 1. Clustering

K-means clustering was used to segment borrowers based on risk and financial profiles.

A final **two-cluster solution** was selected because it gave clearer business interpretation than three-cluster alternatives.

Final cluster results:

| Cluster | Records | Default Rate | Interpretation |
|---|---:|---:|---|
| Cluster 1 | 1,174 | 15.8% | Lower-risk segment with longer credit history and fewer risk indicators |
| Cluster 2 | 2,998 | 21.3% | Higher-risk segment with shorter credit history and more credit risk signals |

### 2. Regression

Regression models were used to study borrower leverage through `LTV`.

Models tested:

- Linear regression
- Stepwise regression
- Improved regression with transformed mortgage balance
- Regression tree
- Pruned regression tree

The regression tree provided an interpretable view of leverage patterns, with `MORTDUE`, `REASON`, `CLAGE`, `DEROG`, `DEBTINC`, and `CLNO` appearing as important split variables.

### 3. Classification

Classification was the primary modeling task because the main goal was to predict whether a borrower would become a bad borrower.

Models tested:

- Logistic Regression
- Pruned Decision Tree
- C5.0 Rule-Based Classifier

Oversampling was applied only to the training data to improve learning from the minority default class.

## Model Performance

| Model | Accuracy | Sensitivity | Specificity | Balanced Accuracy | AUC | Approval Rate | Default Rate Among Approved |
|---|---:|---:|---:|---:|---:|---:|---:|
| Logistic Regression | 75.17% | 57.97% | 79.56% | 68.77% | 0.7757 | 71.92% | 11.90% |
| Pruned Decision Tree | 75.28% | 65.38% | 77.81% | 71.60% | 0.7625 | 69.02% | 10.21% |
| C5.0 Classifier | 87.42% | 64.84% | 93.19% | 79.01% | 0.8343 | 81.38% | 8.80% |

## Final Model Selection

The **C5.0 classifier** was selected as the final classification model.

It performed best across the most important business and model evaluation metrics:

- Highest accuracy
- Highest specificity
- Highest balanced accuracy
- Highest AUC
- Lowest default rate among approved borrowers
- Strong approval rate while controlling risk
- Rule-based structure that supports explainable credit decisions

## Business Impact

This project shows how machine learning can support credit decision-making in a way that is both practical and explainable.

The final model helps the bank:

- Identify borrowers with higher default risk
- Reduce inconsistency from manual underwriting judgment
- Support faster and more scalable loan decisions
- Maintain responsible approval volume
- Explain decisions using clear borrower risk factors
- Balance credit risk control with loan growth objectives

## Key Takeaways

- Credit behavior variables such as `DELINQ`, `DEROG`, `NINQ`, and `CLAGE` were more predictive than loan amount alone.
- Debt burden, represented by `DEBTINC`, was an important risk indicator.
- Missing credit-history information carried useful business meaning and was captured through feature engineering.
- C5.0 provided the best balance between predictive performance and interpretability.
- The final solution can act as a decision-support framework for home equity loan risk assessment.

## Repository Structure

```text
.
├── HMEQ Rcode.R                         # Full R analysis script
├── HMEQ R Output.txt                    # Console output and model results
├── HOME EQUITY LOAN DECISION MAKING ANALYTICS.docx  # Final project report
├── Home Equity Loan Project Req.docx    # Project requirements
├── hmeq.csv                             # Dataset
└── README.md                            # Project overview
```

## How to Run

1. Clone this repository.
2. Open `HMEQ Rcode.R` in RStudio.
3. Place `hmeq.csv` in the same working directory as the R script.
4. Install the required packages listed in the script.
5. Run the script from top to bottom.
6. Review the generated plots, model outputs, and evaluation metrics.

## Summary

This project demonstrates end-to-end analytics skills across data cleaning, feature engineering, statistical modeling, machine learning, model evaluation, and business communication. It also highlights the ability to build interpretable models for a regulated financial services use case where accuracy, explainability, and business impact all matter.
