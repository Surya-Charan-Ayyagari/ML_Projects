# 📊 Consumer Behavior Analytics – GourmetHub Market Case

## 📌 Project Overview
This project analyzes consumer behavior to help **GourmetHub** improve marketing effectiveness. It combines segmentation, association analysis, regression, and classification models to understand customer behavior and predict campaign response.

Instead of targeting all customers equally, the goal is to identify high-value segments and design data-driven marketing strategies.

---

## 🎯 Objectives
- Segment customers based on demographics and behavior  
- Analyze campaign effectiveness  
- Identify patterns in purchasing behavior  
- Predict customer engagement (purchases)  
- Predict campaign response  
- Provide actionable marketing recommendations  

---

## 📂 Dataset
- **File:** `Consumer_Data.csv`  
- **Records:** 2,240 customers  
- **Features:** 29 variables  

The dataset includes:
- Demographics (Age, Income, Education, Marital Status)  
- Spending behavior (Mnt variables)  
- Purchase channels (Web, Store, Catalog)  
- Campaign responses (AcceptedCmp1–5, Response)  

---

## 🔍 Data Processing
Key steps performed:

- Missing value handling (Income imputed using median)  
- Feature engineering:
  - Age  
  - TotalSpend  
  - TotalPurchases  
  - AcceptedAny (campaign response flag)  
- Encoding categorical variables  
- PCA applied to spending variables (reduced to 3 components)  
- Train-test split (70% / 30%)  

Dataset summary:
- 2240 rows, 29 columns  
- No duplicate customer IDs  
- ~20% customers responded to campaigns  

---

## 📊 Exploratory Data Analysis (EDA)
Key insights:

- Wines and meat products dominate spending  
- Store purchases are highest, followed by web purchases  
- Higher income → higher spending and purchases  
- Campaign response rate is low (~15%)  
- Customers who respond:
  - Have higher income  
  - Spend more  
  - Purchase more frequently  

---

## 🧠 Methodology

### 1. Customer Segmentation (K-Means)
- Used demographic + behavioral variables + PCA features  
- Optimal clusters: **k = 4**
- Silhouette score: **0.53**

**Key insight:**  
One segment shows ~51% response rate (high-value customers)

---

### 2. Association Analysis (Apriori)
- Converted data into transaction format  
- Generated behavioral rules  

**Example rule:**
Web Buyer + Catalog Buyer → Campaign Acceptance
Confidence: ~32% | Lift: >1.5


Multi-channel customers are more likely to respond.

---

### 3. Regression (Customer Engagement)
- Target: **TotalPurchases**

Key predictors:
- Income  
- Household composition  
- Web visits  
- PCA components  

**Performance:**
- Training R²: ~0.65  
- Test R²: ~0.19  

Good for understanding drivers, moderate for prediction.

---

### 4. Classification (Campaign Response)

Models used:
- Logistic Regression  
- Decision Tree  
- Random Forest  

**Best Model: Logistic Regression**

| Metric | Value |
|------|------|
| Accuracy | ~74% |
| AUC | ~0.776 |
| Balanced Accuracy | ~73% |

Provides strong balance of performance and interpretability.

---

## 📈 Key Findings

- High-income customers are more likely to respond  
- Multi-channel buyers respond more  
- Higher engagement leads to higher conversion  
- Clear high-response customer segment identified  

---

## 💡 Business Recommendations

- Target high-income, high-spending customers  
- Focus campaigns on multi-channel buyers  
- Promote premium products (wine, meat)  
- Reduce targeting of low-response segments  
- Use predictive models to prioritize customers  

---

## 🛠️ Tech Stack
- **Language:** R  
- **Libraries:**
  - dplyr  
  - ggplot2  
  - caret  
  - rpart  
  - randomForest  
  - arules  
  - cluster  

---

## 📁 Project Structure
├── Consumer_Data.csv
├── Cons_Bhv_Rcode v2.R
├── Consumer_Behavior_Analytics.docx
├── README.md

---

## 🚀 How to Run
1. Load dataset in R  
2. Install required packages  
3. Run the R script  
4. Review outputs:
   - EDA summaries  
   - Clustering results  
   - Model performance  

---

## 📊 Conclusion
This project demonstrates how combining segmentation, prediction, and behavioral analysis can improve marketing decisions.

Instead of broad campaigns, businesses can:
- Target the right customers  
- Improve conversion rates  
- Optimize marketing spend  
