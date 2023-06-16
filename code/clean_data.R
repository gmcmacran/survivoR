library(tidyverse)
library(stringr)
library(readr)

whas500 <- read_table("data/whas500.dat", col_names = FALSE)

##############
# Column names
##############
whas500 <- whas500 %>%
  select(-X23)
colnames(whas500) <- c("id", "age", "gender", "hr", "sysbp", "diasbp", "bmi", "cvd", "afb", "sho", "chf", "av3", "miord", "mitype", "year", "admitdata", "disdate", "fdate", "los", "dstat", "lenfol", "fstat")

nrow(whas500) == 500
ncol(whas500) == 22

##############
# dates
##############
whas500 %>%
  mutate(admitdata = mdy(admitdata),
         disdate = mdy(disdate),
         fdate = mdy(fdate))

##############
# Sanity check variables
##############
whas500 %>%
  summarise(across(everything(), min))

whas500 %>%
  summarise(across(everything(), max))

##############
# modify values
##############
whas500 <- whas500 %>%
  mutate(year = case_when(
    year == 1 ~ 1997,
    year == 2 ~ 1999,
    year == 3 ~ 2001
  ))

##############
# save
##############
whas500 %>%
  saveRDS(file = "data/clean_data.rds")
