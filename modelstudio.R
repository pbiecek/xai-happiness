library("dplyr")
library("ggplot2")
library("patchwork")
library("ranger")
library("xgboost")
library("DALEX")
library("rms")
library("modelStudio")

# Get the data from 
# https://www.kaggle.com/unsdsn/world-happiness#
happiness <- read.table("2019.csv", sep = ",", header = TRUE)

row.names(happiness) <- happiness[,2]
happiness <- happiness[,-(1:2)]

col_names <- names(happiness)
col_names <- tolower(col_names)
col_names <- lapply(strsplit(col_names, "[.]"), paste, collapse  ="_")
colnames(happiness) <- col_names

saveRDS(happiness, file = "happiness.rds")

happiness <- readRDS("happiness.rds")

model <- ranger(score~., data = happiness)
modelr <- DALEX::explain(model, data = happiness[,-1], y = happiness$score)

# small
ms <- modelStudio(modelr, happiness[c("Poland","Finland","Germany"),],
                  options = ms_options(margin_left = 220))
ms

# large
ms <- modelStudio(modelr, happiness,
                  options = ms_options(margin_left = 220,
                                       ms_title = "What makes you happy? (country level)"))

r2d3::save_d3_html(ms, file = "index.html")
