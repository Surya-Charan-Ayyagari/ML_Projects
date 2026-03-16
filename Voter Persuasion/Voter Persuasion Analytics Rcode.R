#Load libraries
library(dplyr)
library(caret)
library(ggplot2)

set.seed(2026)
#Load the data set
vp_data <- read.csv("./VoterPersuasion.csv")

#---------------------------
# Data Quality and Structure
#---------------------------
cat("\n---------------------------\n")
cat("\nData Quality and Structure\n")
cat("\n---------------------------\n")
# Understand the structure of the data
cat("\n Structure of the dataset\n")
str(vp_data)

# Summary of the each variable
cat("\n Summary of each column\n")
print(summary(vp_data))

# Checking NULLs in each column
cat("\n Missing values count in each column\n")
print(colSums(is.na(vp_data)))

# Checking Duplicate voter IDs
cat("\n Number of unique voter IDs\n")
print(length(unique(vp_data$VOTER_ID)))

#---------------------------
# Exploratory Data Analysis
#---------------------------
cat("\n---------------------------\n")
cat("\nExploratory Data Analysis\n")
cat("\n---------------------------\n")
# Understand the distribution of the Target variable MOVED_A
cat("\n Target variable distribution (MOVED_A)\n")
print(table(vp_data$MOVED_A))
cat("\n In percentage \n")
print(round(prop.table(table(vp_data$MOVED_A))*100,2))

# Understand the distribution of the treatment variable MESSAGE_A
cat("\n Treatment variable distribution (MESSAGE_A)\n")
print(table(vp_data$MESSAGE_A))
cat("\n In percentage \n")
print(round(prop.table(table(vp_data$MESSAGE_A))*100,2))

# Understand the effect of treatment on persuasion
cat("\nEffect of Message treatmet on persuasion\n")
vp_data$campain_msg <- ifelse(vp_data$MESSAGE_A ==1, "Received" , "Not Received")
print(vp_data %>% group_by(campain_msg) %>% 
        summarise(count = n(), Persuaded = sum(MOVED_A)) %>% 
        mutate(Persuaded_Per_Msg = Persuaded/count*100 ))

# understand the Party distribution among voters
cat("\n Party distribution\n")
vp_data$party <- ifelse(vp_data$PARTY_D == 1, "Democrat",
                        ifelse(vp_data$PARTY_R == 1, "Republican",
                               ifelse(vp_data$PARTY_I == 1, "Independent", "Other")))
print(table(vp_data$party))

cat("\n Party Affiliation and the persuaion percentage\n")
print(vp_data %>% group_by(party) %>% 
        summarise(persuaded = sum(MOVED_A),
                  message_received = sum(MESSAGE_A),
                  count = n()) %>% 
        mutate(party_per = count/sum(count)*100,persuaded_per = (persuaded/count)*100))


# Understanding the Gender Distribution
vp_data$GENDER <- as.factor(ifelse(vp_data$GENDER_F==1,'Female','Male'))
print(table(vp_data$GENDER))

# Understanding the candidate support and persuasion effect by treatment
cat("\n Candidate 1 support, persuasion and treatment\n")
print(vp_data %>% group_by(CAND1S) %>% 
        summarise(persuaded = sum(MOVED_A),
                  message_received = sum(MESSAGE_A),
                  count = n()) %>% 
        mutate(persuaded_per = (persuaded/count)*100))

cat("\n Candidate 2 support, persuasion and treatment\n")
print(vp_data %>% group_by(CAND2S) %>% 
        summarise(persuaded = sum(MOVED_A),
                  message_received = sum(MESSAGE_A),
                  count = n()) %>% 
        mutate(persuaded_per = (persuaded/count)*100))


#---------------------
# Data Visualizations
#---------------------
cat("\n---------------------------\n")
cat("\nData Visualizations\n")
cat("\n---------------------------\n")
# Age Distribution
hist(vp_data$AGE, main = "Age Distribution", xlab = "Age")

# Median Household Income Distribution
hist(vp_data$MED_HH_INC, main = "Median Household Income Distribution", xlab =  "Median Household Income")

# Gender Distribution
gender_plot <- ggplot(vp_data, aes(x = GENDER,fill = MOVED_AD))+
  geom_bar() +
  labs(title = "Distrbution of Voter's Gender and Persuasion") +
  theme_minimal()
print(gender_plot)

# Effect of Message on persuasion
message_plot <- ggplot(vp_data, aes(x = as.factor(MESSAGE_A),fill = as.factor(MOVED_AD)))+
  geom_bar() +
  labs(title = "Distrbution of Message treatment and Persuasion", x="Message Received" )+
  theme_minimal()
print(message_plot)

#Party Distribution
vp_data$party <- as.factor(vp_data$party)
party_plot <- ggplot(vp_data, aes(x = party, fill = MOVED_AD)) +
  geom_bar() +
  labs(title = "Distribution of Voters by Party",
       x = "Party Affiliation",
       y = "Number of Voters") +
  theme_minimal()
print(party_plot)


# Correlation Analysis
cor_data <- vp_data %>%
  select_if(is.numeric) %>% cor()

select_cor <- vp_data %>%select(MOVED_A, MESSAGE_A, PARTY_D, PARTY_R, PARTY_I, AGE, 
                                GENDER_F, GENDER_M, MED_HH_INC, HH_ND, HH_NR, HH_NI,
                                VG_04, VG_06, VG_08, VG_10, VG_12,POLITICALC,NL5G,NL3PR,NL5AP) %>% cor()
corrplot::corrplot(select_cor)


#------------------------------
# Preparing Data for modeling
#------------------------------
cat("\n---------------------------\n")
cat("\nPreparing Data for modeling\n")
cat("\n---------------------------\n")

# Creating a new variable 'vote_count' to get number of times a voter voted in previous elections
vp_data$vote_count <- vp_data$VG_04 + vp_data$VG_06 + vp_data$VG_08 + vp_data$VG_10 + vp_data$VG_12
cat("\nCreating a new variable 'vote_count' \n")
print(summary(vp_data$vote_count))

# Selecting the data for modeling
modeling_Voterdata <- vp_data[, c('MOVED_A','MESSAGE_A', 'AGE', 'GENDER', 'MED_HH_INC',
                                  'PARTY_D', 'PARTY_R', 'vote_count','CAND1S','CAND2S')]
cat("\nSelected columns for Modeling:\n")
print(colnames(modeling_Voterdata))

# Convert Binary variables to factor
factor_cols <- c('MOVED_A','MESSAGE_A',
                 'PARTY_D', 'PARTY_R','CAND1S','CAND2S')

modeling_Voterdata[factor_cols] <- lapply(modeling_Voterdata[factor_cols],as.factor)

#------------------------------
# Model Fitting and Evaluation
#------------------------------
cat("\n---------------------------\n")
cat("\nModel Fitting and Evaluation\n")
cat("\n---------------------------\n")

#--------- Logistic Regression Model-----------

cat("\n--------- Logistic Regression Model-----------\n")


# Split the modeling data into train (70%) and test (30%)
idx = createDataPartition(modeling_Voterdata$MOVED_A, p = 0.7, list=FALSE)

train_voterdata <- modeling_Voterdata[idx,]
test_voterdata <- modeling_Voterdata[-idx,]

# Standardize the modeling data
std_model <- preProcess(train_voterdata, method = c('center','scale'))

train_voterdata_std <- predict(std_model,train_voterdata)
test_voterdata_std <- predict(std_model,test_voterdata)

# Check the proportion of the data
cat("\nTraining data MOVED_A distribution\n")
print(round(prop.table(table(train_voterdata_std$MOVED_A))*100,2))

cat("\nTest data MOVED_A distribution\n")
print(round(prop.table(table(test_voterdata_std$MOVED_A))*100,2))

# Fit the model
cat("\nLogistic Model Fit")
model_glm <- glm(MOVED_A ~ ., data = train_voterdata_std, family = "binomial")


# Look at the model results
cat("Logistic Regression Model Summary:\n")
print(summary(model_glm))

# Make predictions on the test set
# Get probabilities (between 0 and 1)
logistic_probabilities <- predict(model_glm, 
                                  newdata = test_voterdata_std, 
                                  type = "response")

# Convert probabilities to Yes/No predictions, If probability > 0.5, predict Yes, otherwise No
logistic_predictions <- ifelse(logistic_probabilities > 0.5, "1", "0")
logistic_predictions <- factor(logistic_predictions, levels = c("1", "0"))

cat("Model Evaluation")

# Evaluate the model using a confusion matrix
logistic_cm <- confusionMatrix(logistic_predictions, 
                               test_voterdata_std$MOVED_A, 
                               positive = "1")
cat("\nLogistic Regression - Confusion Matrix:\n")
print(logistic_cm)

# Plot the ROC curve
library(pROC)
roc_score <- roc(test_voterdata_std$MOVED_A, logistic_probabilities)
plot(roc_score, main="ROC Curve for Logistic Regression Model", print.auc = TRUE,)

logistic_auc <- auc(roc_score)

cat("\nLogistic Regression AUC:", round(logistic_auc, 4), "\n")
cat("(AUC ranges from 0.5 to 1.0; higher is better)\n")

# Show the most important coefficients
coef_table <- as.data.frame(summary(model_glm)$coefficients)

coef_table <- rename(coef_table,  p_value = "Pr(>|z|)")
positive_significant <- coef_table %>%
  filter(
    Estimate > 0,
    p_value < 0.01,
    rownames(.) != "(Intercept)"
  ) %>%
  arrange(desc(Estimate)) %>%
  select(Estimate) %>%
  head(5)

negative_significant <- coef_table %>%
  filter(
    Estimate < 0,
    p_value < 0.05,
    rownames(.) != "(Intercept)"
  ) %>%
  arrange(Estimate) %>%
  select(Estimate) %>%
  head(5)
cat("\nTop 5 Positive Effects (increase persuasion):\n")
print(positive_significant)
cat("\nTop 5 Negative Effects (decrease persuasion):\n")
print(negative_significant)

# Fit the logistic model with interaction terms
cat("\nFit the logistic model with interaction terms\n")
model_glm_intr <- glm(MOVED_A ~ . + MESSAGE_A:PARTY_R + MESSAGE_A:CAND2S, train_voterdata_std,family = 'binomial')
print(summary(model_glm_intr))

# Make predictions on the test set
# Get probabilities (between 0 and 1)
logistic_probabilities_intr <- predict(model_glm_intr, 
                                  newdata = test_voterdata_std, 
                                  type = "response")

# Convert probabilities to Yes/No predictions, If probability > 0.5, predict Yes, otherwise No
logistic_predictions_intr <- ifelse(logistic_probabilities_intr > 0.5, "1", "0")
logistic_predictions_intr <- factor(logistic_predictions_intr, levels = c("1", "0"))

cat("Model Evaluation")

# Evaluate the model using a confusion matrix
logistic_cm_intr <- confusionMatrix(logistic_predictions_intr, 
                               test_voterdata_std$MOVED_A, 
                               positive = "1")
cat("\nLogistic Regression w. Interacton Terms - Confusion Matrix:\n")
print(logistic_cm_intr)

# Plot the ROC curve
library(pROC)
roc_score_intr <- roc(test_voterdata_std$MOVED_A, logistic_probabilities_intr)
plot(roc_score_intr, main="ROC Curve for Logistic Regression Model w. Interactions", print.auc = TRUE,)

logistic_auc_intr <- auc(roc_score_intr)

cat("\nLogistic Regression w. InteractionsAUC:", round(logistic_auc_intr, 4), "\n")

# -----------Decision Tree Model--------------
cat("\n-----------Decision Tree Model--------------\n")
library(rpart)
library(rpart.plot)
set.seed(2026)


# Check the proportion of the train and test data
cat("\nCheck the proportion of the train and test data\n")
cat("\nTraining data MOVED_A distribution\n")
print(round(prop.table(table(train_voterdata$MOVED_A))*100,2))

cat("\nTest data MOVED_A distribution\n")
print(round(prop.table(table(test_voterdata$MOVED_A))*100,2))
print(table(test_voterdata$MOVED_A))

# Fit the model and print
cat("\n Build the Decision tree using training data")
model_dt <- rpart(MOVED_A ~ ., data = train_voterdata)
cat("\nDecision Tree Output\n")
print(model_dt)

# Plot the tree
library(rattle)
fancyRpartPlot(model_dt, main = "Decision Tree Plot")


# Predict using the model on test data set
cat("\nPredict and evaulate the decision tree using the test data\n")
model_dt_pred <- predict(model_dt, test_voterdata, type = 'class')

# Decision Tree Confusion Matrix
cat("\nDecision Tree - Confusion Matrix\n")
dt_cm <- confusionMatrix(model_dt_pred, 
                         test_voterdata$MOVED_A, 
                         positive ='1')
print(dt_cm)
cat("\n The Decision tree seems overfitted as it has high accuracy.\n")

# Print the complexity parameter values of the model to prune the model
par(mfrow = c(1, 1))
printcp(model_dt)
plotcp(model_dt)

cat("\nThe best cp value is 0.01 which is the default value. So pruning based on best cp gives the same\n")

cat("\nSo, lets fit the model using the control parameters.\n")
cat("\nSet the cp value to 0.0137 as per 1-SE rule,\nIncrease the cross validation to 20 and\nminbucket to 100 because the default model has very small bucket size \n")

# Fit the model again using control parameters
control = rpart.control(cp=0.0137, xval = 20, minbucket = 100)
model_ctrl_dt <- rpart(MOVED_A ~ ., data = train_voterdata, control = control)
cat("\nPruned Decision Tree\n")
print(model_ctrl_dt)
fancyRpartPlot(model_ctrl_dt, main = "Pruned Decision Tree Plot")

cat("\nPruned Decision Tree - Confusion Matrix\n")
model_ctrl_dt_pred <- predict(model_ctrl_dt, test_voterdata, type = 'class')
ctrl_dt_cm <- confusionMatrix(model_ctrl_dt_pred,
                              test_voterdata$MOVED_A, 
                              positive ='1')
print(ctrl_dt_cm)

cat("\nRules of the tree which can be used in Campaign outreach planning:\n")
print(rpart.rules(model_ctrl_dt))


#------------------------------
# Model Comparison
#------------------------------
comparison <- data.frame(
  Model = c("Logistic Regression",
            "Logistic Regression (Interaction)",
            "Decision Tree (Unpruned)",
            "Decision Tree (Pruned)"),
  
  Accuracy = c(logistic_cm$overall["Accuracy"],
               logistic_cm_intr$overall["Accuracy"],
               dt_cm$overall["Accuracy"],
               ctrl_dt_cm$overall["Accuracy"]),
  
  Sensitivity = c(logistic_cm$byClass["Sensitivity"],
                  logistic_cm_intr$byClass["Sensitivity"],
                  dt_cm$byClass["Sensitivity"],
                  ctrl_dt_cm$byClass["Sensitivity"]),
  
  Specificity = c(logistic_cm$byClass["Specificity"],
                  logistic_cm_intr$byClass["Specificity"],
                  dt_cm$byClass["Specificity"],
                  ctrl_dt_cm$byClass["Specificity"]))

print(tibble(comparison))
