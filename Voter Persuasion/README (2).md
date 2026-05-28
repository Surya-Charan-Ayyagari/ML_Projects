# Voter Persuasion Analytics

## Project Overview

This project applies supervised machine learning to a voter-level persuasion dataset to help a campaign-style organization understand which voters are most likely to respond to outreach. The analysis was created for a consulting scenario involving **CiviSight Analytics**, a political data science and strategic consulting firm supporting data-driven outreach planning.

The main goal is to move beyond broad outreach and build an interpretable analytics workflow that can help decision-makers prioritize voters based on persuasion likelihood, message response, party affiliation, candidate support, and demographic behavior.

## Business Problem

Campaign outreach resources are limited, so contacting every voter is not practical. The client needs a data-driven way to answer:

> Which voters are most likely to be persuaded by campaign messaging, and which voter segments should be prioritized for outreach?

The solution focuses on both prediction and interpretability. The models are designed not only to classify voters as persuadable or not persuadable, but also to explain the key factors behind persuasion so that non-technical campaign stakeholders can understand and use the results.

## Dataset

The project uses `VoterPersuasion.csv`, a voter-level dataset with **10,000 records** and **79 variables**. Each row represents one voter and includes demographic, household, political, voting history, candidate support, treatment, and outcome variables.

Key variables used in modeling include:

- `MOVED_A`: Target variable indicating whether a voter was persuaded
- `MESSAGE_A`: Campaign message treatment indicator
- `AGE`: Voter age
- `GENDER`: Derived gender variable from `GENDER_F` and `GENDER_M`
- `MED_HH_INC`: Median household income
- `PARTY_D`, `PARTY_R`: Party affiliation indicators
- `vote_count`: Engineered variable representing historical voting frequency
- `CAND1S`, `CAND2S`: Candidate support indicators

## Project Objectives

- Explore voter-level demographic, political, and behavioral patterns
- Evaluate the effect of campaign messaging on voter persuasion
- Engineer useful variables for supervised modeling
- Build interpretable classification models
- Compare model performance using accuracy, sensitivity, specificity, and AUC
- Translate model findings into clear outreach recommendations

## Tools and Technologies

- **R**
- **dplyr** for data manipulation
- **ggplot2** for visualization
- **caret** for partitioning and model evaluation
- **rpart** and **rpart.plot** for decision tree modeling
- **rattle** for decision tree visualization
- **pROC** and **ROCR** for ROC/AUC analysis
- **corrplot** for correlation analysis

## Analytics Workflow

The project follows a complete supervised machine learning workflow:

1. Project introduction and business context
2. Business and analytics goal definition
3. Data quality assessment
4. Exploratory data analysis
5. Predictor analysis and variable relevance
6. Data engineering and transformation
7. Train-test data partitioning
8. Model selection and justification
9. Model fitting and evaluation
10. Model performance reporting
11. Model comparison
12. Business observations and recommendations

## Data Preparation

The dataset was checked for structure, missing values, duplicates, and variable consistency.

Key preparation steps included:

- Verified that the dataset contains no missing values
- Confirmed that each `VOTER_ID` is unique
- Converted relevant variables into categorical factors
- Created a derived `GENDER` variable
- Created a new `vote_count` variable by summing prior election participation variables: `VG_04`, `VG_06`, `VG_08`, `VG_10`, and `VG_12`
- Selected a focused set of predictors to keep the model interpretable
- Standardized numeric variables for logistic regression
- Used original unstandardized data for decision tree modeling

## Exploratory Data Analysis Highlights

The target variable showed that **37.34%** of voters were persuaded, while **62.66%** were not persuaded. This class distribution provided enough examples in both groups for supervised classification.

The treatment variable was balanced, with **50%** of voters receiving the campaign message and **50%** not receiving it.

Message impact showed a measurable persuasion lift:

- Voters who did not receive the message: **34.4% persuaded**
- Voters who received the message: **40.2% persuaded**

This indicates that the campaign message increased persuasion by about **5.8 percentage points**.

Party affiliation showed strong differences in persuasion:

- Democrats had the highest persuasion rate
- Independents showed moderate persuasion potential
- Republicans had the lowest persuasion rate overall

Candidate support variables were among the strongest indicators of voter persuasion, showing that voters' initial candidate preferences were highly important for identifying persuadable segments.

## Models Built

Four supervised models were evaluated:

1. **Logistic Regression**
2. **Logistic Regression with Interaction Terms**
3. **Unpruned Decision Tree**
4. **Pruned Decision Tree**

### Logistic Regression

Logistic regression was selected for interpretability. It helps explain the direction and strength of each predictor's relationship with voter persuasion.

Key findings:

- Receiving `MESSAGE_A` increased persuasion likelihood
- Male voters were less likely to be persuaded than female voters
- Republican voters were less persuadable overall
- Candidate support variables were strong predictors
- Median household income and vote count were not strong predictors after controlling for other variables

### Logistic Regression with Interaction Terms

Interaction terms were added to understand whether campaign messages worked differently across voter segments.

Interactions tested:

- `MESSAGE_A × PARTY_R`
- `MESSAGE_A × CAND2S`

This model helped answer whether message effectiveness varies across party and candidate support segments.

### Decision Tree

A decision tree was used to identify rule-based voter segments. This model is useful for outreach planning because its output can be translated into simple decision rules.

The unpruned tree had strong performance but showed signs of overfitting because of small terminal nodes and near-perfect classifications.

### Pruned Decision Tree

The pruned decision tree was developed to reduce overfitting and improve generalizability. It used cost-complexity pruning with a complexity parameter of `cp = 0.0137`, increased cross-validation, and a larger minimum bucket size.

The pruned tree retained strong performance while producing simpler and more actionable voter segments.

## Model Performance

| Model | Accuracy | Sensitivity | Specificity |
|---|---:|---:|---:|
| Logistic Regression | 0.850 | 0.873 | 0.836 |
| Logistic Regression with Interactions | 0.852 | 0.882 | 0.834 |
| Decision Tree - Unpruned | 0.931 | 0.942 | 0.925 |
| Decision Tree - Pruned | 0.912 | 0.959 | 0.884 |

Additional model performance:

- Logistic Regression AUC: **0.8939**
- Logistic Regression with Interactions AUC: **0.8960**

## Final Model Recommendation

The **Pruned Decision Tree** is recommended as the primary targeting model because it provides the best balance between predictive performance, interpretability, and operational usefulness.

It achieved:

- **91.20% accuracy**
- **95.89% sensitivity**
- **88.40% specificity**

The high sensitivity is especially valuable because the campaign wants to avoid missing voters who are likely to be persuaded.

The logistic regression model with interaction terms is also valuable because it explains *why* persuasion happens and how message effects differ across voter groups. Together, the models provide both strategic insight and operational targeting rules.

## Key Business Insights

- Campaign messaging had a positive effect on voter persuasion.
- Candidate support variables were the strongest predictors of persuasion.
- Voters who were less firmly committed to a candidate were more likely to be persuaded.
- Party affiliation played an important role in persuasion behavior.
- The pruned decision tree can help identify high-priority voter segments for outreach.
- Logistic regression provides explainable insights for leadership and stakeholder communication.

## Repository Structure

```text
.
├── VoterPersuasion.csv
├── Voter Persuasion Analytics Rcode.R
├── VP R Output.txt
├── VOTER PERSUASION ANALYTICS.docx
└── README.md
```

## How to Run the Project

1. Clone this repository.
2. Open the R script file in RStudio.
3. Make sure `VoterPersuasion.csv` is in the same working directory as the R script.
4. Install the required R packages if they are not already installed.
5. Run the full script from top to bottom.
6. Review the model output, confusion matrices, ROC curves, and decision tree rules.

## Required R Packages

```r
lubridate
dplyr
ggplot2
caret
rpart
rattle
corrplot
scales
ROCR
pROC
rpart.plot
tidyr
```

## Skills Demonstrated

- Supervised machine learning
- Classification modeling
- Logistic regression
- Interaction effect analysis
- Decision tree modeling and pruning
- Feature engineering
- Train-test split validation
- Confusion matrix evaluation
- ROC and AUC analysis
- Data visualization
- Business-focused model interpretation
- Translating analytics into strategic recommendations

## Conclusion

This project demonstrates how voter-level data can be transformed into actionable insights through supervised machine learning. By combining interpretable statistical modeling with rule-based decision trees, the analysis helps identify persuadable voter segments, evaluate campaign message effectiveness, and support data-driven outreach planning.
