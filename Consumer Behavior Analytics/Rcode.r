#========================================================
# 1. INSTALL & LOAD REQUIRED PACKAGES (AI Assisted)
#========================================================

required_packages <- c(
  "lubridate",
  "dplyr",
  "ggplot2",
  "arules",
  "caret",
  "rpart",
  "fastDummies",
  "cluster",
  "corrplot",
  "scales",
  "ROCR",
  "ROSE",
  "randomForest"
)

# Install missing packages only
new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]

if(length(new_packages)) {
  install.packages(new_packages)
}

# Load all packages
lapply(required_packages, library, character.only = TRUE)


# Avoid scientific notation in printed output
options(scipen = 999) #AI Assisted

# Save current plotting settings
old_par <- par(no.readonly = TRUE) #AI Assisted

#---------------------------
# 2. Load the dataset
#---------------------------
cat("------------ DATA LOADING ------------\n")

cons_data <- read.csv("./Consumer_Data.csv")

cat("Dataset loaded successfully.\n")
cat("Number of rows   :", nrow(cons_data), "\n")
cat("Number of columns:", ncol(cons_data), "\n\n")

#---------------------------
# 3. Initial data quality check
#---------------------------
cat("------------ INITIAL DATA QUALITY CHECK ------------\n")

cat("Preview of first 6 rows:\n")
print(head(cons_data))

cat("\nStructure of dataset:\n")
str(cons_data)

# Convert variables to appropriate data types
cons_data$Education <- as.factor(cons_data$Education)
cons_data$Marital_Status <- as.factor(cons_data$Marital_Status)
cons_data$Dt_Customer <- as.Date(cons_data$Dt_Customer, format = "%d-%m-%Y")

cat("\nSummary statistics:\n")
print(summary(cons_data))

cat("\nMissing values in each column:\n")
print(colSums(is.na(cons_data)))

cat("\nChecking uniqueness of customer IDs:\n")
cat("Unique IDs:", length(unique(cons_data$ID)), "\n")
cat("Total records:", nrow(cons_data), "\n")

if (length(unique(cons_data$ID)) == nrow(cons_data)) {
  cat("Result: No duplicate customer IDs detected.\n\n")
} else {
  cat("Warning: Duplicate customer IDs may exist.\n\n")
}

#-----------------------------
# 4. Create Variables for EDA
#-----------------------------

cons_data$TotalSpend <- cons_data$MntWines + cons_data$MntFruits +
  cons_data$MntMeatProducts + cons_data$MntFishProducts +
  cons_data$MntSweetProducts + cons_data$MntGoldProds

cons_data$TotalPurchases <- cons_data$NumCatalogPurchases +
  cons_data$NumDealsPurchases + cons_data$NumStorePurchases +
  cons_data$NumWebPurchases

cons_data$HighestSpendProduct <- c("Wines", "Fruits", "Meat", "Fish", "Sweets", "Gold")[
  max.col(cons_data[, c("MntWines", "MntFruits", "MntMeatProducts",
                        "MntFishProducts", "MntSweetProducts", "MntGoldProds")],
          ties.method = "first")
]

cons_data$Age <- as.numeric(format(Sys.Date(), "%Y")) - cons_data$Year_Birth

cons_data$IncomeBins <- cut(
  cons_data$Income,
  breaks = c(0, 30000, 60000, 90000, 120000, Inf),
  labels = c("0-30k", "30k-60k", "60k-90k", "90k-120k", "120k+")
)

cons_data$AgeBins <- cut(
  cons_data$Age,
  breaks = c(0, 18, 25, 30, 40, 50, 60, 70, 90, Inf)
)

#---------------------------
# 5. Exploratory analysis
#---------------------------
cat("------------ EXPLORATORY DATA ANALYSIS ------------\n")

cat("Total spending across product categories:\n")
print(colSums(cons_data[, 10:15], na.rm = TRUE))

cat("\nTotal transactions across purchase channels:\n")
print(colSums(cons_data[, 16:20], na.rm = TRUE))

cat("\nSummary of Age:\n")
print(summary(cons_data$Age))

cat("\nIncome group distribution:\n")
print(table(cons_data$IncomeBins, useNA = "ifany"))

cat("\nAge group distribution:\n")
print(table(cons_data$AgeBins, useNA = "ifany"))

# Scatterplots to inspect relationships between income and consumer value
ggplot(cons_data[!is.na(cons_data$Income), ],
       aes(x = Income, y = TotalSpend)) +
  geom_point() +
  scale_x_continuous(labels = comma) +
  labs(title = "Income vs Total Spend")

ggplot(cons_data[!is.na(cons_data$Income), ],
       aes(x = Income, y = TotalPurchases)) +
  geom_point() +
  scale_x_continuous(labels = comma) +
  labs(title = "Income vs Total Purchases")

cat("\nIncome-based consumer summary:\n")
income_summary <- cons_data %>%
  group_by(IncomeBins) %>%
  summarise(
    count = n(),
    AvgIncome = mean(Income, na.rm = TRUE),
    AvgSpend = mean(TotalSpend, na.rm = TRUE),
    AvgPurchases = mean(TotalPurchases, na.rm = TRUE),
    AvgRecency = mean(Recency, na.rm = TRUE),
    Response_Acpt_per = mean(Response, na.rm = TRUE) * 100,
    .groups = "drop"
  )
print(income_summary)

cat("\nTop 3 products within each income group:\n")  #AI Assisted
top_income_products <- cons_data %>%
  group_by(IncomeBins, HighestSpendProduct) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(IncomeBins) %>%
  slice_max(order_by = count, n = 3) %>%
  ungroup()
print(top_income_products)

cat("\nAge-group summary:\n")
age_summary <- cons_data %>%
  group_by(AgeBins) %>%
  summarise(
    count = n(),
    AvgIncome = mean(Income, na.rm = TRUE),
    AvgSpend = mean(TotalSpend, na.rm = TRUE),
    AvgPurchases = mean(TotalPurchases, na.rm = TRUE),
    AvgRecency = mean(Recency, na.rm = TRUE),
    Response_Acpt_per = mean(Response, na.rm = TRUE) * 100,
    .groups = "drop"
  )
print(age_summary)

cat("\nTop 3 products within each age group:\n") 
top_age_products <- cons_data %>%
  group_by(AgeBins, HighestSpendProduct) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(AgeBins) %>%
  slice_max(order_by = count, n = 3) %>%
  ungroup()
print(top_age_products)

cat("\nEducation-level summary:\n")
education_summary <- cons_data %>%
  group_by(Education) %>%
  summarise(
    count = n(),
    AvgIncome = mean(Income, na.rm = TRUE),
    AvgSpend = mean(TotalSpend, na.rm = TRUE),
    AvgPurchases = mean(TotalPurchases, na.rm = TRUE),
    AvgRecency = mean(Recency, na.rm = TRUE),
    Response_Acpt_per = mean(Response, na.rm = TRUE) * 100,
    .groups = "drop"
  )
print(education_summary)

cat("\nTop 3 products within each education group:\n")
top_education_products <- cons_data %>%
  group_by(Education, HighestSpendProduct) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(Education) %>%
  slice_max(order_by = count, n = 3) %>%
  ungroup()
print(top_education_products)

cat("\nMarital status summary:\n")
marital_summary <- cons_data %>%
  group_by(Marital_Status) %>%
  summarise(
    count = n(),
    AvgIncome = mean(Income, na.rm = TRUE),
    AvgSpend = mean(TotalSpend, na.rm = TRUE),
    AvgPurchases = mean(TotalPurchases, na.rm = TRUE),
    AvgRecency = mean(Recency, na.rm = TRUE),
    Response_Acpt_per = mean(Response, na.rm = TRUE) * 100,
    .groups = "drop"
  )
print(marital_summary)

cat("\nTop 3 products within each marital status group:\n") 
top_marital_products <- cons_data %>%
  group_by(Marital_Status, HighestSpendProduct) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(Marital_Status) %>%
  slice_max(order_by = count, n = 3) %>%
  ungroup()
print(top_marital_products, n = 100)

cat("\nCAMPAIGN RESPONSE ANALYSIS\n")

cat("Percentage acceptance across previous campaigns:\n")
campaign_acceptance <- round(
  colMeans(cons_data[, c("AcceptedCmp1", "AcceptedCmp2", "AcceptedCmp3",
                         "AcceptedCmp4", "AcceptedCmp5")], na.rm = TRUE) * 100, 2
)
print(campaign_acceptance)

# Create a response flag for whether the consumer accepted at least one of the previous campaigns
cons_data$AcceptedAny <- ifelse(
  (cons_data$AcceptedCmp1 + cons_data$AcceptedCmp2 + cons_data$AcceptedCmp3 +
     cons_data$AcceptedCmp4 + cons_data$AcceptedCmp5) > 0, 1, 0
)

cat("\nSummary of consumers by response to any previous campaign:\n")
campaign_response_summary <- cons_data %>%
  group_by(AcceptedAny) %>%
  summarise(
    count = n(),
    AvgIncome = mean(Income, na.rm = TRUE),
    AvgSpend = mean(TotalSpend, na.rm = TRUE),
    AvgPurchases = mean(TotalPurchases, na.rm = TRUE),
    AvgRecency = mean(Recency, na.rm = TRUE),
    Response_Acpt_per = mean(AcceptedAny, na.rm = TRUE) * 100,
    .groups = "drop"
  )
print(campaign_response_summary)

#---------------------------
# 7. Data visualization
#---------------------------
cat("\n------------ VISUAL INSPECTION OF NUMERIC VARIABLES ------------\n")

num_var <- c("Income", "Kidhome", "Teenhome", "Recency", "MntWines", "MntFruits",
             "MntMeatProducts", "MntSweetProducts", "MntFishProducts", "MntGoldProds",
             "NumWebPurchases", "NumDealsPurchases", "NumCatalogPurchases",
             "NumStorePurchases", "NumWebVisitsMonth")

cat("Creating histograms for selected numeric variables...\n")
par(mfrow = c(2, 3), mar = c(4, 4, 2, 1))
for (x in num_var) {
  hist(cons_data[[x]],
       main = paste("Histogram of", x),
       xlab = x,
       col = "lightgray",
       border = "white")
}

cat("Creating boxplots for selected numeric variables...\n")
for (x in num_var) {
  boxplot(cons_data[[x]],
          main = paste("Boxplot of", x),
          ylab = x,
          col = "lightgray",
          border = "black")
}
par(mfrow = c(1, 1))
par(old_par)

#---------------------------
# 8. Correlation analysis
#---------------------------
cat("\n------------ CORRELATION ANALYSIS ------------\n")

cor_data <- cons_data[, -c(1, 2, 3, 4, 8, 27, 28, 30:36)]
cor_mat <- round(cor(cor_data, use = "complete.obs"), 2)

cat("Correlation matrix calculated.\n")
print(cor_mat)

corrplot::corrplot.mixed(cor_mat)

#---------------------------
# 9. Missing value analysis
#---------------------------
cat("\n------------ MISSING VALUE ANALYSIS ------------\n")

inc_na <- cons_data[is.na(cons_data$Income), ]

cat("Number of missing Income values:", nrow(inc_na), "\n")
cat("Summary of records with missing Income:\n")
print(summary(inc_na))

#---------------------------
# 10. Train-test split
#---------------------------


cat("\n------------ TRAIN-TEST SPLIT ------------\n")

set.seed(2026)

# Remove unsed variables
cons_data <- cons_data[,-c(1,2,8,27:29)]

cat("Target variable distribution before split:\n")
print(prop.table(table(cons_data$AcceptedAny)))

idx <- createDataPartition(cons_data$AcceptedAny, p = 0.7, list = FALSE)

train_data <- cons_data[idx, ]
test_data  <- cons_data[-idx, ]

cat("\nTraining set size  :", nrow(train_data), "\n")
cat("Testing set size   :", nrow(test_data), "\n")

cat("\nTarget variable distribution in training data:\n")
print(prop.table(table(train_data$AcceptedAny)))

cat("\nTarget variable distribution in testing data:\n")
print(prop.table(table(test_data$AcceptedAny)))

cat("\nTraining data summary:\n")
print(summary(train_data))

#---------------------------
# 11. Income imputation
#---------------------------

cat("\n------------ INCOME IMPUTATION ------------\n")

med_income_tr <- median(train_data$Income, na.rm = TRUE)

train_data$IncomeImp <- ifelse(is.na(train_data$Income),
                               med_income_tr,
                               train_data$Income)

test_data$IncomeImp <- ifelse(is.na(test_data$Income),
                              med_income_tr,
                              test_data$Income)

cat("Median income used for imputation:", med_income_tr, "\n")

cat("\nSummary of imputed training income:\n")
print(summary(train_data$IncomeImp))

cat("\nMissing Income values after imputation:\n")
cat("Training data:", sum(is.na(train_data$IncomeImp)), "\n")
cat("Testing data :", sum(is.na(test_data$IncomeImp)), "\n")

#---------------------------
# 12. PCA on spending variables
#---------------------------


cat("\n------------ PCA FOR SPENDING VARIABLES ------------\n")

mnt_vars <- c("MntWines", "MntFruits", "MntMeatProducts",
              "MntFishProducts", "MntSweetProducts", "MntGoldProds")

mnt_vars_scaled <- scale(train_data[, mnt_vars])

pca_mnt <- prcomp(mnt_vars_scaled, center = TRUE, scale. = TRUE)

cat("PCA completed successfully.\n")
cat("\nPCA summary:\n")
print(summary(pca_mnt))

cat("\nProportion of variance explained by first 3 components:\n")
print(summary(pca_mnt)$importance[2, 1:3])

plot(pca_mnt, type = "l", main = "Scree Plot for Spending Variables")

pca_3 <- as.data.frame(pca_mnt$x[, 1:3])
colnames(pca_3) <- c("PC1", "PC2", "PC3")

train_center <- attr(mnt_vars_scaled, "scaled:center")
train_scale  <- attr(mnt_vars_scaled, "scaled:scale")

test_mnt_scaled <- scale(
  test_data[, mnt_vars],
  center = train_center,
  scale  = train_scale
)
test_pca <- predict(pca_mnt, newdata = test_mnt_scaled)
test_pca_3 <- as.data.frame(test_pca[, 1:3])
colnames(test_pca_3) <- c("PC1", "PC2", "PC3")

cat("\nFirst 3 principal components extracted for clustering.\n")

#--------------------------------------
# 13. Standardization of numeric variables
#---------------------------------------

std_model <- preProcess(train_data, method = "range")
train_data_std <- predict(std_model, train_data)
test_data_std <- predict(std_model, test_data)

#---------------------------
# 14. Clustering analysis
#---------------------------


cat("\n------------ CLUSTERING ANALYSIS ------------\n")

cluster_var <- c("Age", "Education", "Marital_Status", "IncomeImp",
                 "Kidhome", "Teenhome", "Recency", "NumDealsPurchases",
                 "NumWebPurchases", "NumCatalogPurchases", "NumStorePurchases",
                 "NumWebVisitsMonth", "Complain")

cluster_data <- train_data[, cluster_var]

cat("Preparing clustering dataset...\n")
cat("Variables used for clustering:\n")
print(cluster_var)

cluster_data <- fastDummies::dummy_cols(
  cluster_data,
  select_columns = c("Marital_Status", "Education"),
  remove_first_dummy = TRUE,
  remove_selected_columns = TRUE
)

cat("\nDimensions after dummy variable creation:\n")
print(dim(cluster_data))

# Add PCA components to the clustering input
cluster_data <- cbind(cluster_data, pca_3)

cat("\nDimensions after adding PCA components:\n")
print(dim(cluster_data))

set.seed(2026)

wss <- numeric(9)

for (k in 2:10) {
  km_model <- kmeans(cluster_data, centers = k, nstart = 25)
  wss[k-1] <- km_model$tot.withinss
}

# AI Assisted
elbow_df <- data.frame(
  k = 2:10,
  WSS = wss
)

cat("Within-cluster sum of squares for k = 2 to 10:\n")
print(elbow_df)

ggplot(elbow_df, aes(x = k, y = WSS)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Elbow Method for Optimal Number of Clusters",
    x = "Number of Clusters (k)",
    y = "Total Within-Cluster Sum of Squares"
  ) +
  theme_minimal()


set.seed(2026)
cluster_model <- kmeans(cluster_data, centers = 4, nstart = 25)

train_data$cluster <- cluster_model$cluster

cat("\nK-means clustering completed.\n")
cat("Cluster sizes:\n")
print(table(train_data$cluster))

cat("\nCluster centers:\n")
print(cluster_model$centers)

# Silhouette plot checks how well observations fit their assigned clusters
sil <- silhouette(cluster_model$cluster, dist(cluster_data))
plot(sil, main = "Silhouette Plot (k = 4)", col = 1:4, border = NA)

cat("\nAverage silhouette width:\n")
print(summary(sil)$avg.width)

# Create cluster profiles using the original clustering variables
cluster_profile_data <- train_data[, c(cluster_var, "cluster")]

cluster_profile_all <- cluster_profile_data %>%
  group_by(cluster) %>%
  summarise(
    across(where(is.numeric), ~mean(.x, na.rm = TRUE)),
    .groups = "drop"
  )

cat("\nCluster profile summary:\n")
print(cluster_profile_all)
# Most common Education by cluster
cluster_profile_edu <- train_data %>%
  group_by(cluster, Education) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(cluster) %>%
  slice_max(order_by = count, n = 1) %>%
  ungroup()

cat("\nMost common education level by cluster:\n")
print(cluster_profile_edu)

# Most common Marital Status by cluster
cluster_profile_marital <- train_data %>%
  group_by(cluster, Marital_Status) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(cluster) %>%
  slice_max(order_by = count, n = 1) %>%
  ungroup()
cat("\nMost common marital status by cluster:\n")
print(cluster_profile_marital)

# Campaign Acceptance across clusters
cat("\nCampaign Acceptance across clusters:\n")
cluster_cmpAccept <- train_data %>% 
  group_by(cluster) %>% 
  summarise(cmp1 = mean(AcceptedCmp1),cmp2 = mean(AcceptedCmp2),
            cmp3 = mean(AcceptedCmp3),cmp4 = mean(AcceptedCmp4),
            cmp5 = mean(AcceptedCmp5),cmpAny = mean(AcceptedAny))
print(cluster_cmpAccept)

#--------------------------------------------------
# 15. TESTING WHETHER CLUSTERS ARE MEANINGFULLY DIFFERENT (AI ASSISTED)
#--------------------------------------------------


cat("\n-------ANOVA: Income vs Cluster -------\n")

anova_income <- aov(IncomeImp ~ as.factor(cluster), data = train_data)
print(summary(anova_income))


# CHI-SQUARE TEST: CLUSTER VS EDUCATION

cat("\n----- Chi-Square: Cluster vs Education -------\n")

table_edu <- table(train_data$cluster, train_data$Education)
print(table_edu)

chisq_edu <- chisq.test(table_edu)
print(chisq_edu)

# CHI-SQUARE TEST: CLUSTER VS CAMPAIGN RESPONSE
cat("\n------- Chi-Square: Cluster vs AcceptedAny -------\n")

table_resp <- table(train_data$cluster, train_data$AcceptedAny)
print(table_resp)

chisq_resp <- chisq.test(table_resp)
print(chisq_resp)

# AVERAGE RESPONSE RATE BY CLUSTER
cat("\nAverage Response Rate by Cluster:\n")

avg_resp <- aggregate(AcceptedAny ~ cluster, data = train_data, mean)
print(avg_resp)

# LOGISTIC REGRESSION: CLUSTER ->RESPONSE
cat("\nLogistic Regression: Cluster Predicting Response \n")

model <- glm(AcceptedAny ~ as.factor(cluster),
             data = train_data,
             family = "binomial")

print(summary(model))

#-------------------------
# 16. Association Analysis
#-------------------------
cat("\n------------ASSOCIATION ANALYSIS-----------------")
arule_data <- train_data[,c("AcceptedCmp1", "AcceptedCmp2", "AcceptedCmp3",
                            "AcceptedCmp4", "AcceptedCmp5", "AcceptedAny")]

# Convert Spending and Purchase behavior variables to Binary for Association Analysis
arule_data$Buy_Wine <- ifelse(train_data$MntWines > 1, 1, 0)
arule_data$Buy_Fruits <- ifelse(train_data$MntFruits > 1, 1, 0)
arule_data$Buy_Meat <- ifelse(train_data$MntMeatProducts > 1, 1, 0)
arule_data$Buy_Fish <- ifelse(train_data$MntFishProducts > 1, 1, 0)
arule_data$Buy_Sweet <- ifelse(train_data$MntSweetProducts > 1, 1, 0)
arule_data$Buy_Gold <- ifelse(train_data$MntGoldProds > 1, 1, 0)
arule_data$Deal_Buyer <- ifelse(train_data$NumDealsPurchases > 1, 1, 0)
arule_data$Web_Buyer <- ifelse(train_data$NumWebPurchases > 1, 1, 0)
arule_data$Catalog_Buyer <- ifelse(train_data$NumCatalogPurchases > 1, 1, 0)
arule_data$Store_Buyer <- ifelse(train_data$NumStorePurchases > 1, 1, 0)

# Convert to factor with labels (IMPORTANT)
arule_data[] <- lapply(arule_data, function(x) {
  factor(x, levels = c(0, 1), labels = c("No", "Yes"))
})

cat("Dimensions of association dataset:\n")
print(dim(arule_data))

trans <- as(arule_data, "transactions")

summary(trans)

rules_campaign <- apriori(
  trans,
  parameter = list(supp = 0.01, conf = 0.30, minlen = 2),
  appearance = list(
    rhs = c("AcceptedAny=Yes",
            "AcceptedCmp1=Yes", "AcceptedCmp2=Yes",
            "AcceptedCmp3=Yes", "AcceptedCmp4=Yes",
            "AcceptedCmp5=Yes"
            ),
    default = "lhs"
  )
)

cat("\nNumber of campaign-related rules:\n")
print(length(rules_campaign))

# Sort and inspect
rules_sorted <- sort(rules_campaign, by = "lift")

cat("\nTop rules:\n")
inspect(head(rules_sorted, 10))


# Keep only campaign success items for RHS
rhs_items <- c("AcceptedCmp1=Yes", "AcceptedCmp2=Yes",
               "AcceptedCmp3=Yes", "AcceptedCmp4=Yes",
               "AcceptedCmp5=Yes", "AcceptedAny=Yes")

# LHS should contain only Yes items excluding RHS items
lhs_items <- c("Buy_Wine=Yes", "Buy_Fruits=Yes", "Buy_Meat=Yes",
               "Buy_Fish=Yes", "Buy_Sweet=Yes", "Buy_Gold=Yes",
               "Deal_Buyer=Yes", "Web_Buyer=Yes",
               "Catalog_Buyer=Yes", "Store_Buyer=Yes")

rules_campaign_yeslhs <- apriori(
  trans,
  parameter = list(
    supp = 0.005,
    conf = 0.20,
    minlen = 2,
    maxlen = 3
  ),
  appearance = list(
    lhs = lhs_items,
    rhs = rhs_items,
    default = "none"
  )
)

cat("Number of rules:\n")
print(length(rules_campaign_yeslhs))

# Remove redundant rules
rules_campaign_yeslhs <- rules_campaign_yeslhs[!is.redundant(rules_campaign_yeslhs)]

cat("\nTop rules:\n")
inspect(head(sort(rules_campaign_yeslhs, by = "lift"), 10))

#-----------------------
# 17. Regression Analysis
#-----------------------
cat("\n------------REGRESSION ANALYSIS-----------------")
reg_vars <- c("Age", "Education", "Marital_Status", "IncomeImp",
              "Kidhome", "Teenhome", "Recency",
              "NumWebVisitsMonth", "Complain", "TotalPurchases")
# Data Preparation
reg_train <- cbind(train_data_std[,reg_vars], pca_3)

reg_test <- cbind(test_data[,reg_vars], test_pca_3)


# Full regression model
reg_model_full <- lm(TotalPurchases ~ ., data = reg_train)

cat("\nFull regression model fitted successfully.\n")
cat("\nRegression model summary:\n")
print(summary(reg_model_full))

# Optional stepwise refinement for a simpler model
cat("\nApplying stepwise variable selection to simplify the regression model...\n")
reg_model_step <- step(reg_model_full, direction = "both", trace = 0)

cat("Stepwise regression model completed.\n")
cat("\nStepwise regression model summary:\n")
print(summary(reg_model_step))

plot(reg_model_step, ask = FALSE)

# Predictions on test data
reg_pred <- predict(reg_model_step, newdata = reg_test)

# Evaluate regression performance
rmse_val <- sqrt(mean((reg_test$TotalPurchases - reg_pred)^2))
mae_val <- mean(abs(reg_test$TotalPurchases - reg_pred))
cor(reg_test$TotalPurchases,reg_pred)

reg_model_clean <- lm(
  TotalPurchases ~ 
    IncomeImp +
    Age +
    Kidhome +
    Teenhome +
    NumWebVisitsMonth,
  data = train_data
)

summary(reg_model_clean)

reg_pred_clean <- predict(reg_model_clean, newdata = reg_test)

# RMSE
rmse_clean <- sqrt(mean((reg_test$TotalPurchases - reg_pred_clean)^2))

# MAE
mae_clean <- mean(abs(reg_test$TotalPurchases - reg_pred_clean))

# Correlation
cor_clean <- cor(reg_test$TotalPurchases, reg_pred_clean)

# R-squared (test)
r2_clean <- cor_clean^2

cat("Test Performance (Clean Model):\n")
cat("RMSE:", rmse_clean, "\n")
cat("MAE :", mae_clean, "\n")
cat("Correlation:", cor_clean, "\n")
cat("R-squared:", r2_clean, "\n")

#-----------------------------
# 18. Classification Model
#-----------------------------
cat("\n------------CLASSIFICATION MODEL-----------------")
class_train <- cbind(train_data[, c("Age", "Education", "Marital_Status", "IncomeImp",
                              "Kidhome", "Teenhome", "Recency", "NumDealsPurchases",
                              "NumWebPurchases", "NumCatalogPurchases", "NumStorePurchases",
                              "NumWebVisitsMonth", "Complain", "AcceptedAny")], pca_3)
class_test <- cbind(test_data[, c("Age", "Education", "Marital_Status", "IncomeImp",
                                  "Kidhome", "Teenhome", "Recency", "NumDealsPurchases",
                                  "NumWebPurchases", "NumCatalogPurchases", "NumStorePurchases",
                                  "NumWebVisitsMonth", "Complain", "AcceptedAny")], test_pca_3)
# Convert to character first
class_train$Marital_Status <- as.character(class_train$Marital_Status)
class_test$Marital_Status  <- as.character(class_test$Marital_Status)

# Combine rare categories
rare_marital <- c("YOLO", "Absurd", "Alone")

class_train$Marital_Status[class_train$Marital_Status %in% rare_marital] <- "Other"
class_test$Marital_Status[class_test$Marital_Status %in% rare_marital] <- "Other"

# Convert back to factor
class_train$Marital_Status <- factor(class_train$Marital_Status)
class_test$Marital_Status  <- factor(class_test$Marital_Status,
                                    levels = levels(class_train$Marital_Status))
table(class_train$AcceptedAny)
prop.table(table(class_train$AcceptedAny))
class_train$AcceptedAny <- factor(
  class_train$AcceptedAny,
  levels = c(0,1),
  labels = c("No","Yes")
)

class_test$AcceptedAny <- factor(
  class_test$AcceptedAny,
  levels = c(0,1),
  labels = c("No","Yes")
)
set.seed(2026)

library(ROSE)
train_balanced <- ROSE(
  AcceptedAny ~ .,
  data = class_train
)$data

table(train_balanced$AcceptedAny)
prop.table(table(train_balanced$AcceptedAny))



#-----------------Logistic Regression--------------
cat("\n-----------------Logistic Regression--------------\n")
model_glm <- glm(
  AcceptedAny~ .,
  data = train_balanced,
  family = "binomial"
)
print(summary(model_glm))


prob_glm <- predict(model_glm, newdata = class_test, type = "response")

pred_glm <- ifelse(prob_glm > 0.5, "Yes", "No")
pred_glm <- factor(pred_glm, levels = c("No", "Yes"))

cat("\nConfusion Matrix - Logistic Regression\n")
print(confusionMatrix(
  pred_glm,
  class_test$AcceptedAny,
  positive = "Yes"
))

pred_obj_glm <- prediction(prob_glm, class_test$AcceptedAny)
auc_glm <- performance(pred_obj_glm, "auc")@y.values[[1]]

cat("GLM AUC:", auc_glm, "\n")
perf_roc_glm <- performance(pred_obj_glm, "tpr", "fpr")

# Plot ROC
plot(
  perf_roc_glm,
  main = "ROC Curve - Logistic Regression",
  lwd = 2
)
abline(a = 0, b = 1, lty = 2)


#----------Decision Tree Model -----------------
cat("\n-----------------Decision Tree Model--------------\n")

set.seed(2026)
tree_model <- rpart(
  AcceptedAny ~ .,
  data = train_balanced,
  method = "class"
)

print(tree_model)

printcp(tree_model)
plotcp(tree_model)

rattle::fancyRpartPlot(tree_model)

prob_tree <- predict(tree_model, newdata = class_test, type = "prob")[,2]

pred_tree <- ifelse(prob_tree > 0.5, "Yes", "No")
pred_tree <- factor(pred_tree, levels = c( "Yes", "No"))

cat("\nConfusion Matrix - Decision Tree:\n")
print(confusionMatrix(
  pred_tree,
  class_test$AcceptedAny,
  positive = "Yes"
))

pred_obj_tree <- prediction(prob_tree, class_test$AcceptedAny)
auc_tree <- performance(pred_obj_tree, "auc")@y.values[[1]]

cat("Tree AUC:", auc_tree, "\n")

perf_roc_tree <- performance(pred_obj_tree, "tpr", "fpr")

plot(
  perf_roc_tree,
  main = "ROC Curve - Decision Tree",
  lwd = 2
)
abline(a = 0, b = 1, lty = 2)

#---------Random Forest Model-------------
cat("\n-----------------Random Forest Model--------------\n")

set.seed(2026)

rf_model <- randomForest(
  AcceptedAny ~ .,
  data = train_balanced,
  
)
cat("\nRandom Forest Model:\n")
summary(rf_model)
plot(rf_model)
print(rf_model)

# Variable Importance
importance(rf_model)
varImpPlot(rf_model)

# Evaluation
rf_pred_class <- predict(rf_model, class_test)
rf_pred_prob  <- predict(rf_model, class_test, type = "prob")[,2]

# Confusion Matrix
cat("\nConfusion Matrix - Random Forest:\n")
print(confusionMatrix(
  rf_pred_class, 
  class_test$AcceptedAny,
  positive = "Yes"))

# ROC and AUC
pred_obj_rf <- prediction(rf_pred_prob, class_test$AcceptedAny)
auc_rf <- performance(pred_obj_rf, "auc")@y.values[[1]]

cat("RandonForest AUC:", auc_rf, "\n")

# Plot ROC curve
perf_roc_rf <- performance(pred_obj_rf, "tpr", "fpr")
plot(perf_roc_rf,  main = "Random Forest ROC Curve", lwd = 2)
abline(a = 0, b = 1, lty = 2)

# Tuning Random forest
cat("\n-----------------Tuned Random Forest Model--------------\n")
set.seed(2026)

control <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)

rf_tuned <- train(
  AcceptedAny ~ .,
  data = train_balanced,
  method = "rf",
  metric = "ROC",
  trControl = control,
  tuneLength = 5
)

plot(rf_tuned)
cat("\nTuned Random Forest Model:\n")
print(rf_model)


# Evaluation
rft_pred_class <- predict(rf_tuned, class_test)
rft_pred_prob  <- predict(rf_tuned, class_test, type = "prob")[,2]

# Confusion Matrix
cat("\nConfusion Matrix - Tuned Random Forest:\n")
print(confusionMatrix(
  rft_pred_class, 
  class_test$AcceptedAny,
  positive = "Yes"))

# ROC and AUC
pred_obj_rft <- prediction(rft_pred_prob, class_test$AcceptedAny)
auc_rft <- performance(pred_obj_rft, "auc")@y.values[[1]]
cat("Tuned RF AUC:", auc_rft, "\n")

# Plot ROC curve
perf_roc_rft <- performance(pred_obj_rft, "tpr", "fpr")
plot(perf_roc_rft,  main = "Tuned Random Forest ROC Curve", lwd = 2)
abline(a = 0, b = 1, lty = 2)

"Notes on AI Assistance:
  Commented the parts where AI assisted for this project. AI was succesful in most cases but 
  I had to correct and debug some code in EDA summaries and in K-means elbow method. Other than
  these coding assistance, I have used AI assistance for commenting and writing Print statments
  in code."
