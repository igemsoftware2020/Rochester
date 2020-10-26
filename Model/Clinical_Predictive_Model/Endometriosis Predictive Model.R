library(tidyverse)
library(tidyr)
library(ggplot2)
library(randomForest)
library(hablar)



#Changing columns to factors (categorical) or numerics (continuous) 
Endo_RF_Data <- BalancedDataSet %>%
  convert(num(age, age_menarche, Menstrual_Cycle_length, Period_length, age_1st_child,Age_symptoms, bmi, exercise_week),
          fct(Civil_Status, Education,cycle_regularity,Dysmenorrhea:miscarriages_n, OCP_before:Endometriosis_DX, Family_Hx:treatment_infertility_Y_N, allerg:cardiovascular))
str(Endo_RF_Data)

#split data into train and validation sets
#Train : Validation = 70 : 30
set.seed(100) #pseudo number generator to randomize the subject that go into validation versus training

#Random sample the dataframe where 70% of rows (subjects) will be subset
train <- sample(nrow(Endo_RF_Data), 0.7*nrow(Endo_RF_Data), replace = FALSE)
#new data frame with 70% of the rows from Endo_RF_Data
trainSet <- Endo_RF_Data[train,] 
#new data frame with the remaining 30% from Endo_RF_Data
valSet <- Endo_RF_Data[-train,]

#line 28 is the model
#EndoModel with mtry = 17 meaning 17 variables are randomly sampled at each split
EndoModel <- randomForest(Endometriosis_DX ~ ., data = trainSet, ntree = 500, mtry = 17, importance = TRUE, na.action = na.exclude)
EndoModel #view model

#line 33 runs the model on input data. In this case, the data is called "valSet"
#prediction/classification using EndoModel on validation set
predVal <- predict(EndoModel, valSet, type = "class")
predVal #view results

#creates confusion matrix to determine false pos and false neg
table(predVal, valSet$Endometriosis_DX)

#calculates mean accuracy of EndoModel when run on validation data set
mean(predVal == valSet$Endometriosis_DX)

#calculating the mean decrease accuracy (MDA) for each variables
imp <- importance(EndoModel, type=1) 
imp #view MDA for each predictor variable

#graphing the MDA of the 25 most important predictors to visualize importance
varImpPlot(EndoModel, sort=TRUE, n.var=min(25, nrow(EndoModel$importance)),
           type=1)



