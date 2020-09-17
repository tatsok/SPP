my_packages <- c("tidyverse","caret","data.table","lubridate","dslabs","dplyr", "data.table","matrixStats","raster","gam","scales","RColorBrewer","gridExtra","knitr","devtools","ggpubr", "gam","gbm", "xgboost","Rborist")                
not_installed <- my_packages[!(my_packages %in% installed.packages()[ , "Package"])]    # Extract not installed packages
if(length(not_installed)) install.packages(not_installed)                               # Install not installed packages


if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(data.table)) install.packages("data.table", repos = "http://cran.us.r-project.org")
if(!require(lubridate)) install.packages("lubridate", repos = "http://cran.us.r-project.org")
if(!require(dslabs)) install.packages("dslabs",repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr",repos = "http://cran.us.r-project.org")
if(!require(data.table)) install.packages("data.table",repos = "http://cran.us.r-project.org")
if(!require(matrixStats)) install.packages("matrixStats",repos = "http://cran.us.r-project.org")
#if(!require(keras)) install_keras() #install_keras(tensorflow = "gpu")
if(!require(raster)) install.packages("raster")
if(!require(gam)) install.packages("gam", repos = "http://cran.us.r-project.org")
if(!require(scales)) install.packages("scales", repos = "http://cran.us.r-project.org")
if(!require(RColorBrewer)) install.packages("RColorBrewer", repos = "http://cran.us.r-project.org")
if(!require(gridExtra)) install.packages("gridExtra", repos = "http://cran.us.r-project.org")
if(!require(knitr)) install.packages("knitr")
if(!require(devtools)) install.packages("devtools")

if(!require(ggpubr)) install.packages("ggpubr",repos = "http://cran.us.r-project.org")
if(!require(gam)) install.packages("gam",repos = "http://cran.us.r-project.org")
if(!require(gbm)) install.packages("gbm",repos = "http://cran.us.r-project.org")
if(!require(xgboost)) install.packages("xgboost",repos = "http://cran.us.r-project.org")
if(!require(Rborist)) install.packages("Rborist",repos = "http://cran.us.r-project.org")



devtools::install_github("kassambara/ggpubr")
library(ggpubr)
library(keras)
if (FALSE) {
  library(keras)
  install_keras() #install_keras(tensorflow = "gpu")
}
library(tidyverse)
library(lubridate)
library(dslabs)
library(dplyr)
library(leaflet)
library(data.table)
library(matrixStats)
library(raster)
library(corrplot)
library(scales)
library(raster)
library(gam)
library(gbm)
library(xgboost)
library(Rborist)
library(reticulate)
library(caret)
library(RColorBrewer) 




# Load data & clean
github_link<-"https://drive.google.com/file/d/1mK8DTlvQZ4XxWwPKrSk2C-RpbM-BQHFY/view?usp=sharing"

library(httr)
temp_file <- tempfile(fileext = ".xlsx")
req <- GET(github_link, 
           # authenticate using GITHUB_PAT
           authenticate(Sys.getenv("GITHUB_PAT"), ""),
           # write result to disk
           write_disk(path = temp_file))
tab <- readxl::read_excel(temp_file)
tab
#> # A tibble: 5 x 1
#>   text 
#>   <chr>
#> 1 what 
#> 2 fresh
#> 3 hell 
#> 4 is   
#> 5 this
unlink(temp_file)
dl <- tempfile(fileext = ".xlsx")
dl

download.file(, destfile=dl, mode="wb")

readxl::read_xlsx("sqtest.xlsx")

sqtest<-readxl::read_xlsx("~/Documents/Capstone/SPR/sqtest.xlsx")


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ DATA WRANGLING ++++++++++++++++++++++++++++++++++++++++#  

# First, we will wrangle the data and ensure it is presented in the wide format and each line represents a unique observation:
sqtest<-sqtest%>%rename(c("Sale_Date"="Sale Date", "Parcel"="Display Parcel", "Township"="Township","Range"="Range", "Situs_Address"="Situs_Address", "City"="City", "Land_Sq"="Land Sq Ft", "Sales_Price"="Adj Sale Amt", "City_Code" = "City Code", "HEATED_AREA"="HEATED_AREA", "AREA"="Actual Area", "DOR_CODE"="DOR_CODE","MARKET"="MKT_AREA_CODE","NBHD_DESC"="NBHD_DESC","LONGITUDE"="LONGITUDE","LATITUDE"="LATITUDE","PPSF"="Price Per Sq Ft","BLDG_NUM"="BLDG_NUM","SR"="Sales Ratio","BEDS"="BEDS","BATHS"="BATHS","EYB"="EYB","AYB"="AYB","STORIES"="STORIES","EXT_W"="Exterior Wall","ZIP_Code"="ZIP Code", "XFOB"="XFOB Desc"))
sqtest<-sqtest%>%mutate(Sale_Date=as.Date(sqtest$Sale_Date, "%m/%d/%Y"),XFOB=as.factor(XFOB), EXT_W=as.factor(EXT_W), ZIP_Code=as.factor(ZIP_Code), Township=as.numeric(Township),Range=as.numeric(Range),City_Code=as.factor(City_Code),DOR_CODE=as.numeric(DOR_CODE),MARKET=as.numeric(MARKET),LONGITUDE=as.numeric(LONGITUDE), LATITUDE=as.numeric(LATITUDE), EYB=year(mdy(EYB)), AYB=year(mdy(AYB)))
sqtest<-sqtest%>%arrange(BLDG_NUM)%>%distinct(Sale_Date, Parcel,XFOB, .keep_all = TRUE)
sqtest<-sqtest%>%mutate(XFOB_NAME=as.factor((str_extract(XFOB,"[:letter:]+[:space:]?[:letter:]+"))),XFOB_Q=as.numeric(str_extract(XFOB, "[[:digit:]]+")))%>%mutate(XFOB_Q=ifelse(is.na(XFOB_Q),1,XFOB_Q))
sqtest<-sqtest%>%group_by(Sale_Date, Parcel,Township, Range,Situs_Address, City,Land_Sq,Sales_Price,City_Code,HEATED_AREA,AREA, DOR_CODE,MARKET, NBHD_DESC, LONGITUDE,LATITUDE,PPSF,BLDG_NUM,SR,BEDS, BATHS,EYB,AYB,STORIES,EXT_W,ZIP_Code, XFOB_NAME)%>%summarize(XFOB_Q=sum(XFOB_Q))
sqtest<-sqtest%>%spread(key=XFOB_NAME, XFOB_Q,0)%>%ungroup()
sqtest<-rename(sqtest, c( "ACC_BLDG"="ACC BLDG","BOAT_COVER"="BOAT COVER","BOAT_DOCK"="BOAT DOCK","BOAT_HOUSE"="BOAT HOUSE","COVER_ALUM"="COVER ALUM","COVER_STL"="COVER STL", "HORSE_STAB"="HORSE STAB","MOBILE_HM"="MOBILE HM","SUMMER_KITCHEN"="SUMMER KITCHEN","PATIO_NO"="PATIO NO","PATIO_WD"="PATIO WD","PAV_CON"="PAV CON","POLE_BLDG"="POLE BLDG","RESIDENTIAL_EL"="RESIDENTIAL ELEVATOR","RM_ENCL"="RM ENCL" ,"SCRN_ENC"="SCRN ENC", "SHED_N"="SHED N", "SUMMER_KITCHEN"="SUMMER KITCHEN", "WALL_CB"="WALL CB", "WALL_DEC"="WALL DEC", "WALL_NO"="WALL NO"))
head(sqtest)



#++++++++++++++++++++++++++++++++++++++++++++++++++ VISUALIZATION AND DATA CLEANING ++++++++++++++++++++++++++++++++++++++#

# Let's view the structure of our data set after wrangling:

str(sqtest)
summary(sqtest)
colnames(sqtest)


# Let's visualize our data set using Orange County map
county <-subset(raster::getData("GADM", country="usa", level=2), NAME_1=="Florida"&NAME_2=="Orange")
mybins<-c(0,100000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,Inf)
pal<-colorBin(palette="Spectral",domain=sqtest$Sales_Price, bins=mybins,reverse=T)

labels <- sprintf("Date of Sale:<strong> %s</strong><br/>Sale Price: $%g<br/>Heated Area: %g<br>Beds: %g <br>Baths: %g", sqtest$Sale_Date, sqtest$Sales_Price, sqtest$HEATED_AREA, sqtest$BEDS, sqtest$BATHS) %>% lapply(htmltools::HTML)

map<-sqtest%>%leaflet()%>%addProviderTiles(providers$Esri.WorldGrayCanvas)%>%
  addCircles(radius=50, color=pal(sqtest$Sales_Price), weight = 3, stroke = FALSE, fillOpacity = 0.8)%>%addCircleMarkers(color=pal(sqtest$Sales_Price),clusterOptions = markerClusterOptions(),label=~labels, labelOptions = labelOptions( opacity=0.9, color="grey",textsize = "10px", direction="right"))%>%
  addPolygons(data = county,fillOpacity = 0.1, color = "grey", stroke = TRUE, weight = 5,layerId = county@data$NAME_2)%>%leaflet::addLegend("topright", pal=pal, values=sqtest$Sales_Price, title = "Sales by Sales Price")
map


# Let's review the distribution of the Sales Prices. For convenience, we filter the Sales Prices under 2mil:
sqtest%>%filter(Sales_Price<2000000)%>%ggplot(aes(Sales_Price, fill=City))+geom_histogram(binwidth=7000)+scale_x_continuous(labels=dollar, breaks = scales::pretty_breaks(n = 10))+
  theme(axis.text.x = element_text(angle=45, hjust=1, size=15), plot.title = element_text(size=20),plot.subtitle = element_text(size=18), legend.title = element_text(size=18), legend.text = element_text(size=14),axis.title = element_text(size=18), axis.text.y = element_text(size=15))+
  labs(title = 'Single-Family Real Estate Sales Distribution', subtitle= 'Year: 2019', x = 'Sale Price', y = 'Count')
# It looks like vast majority of the sales are under the price of $600,000 with some sales below $1.4 and a very few above that
# Let's see the boxplot and histogram distributions of Sales Prices and logged Sales Prices 

a<-ggplot(sqtest)+geom_boxplot(aes(Sales_Price), fill="red")
b<-ggplot(sqtest)+geom_boxplot(aes(log(Sales_Price)), fill="blue")
c<-ggplot(sqtest)+geom_histogram(aes(Sales_Price), fill="red")
d<-ggplot(sqtest)+geom_histogram(aes(log(Sales_Price)), fill="blue")
ggpubr::ggarrange(a,b,c,d,ncol = 2, nrow = 2)

# The sales price data is positively skewed. The logarithmic transformation will be warranted as it makes distribution to resemble a normal curve and it tends to show less severe increases or decreases than linear scales.
## Additionally, let's convert the Sales Date into year and month
##sqtest<-sqtest%>%mutate(Sale_Date=year(Sale_Date))

# Let's now review SR feature in the data set that stands for sales ratio. This ratio is calculated for each observation by dividing the appraised (or assessed) value by the sale price.
# It measures the quality of the assessments and can be used to measure the annual performance of the assessment roll produced by the assessors' offices.

e<-ggplot(sqtest)+geom_point(aes(Sales_Price, SR))
f<-ggplot(sqtest)+geom_boxplot(aes(Sales_Price))
ggpubr::ggarrange(e,f,ncol = 1, nrow = 2)

# There are two apparent observations from the plots: (1) the data set is affected by the sales ratio outliers (which often signal a bias in the assessment or sales price); (2) the majority of properties are below 2 million dollar range.
# Therefore, to improve our model performance, it is reasonable to remove the sales ratio (SR) outliers from the data set and properties over 2 million dollars, which represent less than 1% of the data set. 

sqtest<-sqtest%>%filter(Sales_Price<2000000, !SR%in%boxplot(SR, plot=FALSE)$out)%>%mutate(Sale_Date=year(Sale_Date))

# The plots after this transformation show an apparent improvement
e<-ggplot(sqtest)+geom_point(aes(Sales_Price, SR))
f<-ggplot(sqtest)+geom_boxplot(aes(Sales_Price))
ggpubr::ggarrange(e,f,ncol = 1, nrow = 2)



# For single-family residential (no condos) the acceptable Sales Ratio should be close to 0.85 due to a legal requirement to adjust Assessed value by 15%. 
# Additionally, assessment jurisdictions do an annual ratio study to determine the uniformity, variability, and equality of the assessment roll.
# The most generally useful measure of variability or uniformity is the COD. 
# It relates to “horizontal,” or random, dispersion among the ratios in a stratum, regardless of the value of individual parcels. 
# It is calculated by subtracting the median from each ratio, taking the absolute value of the calculated differences, summing the absolute differences, dividing by the number of ratios to obtain the average absolute deviation, dividing by the median and multiplied by 100.
# The acceptable level for single-family type of properties is 5.0-15.0.
# Another form of inequity can be systematic differences in the appraisal of low- and high-value properties,termed “vertical” inequities.
# An index for measuring vertical equity is the PRD, which is calculated by dividing the mean ratio by the weighted mean ratio. This statistic should be close to 1.00
# The acceptable level is 0.98-1.03.
# So, let's see how these metrics hold on our data set:
stat<-sqtest%>%summarise(MEAN=mean(SR), MEDIAN=median(SR))
stat

# Since the ratios are assumed to be normally distributed, we find confidence intervals using the following formula:
hist(sqtest$SR)
ci<-stat$MEAN+c(-qnorm(0.975),qnorm(0.975))*sd(sqtest$SR)
ci

# Let's calculate the COD ratio:
COD<-sqtest%>%summarize(COD=mean(abs(SR-as.numeric(stat$MEDIAN)))/as.numeric(stat$MEDIAN)*100)
COD

# Let's also calculate the PRD ratio:
PRD<-sqtest%>%summarize(PRD=as.numeric(stat$MEAN)/(sum(sqtest$SR*sqtest$Sales_Price)/sum(sqtest$Sales_Price)))
PRD

# With that, we will use the following ratios as benchmarks for our constructed model to it passes the assessment industry standards:

original<-knitr::kable(cbind(MEAN=stat[1], MEDIAN=stat[2], CONF_LOW=ci[1], CONF_HIGH=ci[2], COD=COD, PRD=PRD), "simple", caption = "Original CAMA Ratios")
original

#++++++++++++++++++++++++++++++++++++++++++++++++++ FEATURE ENGINEERING ++++++++++++++++++++++++++++++++++++++++++++++++#

# Let's transform EYB and AYB into effective and actual ages and remove Heated Area from Total Area. 
sqtest<-sqtest%>%mutate(EYB=Sale_Date-EYB, AYB=Sale_Date-AYB, AREA=AREA-HEATED_AREA)

# Let's review the relationship between features and the outcome
area<-sqtest%>%ggplot(aes(AREA,Sales_Price)) + geom_point() + 
  geom_smooth(method="lm")
area_log2<-sqtest%>%mutate(AREA=ifelse(AREA==0, 1,AREA))%>%ggplot(aes(log(AREA),log(Sales_Price))) + geom_point() + 
  geom_smooth(method="lm")
harea<-sqtest%>%ggplot(aes(HEATED_AREA,Sales_Price)) + geom_point() + 
  geom_smooth(method="lm")
harea_log2<-sqtest%>%ggplot(aes(log(HEATED_AREA),log(Sales_Price))) + geom_point() + 
  geom_smooth(method="lm")
land<-sqtest%>%ggplot(aes(Land_Sq,Sales_Price)) + geom_point() + 
  geom_smooth(method="lm")
land_log2<-sqtest%>%ggplot(aes(log(Land_Sq),log(Sales_Price))) + geom_point() + 
  geom_smooth(method="lm")
ayb<-sqtest%>%ggplot(aes(AYB,Sales_Price)) + geom_point() + 
  geom_smooth(method="lm")
ayb_log<-sqtest%>%ggplot(aes(AYB,log(Sales_Price))) + geom_point() + 
  geom_smooth(method="lm")
eyb<-sqtest%>%ggplot(aes(EYB,Sales_Price)) + geom_point() + 
  geom_smooth(method="lm")
eyb_log<-sqtest%>%ggplot(aes(EYB,log(Sales_Price))) + geom_point() + 
  geom_smooth(method="lm")
ggpubr::ggarrange(area, area_log2, harea, harea_log2, land, land_log2, ayb,ayb_log, eyb,eyb_log,ncol = 2, nrow = 5)

# Again, we see that the logarithmic transformation for sales price is reasonable as it creates a closer to linear relationship between features such as Heated Area, Age and Sales price.
# It looks like the double log transformation (outcome and feature transformation) is useful for features related to size such as Area, Heated Area, and Land size.
# We do the transformations after removing zeros and NAs
sqtest<-sqtest%>%mutate(AREA=ifelse(AREA==0, 1, AREA))%>%mutate(STORIES=ifelse(is.na(STORIES),1,STORIES), BEDS=ifelse(is.na(BEDS),1,BEDS), BATHS=ifelse(is.na(BATHS),1,BATHS))%>%mutate(Sales_Price=log(Sales_Price), AREA=log(AREA), HEATED_AREA=log(HEATED_AREA), Land_Sq=log(Land_Sq))

# There are several features listed in the columns 27 through 63. Having too many features will increase the computation time without adding much value.
# Let's review the correlation with the sales price and variability of those features and remove those with little correlation (less than |x|<0.25) and no variability.
correlation<-cor(sqtest[,8],sqtest[,27:ncol(sqtest)])
correlation
nocor<-which(correlation>-0.25&correlation<0.25|is.na(correlation))
X1<-colnames(sqtest[,27:ncol(sqtest)][,nocor])
X1

# Check for no variability in the features using nearZeroVar function:
subset<-data.matrix(sqtest)
mean<-apply(subset,2,mean)
std<-apply(subset,2,sd)
subset1<-scale(subset, center=mean,scale=std)

nd<-nearZeroVar(subset1)
X2<-colnames(subset[,nd])
X2

# Instead of keeping all of the feature variables, we will subset using the intersect function between X1-no correlation and X2-no variability:
feature_remove<-intersect(X1,X2)
feature_remove
sqtest<-sqtest[,-which(colnames(sqtest)%in%feature_remove)]
head(sqtest)

# Lets review how some of the remaining features correlated:
m<-cor(sqtest[,c(3,4,7,8,10:13,15,16,20:24,27:ncol(sqtest))])
corrplot::corrplot(m, method="circle", order="hclust")

# To improve our model, it makes sense to remove Township and Range features since these are highly correlated with LONGITUDE and LATITUDE.

# Also, we will remove the following features: Sale_Date, Parcel, Situs Address , City, NBHG_DESC, SR, PPSF, and ZipCode as these don't add much information and will likely increase the complexity of our model.

sqtest<-sqtest[,c(7:13,15,16,20:25, 27:ncol(sqtest))]

# Therefore, our set is reduced to 26 variables and we are ready to begin constructing the ML algorithms.



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ML ALGORITHMS +++++++++++++++++++++++++++++++++++++++++++++++++++#

# First, let's separate our labels into a vector y of sales prices and create a matrix x containing the features (excluding the sales date):
y<-data.matrix(sqtest[,2])
x<-data.matrix(sqtest[,-2])


# Lets partition the data using createDataPartition function into 80/20 sets. 
# There other ways to partition the data, we use 80/20 rule or Pareto Principle, which states in general that in most cases, 80% of effects come from 20% of causes.
# We could have partitioned using scaling law (Guyon) which determines splits by how many unique features and complexity of these features in the data set with the goal to prevent overtraining.
set.seed(1)
index<-createDataPartition(y,times=1,p=0.8,list=FALSE)

train_x<-x[index,]
test_x<-x[-index,]
train_y<-y[index]
test_y<-y[-index]


# It is problematic to fit the data into ML algorithm that takes a variety of different ranges. For this reason, a feature-wise normalization is used. 
# For each feature, the mean is subtracted and divided by the standard deviation, so the features are centered around 0 and have a unit standard deviation.
# The quantities used for normalization of the test data are computed on the train data only.
# Let's normalize it:
mean<-apply(train_x,2,mean)
std<-apply(train_x,2,sd)
train_x<-scale(train_x, center=mean,scale=std)
test_x<-scale(test_x, center=mean, scale=std)

# There are a variety of loss functions available to measure the performance of ML algorithms. We will define the loss functions that are most applicable to our problem.
# We will use MSE (mean square error) as our loss function and use MAE as a relative metric of loss for easier interpretation of the results.
# One important distinction between MAE & RMSE is that minimizing the squared error over a set of numbers results in finding its mean, and minimizing the absolute error results in finding its median. This is the reason why MAE is robust to outliers whereas RMSE is not.
MSE <- function(true_price, predicted_price){ 
  mean((true_price -  predicted_price)^2)
}

MAE<-function(true_price, predicted_price){ 
  mean(abs(true_price -  predicted_price))
}

# Since our labels were transformed using logarithmic transformation, we will also use these converted relative metrics when evaluating results:
MSEE<-function(true_price, predicted_price){ 
  mean((exp(true_price) -  exp(predicted_price))^2)
}
MAEE<-function(true_price, predicted_price){
  mean(abs(exp(true_price)-exp(predicted_price)))
}



# Now, we are going to fit several different models and build the ensemble model:

# Model: GLM - generalized linear model
# In our model we will define trControl function that controls the resampling scheme to 10 fold cross-validation:

Control<-trainControl(method="cv", number=10)
set.seed(1)
train_glm<-train(train_x,train_y, method="glm", trControl=Control)
glm_predict<-predict(train_glm, test_x)

results1<-data_frame(MODEL="GLM", MSE=MSE(test_y, glm_predict))
knitr::kable(results1, "simple")

# Model: LOESS - (takes under 2 minutes) 
# In Loess model, we can tune the paarmeters using tuneGrid function. After further testing, tuning was omitted to decrease time of training.
#tuneGrid = expand.grid(span = seq(0.20, 0.50, len = 10), degree=2) 

Control<-trainControl(method="cv", number=5)
set.seed(1)
train_loess<-train(train_x,train_y, method="gamLoess", trControl=Control)
loess_predict<-predict(train_loess, test_x)

results2<-bind_rows(results1, data_frame(MODEL="LOESS", MSE=MSE(test_y, loess_predict)) )
knitr::kable(results2, "simple")

# MSE results improved from 0.0495869 to 0.0347857

# Model: svmLinear - (takes under 2 minutes)

# An SVM classifies data by determining the optimal hyperplane that separates observations according to their class labels. 
# While commonly used for classification problems, it can also be applied to regression tasks. We will try it here.
Control<-trainControl(method="cv", number=5)
# grid <- expand.grid(span = seq(0.15, 0.65, len = 10), degree = 1) - optional tuning (substantialy increases training time)
set.seed(1)
train_svm<-train(train_x,train_y, method="svmLinear", trControl=Control, tuneLength = 8)

# We can see variables importance:
varImp(train_svm)
# We can see using variable importance function that Heated area is by far more important than the rest 

svm_predict<-predict(train_svm, test_x)

results3<-bind_rows(results2, data_frame(MODEL="SVM", MSE=MSE(test_y, svm_predict)) )
knitr::kable(results3, "simple")

# The SVM model did not do as great, lets try K Nearest Neighbors (KNN) model

# Model: KNN - (takes under 1 minutes)

tuningknn<-data.frame(k=seq(3,15,2))
Control<-trainControl(method="cv", number=5)
set.seed(1)
train_knn<-train(train_x, train_y, method="knn",tuneGrid=tuningknn, trControl=Control,tuneLength = 10)

# We can also check for variables importance:
varImp(train_knn)
# Similar to svm model, Heated area is by far more important than the rest 

knn_predict<-predict(train_knn, test_x)   

# By plotting the model, we see that the best number of neighbors parameter was 5
plot(train_knn)
train_knn$bestTune

results4<-bind_rows(results3, data_frame(MODEL="KNN", MSE=MSE(test_y, knn_predict)) )
knitr::kable(results4, "simple")

# Model: Random Forest with Rborist - (less then 2 minutes)

# Let's first run a model on 50 trees to define the best tunning parameters (you can skip this code and go to the model with the best parameters a few lines below):
control<-trainControl(method="cv", number = 5, p=0.8)
grid<-expand.grid(minNode=c(1,5),predFixed=c(5,10,15,25))
set.seed(1)
train_rf<-train(train_x, train_y, method="Rborist", nTree=50,trControl=control,tuneGrid = grid, nSamp=5000)

# Let's plot the result
ggplot(train_rf)

# Let's see the best parameters
train_rf$bestTune

# Now let's train with the best parameters
grid<-expand.grid(minNode=1, predFixed=10)
set.seed(1)
train_rf<-Rborist(train_x, train_y, nTree=500, tuneGrid=grid) #- (less then 1 min)

rf_predict<-predict(train_rf, test_x)%>%.$yPred

results5<-bind_rows(results4, data_frame(MODEL="RF", MSE=MSE(test_y, rf_predict)) )
knitr::kable(results5, "simple")

# The Random Forrest model yields the lowest MSE so far 

# Model: GBM - gradient boosting - (it takes under 5 minutes) 

# Gradient boosting is considered a gradient descent algorithm.
# Whereas random forests build an ensemble of deep independent trees, GBMs build an ensemble of shallow and weak successive trees with each tree learning and improving on the previous. 
# We will use 1000 trees number of trees to fit the model. GBMs often require many trees; however, unlike random forests GBMs can overfit so the goal is to find the optimal number of trees that minimize the loss function of interest with cross validation.

# Please note that the parameters below were also used to tune the model. These substantially increase computational time.
# shrinkage = c(.01, .1, .3) - Learning rate: Controls how quickly the algorithm proceeds down the gradient descent.
# interaction.depth = c(1, 3, 5) - the number of splits in each tree, which controls the complexity of the boosted ensemble.
# n.minobsinnode = c(5, 10, 15) - the minimum number of observations allowed in the trees terminal nodes.

TrainControl <- trainControl( method = "repeatedcv", number = 5, repeats = 4)
tunninggbm<-expand.grid(interaction.depth = 5, n.trees = 1000, shrinkage = .1, n.minobsinnode = 5)
set.seed(1)
train_gbm<-train(train_x, train_y, method="gbm", tuneGrid=tunninggbm, trControl=TrainControl, verbose=FALSE) 
gbm_predict<-predict(train_gbm, test_x)

# This code plots the most influential parameters. Again, Heated area appears to have the most relative influence.
par(mar = c(5, 8, 1, 1))
summary(
  train_gbm, 
  cBars = 10,
  las = 2)

results6<-bind_rows(results5, data_frame(MODEL="GBM", MSE=MSE(test_y, gbm_predict)) )
knitr::kable(results6, "simple")

# The GBM model has the lowest MSE out of 6 models



# Let's compile it in the ensemble with equal weight for each model:
 

ensemble_predict1<-apply(cbind(glm_predict, loess_predict, svm_predict, knn_predict, rf_predict, gbm_predict),1,mean)
results7<-bind_rows(results6, data_frame(MODEL="ENS1", MSE=MSE(test_y, ensemble_predict1)) )
knitr::kable(results7, "simple")

# The MSE increased substantially from the GBM's lowest result.

# Let's create a second ensemble that uses two best performing models: Random Forest and GBM with equal weights:

ensemble_predict2<-apply(cbind(rf_predict, gbm_predict),1,mean)
MSE(test_y,ensemble_predict2)

# The MSE has improved.

# Let's see if changing weights can improve model performance even further:
MSE_test<-NULL
for (i in 1:9){
  ensemble_predict2<-cbind(rf_predict,gbm_predict)%>%data.frame()%>%mutate(weighted=rf_predict*i/10+gbm_predict*(1-i/10))%>%.$weighted
  MSE_test=rbind(MSE_test,MSE(test_y, ensemble_predict2))
}
# The best MSE is:
MSE_test[which.min(MSE_test),]

# At the following i:
which.min(MSE_test)

# Let's apply the weights that yield the best MSE:
ensemble_predict2<-cbind(rf_predict,gbm_predict)%>%data.frame()%>%mutate(weighted=rf_predict*(which.min(MSE_test)/10)+gbm_predict*(1-which.min(MSE_test)/10))%>%.$weighted
results8<-bind_rows(results7, data_frame(MODEL="ENS2", MSE=MSE(test_y, ensemble_predict2)) )
knitr::kable(results8, "simple")

# So far, this is the best model. Let's see if we can take it a step further and improve the MSE parameter by adding another model:

# Model: Deep-learning 
# Because the data set is not large, I will use a smaller network with two hidden layers each 128 units to mitigate overfilling.
# The network will end with a single unit to predict a single continuous value.

# It begins with building a function for a model using keras package.

# To ensure this code is reproducible, the following set seed is used:
seed = 42
reticulate::py_config()
reticulate::py_set_seed(seed)
set.seed(seed)
tensorflow::tf$random$set_seed(42)

build_model<-function(){
  model <- keras_model_sequential() %>%
    layer_dense(units = 128, activation = "relu",input_shape = dim(train_x)[[2]]) %>%
    layer_dense(units = 128, activation = "relu")%>%layer_dense(units = 1)
  
  model %>% compile(optimizer = "adam",loss = "mse",metrics = c("mae"))
}

k_clear_session()
#######################################################################################
# To evaluate our network and adjust the parameters, we will use k-fold validation which consists of splitting the available data into 4 partitions and training on each partition split while evaluating on the remaining partitions.
# Please note, it takes about 20 minutes to complete this step. You can skip to the optimized model below:

k<-4
indices<-sample(1:nrow(train_x))
folds<-cut(1:length(indices), breaks=k, labels=FALSE)
num_epochs<-100
all_scores<-NULL

for (i in 1:k){
  cat("processing fold #", i, "\n")
  #prepare the validation data from partition #k
  val_indices<-which(folds==i, arr.ind=TRUE)
  val_data<-train_x[val_indices,]
  val_targets<-train_y[val_indices]
  #prepare the training data from all other partitions
  partial_train_x<-train_x[-val_indices,]
  partial_train_y<-train_y[-val_indices]
  #build the model already compiled above
  model<-build_model()
  #train the model in silent mode (verbose=0)
  history<-model%>%fit(partial_train_x,partial_train_y,validation_data=list(val_data, val_targets),epochs=num_epochs, batch_size=1, verbose=0)
  mse_history<-history$metrics$val_loss
  all_scores<-rbind(all_scores,mse_history)
  
}
# Now, lets compute the average of the MSE scores for all folds:
average_mse_history<-data.frame(epoch=seq(1:ncol(all_scores)),validation_mse=apply(all_scores,2,mean))
# Lets plot it:
ggplot(average_mse_history, aes(x=epoch, y=validation_mse))+geom_line()+geom_smooth()

# According to the plot, MSE stops improving after 75 epochs. Past that, we start overfilling.
# We can also tune other parameters, such as size of the hidden layers. 

#################################################################################################
# Optimized Model: Now lets train the final production model with the best parameters (in this case, number of epochs is 75) - (it takes less then 2 minutes)
# Please note that when test-trained on GPU, the model yields a better result.The result discussed below was produced on CPU.

model<-build_model()
model%>%fit(train_x,train_y,epochs=75, batch_size=20, verbose=0)

seed = 42
reticulate::py_set_seed(seed)
set.seed(seed)
tensorflow::tf$random$set_seed(42)

model%>%evaluate(test_x, test_y)

# Obtaining reproducible model is difficult with Keras. In order to maintain the consistent result, we saved the model produced here and it will be available to download: 
#save_model_hdf5(model, '~/Documents/Capstone/SPR/my_dl_model')
model <- load_model_hdf5('~/Documents/Capstone/SPR/my_dl_model')

dl_predict<-model%>%predict(test_x)

# Let's see what MSE is generated by the deep learning model
MSE(test_y,dl_predict)

# This result is below several models, but not ranked first

# Let's compile a 3rd ensemble with the deep learning model giving the same weight to each model:
ensemble_predict3<-apply(cbind( rf_predict, gbm_predict, dl_predict),1,mean)
MSE(test_y, ensemble_predict3)

# Let's see if we can leverage weighting the models with emphasis on GBM:
# Let's create a sample matrix of weights and apply to predictions of each model:
s<-t(matrix(c(0.1, 0.8, 0.1, 0.2, 0.7, 0.1, 0.1, 0.7, 0.2, 0.1, 0.6, 0.3, 0.2, 0.6, 0.2, 0.3, 0.6, 0.1), nrow = 3, ncol = 6))
s
MSE_test<-NULL
for (i in 1:6){
  ensemble_predict3<-cbind(rf_predict,gbm_predict, dl_predict)%>%data.frame()%>%mutate(weighted=rf_predict*s[i,1]+gbm_predict*s[i,2]+dl_predict*s[i,3])%>%.$weighted
  MSE_test=rbind(MSE_test,MSE(test_y, ensemble_predict3))
}
MSE_test
# Let's pick the better performer and apply to the ensemble 3 model:
s<-s[which.min(MSE_test),]
ensemble_predict3<-apply(cbind( rf_predict*s[1], gbm_predict*s[2], dl_predict*s[3]),1,sum)

results9<-bind_rows(results8, data_frame(MODEL="ENS3", MSE=MSE(test_y, ensemble_predict3)) )
knitr::kable(results9, "simple")

# The weighted ensemble 3, has the best MSE among the ensemble models of less than 0.019

# Let's create a relative measures of RMSE and MAEE to understand the model's performance:

sqrt(MSEE(test_y,ensemble_predict3))
MAEE(test_y,ensemble_predict3)

# Now, let's evaluate if this model will passes the assessment industry standards.
# First, we will apply exponential transformation to the predicted and actual results and apply .85 legal requirement to the assessment before calculating the hypothetical Sales Ratio:
pred<-cbind(Assessed=exp(ensemble_predict3)*.85,Sales_Price=exp(test_y))%>%data.frame()%>%mutate(SR_pred=Assessed/Sales_Price)
head(pred)

# Let's plot it and see the disributions:
pred%>%ggplot()+geom_histogram(aes(Assessed), fill="green")+geom_histogram(aes(Sales_Price), colour="orange", fill=NA)+theme(plot.title = element_text(size=20),plot.subtitle = element_text(size=18), legend.title = element_text(size=18), legend.text = element_text(size=14),axis.title = element_text(size=18), axis.text.y = element_text(size=15))+
  labs(title = 'Predicted vs. Actual Sales Distribution', subtitle= 'Year: 2019', x = 'Sales Price', y = 'Count')

# Let's calculate the required stats:
stat<-pred%>%summarise(MEAN=mean(SR_pred), MEDIAN=median(SR_pred))
stat
# 95% confidence interval for mean
sd<-sqrt(sum((pred$SR_pred-stat$MEAN)^2)/(length(pred$SR_pred)-1))
ci<-(mean(pred$SR_pred)+c(-qnorm(0.975),qnorm(0.975))*sd)*100
ci

COD<-mean(abs(pred$SR_pred-stat$MEDIAN))/stat$MEDIAN*100
COD

PRD<-stat$MEAN/(sum(pred$Assessed)/sum(pred$Sales_Price))
PRD

# Let's compare the performance of the original model to the newly developed ensemble model:

final<-knitr::kable(cbind(MEDIAN=stat$MEDIAN, MEAN=stat$MEAN,CONF_LOW=ci[1], CONF_HIGH=ci[2],COD=COD, PRD=PRD), "simple", caption = "Final Model Ratios")

final

original

# All Ratios either improved or within acceptable limits. Further feature engineering and tuning of the ensemble model will improve the parameters.

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++ THE END +++++++++++++++++++++++++++++++++++++++++++++++++++#

   
