library(survival)
library(StepReg)
library(ggplot2)
library(scales)
library(dplyr)
library(ggfortify)

###################
# Load data
###################
whas500 <- readRDS("data/clean_data.rds")

###################
# Kaplan Meier
###################
km_fit <- survfit(Surv(lenfol, fstat) ~ 1, data=whas500)

temp <- tibble(Time = km_fit$time,Surv = km_fit$surv)

ggplot(temp, aes(x = Time, y = Surv)) + 
  geom_step() + 
  scale_x_continuous(breaks = seq(0, 2400, 400), limit = c(0, 2400)) + 
  scale_y_continuous(breaks = seq(0, 1, .10), labels = percent) + 
  labs(title = "Kaplan Meier Survival Curve", y = "Proportion of People Alive")

whas500_02 <- whas500 %>%
  mutate(chf  = factor(if_else(chf  == 1, "Yes", "No")))
km_fit_02 <- survfit(Surv(lenfol, fstat) ~ chf , data=whas500_02)

autoplot(km_fit_02)

sum(whas500$chf)

temp <- tibble(Time = km_fit_02$time,Surv = km_fit_02$surv, Strata = c(rep("No", 345), rep("Yes", 155)))

whas500_02 <- whas500 %>%
  mutate(afb  = factor(if_else(afb  == 1, "Yes", "No")))
km_fit_02 <- survfit(Surv(lenfol, fstat) ~ afb , data=whas500_02)

autoplot(km_fit_02)

sum(whas500$afb)

temp <- tibble(Time = km_fit_02$time,Surv = km_fit_02$surv, Strata = c(rep("No", 348), rep("Yes", 74)))


ggplot(temp, aes(x = Time, y = Surv, color = Strata)) + 
  geom_step() + 
  scale_x_continuous(breaks = seq(0, 2400, 400), limit = c(0, 2400)) + 
  scale_y_continuous(breaks = seq(0, 1, .10), labels = percent) + 
  labs(title = "Atrial Fibrillation", y = "Proportion of People Alive")

###################
# Cox Proportional Hazards Model
###################
# step wise search
temp <- stepwiseCox(
  formula = Surv(lenfol, fstat) ~ age + gender + hr + sysbp + diasbp + bmi + cvd + afb + sho + chf + av3 + miord + mitype, 
  data = whas500,
  selection = "bidirection",
  select = "AIC"
)
temp[["Selected Varaibles"]]

cox <- coxph(Surv(lenfol, fstat) ~ age + chf + sho + hr + diasbp + bmi + gender + mitype, data = whas500)
summary(cox)

cox_fit <- survfit(cox)
temp <- tibble(Time = cox_fit$time,Surv = cox_fit$surv)
ggplot(temp, aes(x = Time, y = Surv)) + 
  geom_step() + 
  scale_x_continuous(breaks = seq(0, 2400, 400), limit = c(0, 2400)) + 
  scale_y_continuous(breaks = seq(0, 1, .10), labels = percent) + 
  labs(title = "Cox Proportional Hazards Survival Curve", y = "Proportion of People Alive")

###################
# Comparing Survival Curves
###################
plot_df <- rbind(
  tibble(Time = km_fit$time,Surv = km_fit$surv,Model = rep("KM",length(km_fit$time))),
  tibble(Time = cox_fit$time,Surv = cox_fit$surv,Model = rep("Cox",length(cox_fit$time))))

ggplot(plot_df, aes(x = Time, y = Surv, color = Model)) + 
  geom_step() + 
  scale_x_continuous(breaks = seq(0, 2400, 400), limit = c(0, 2400)) + 
  scale_y_continuous(breaks = seq(0, 1, .10), labels = percent) + 
  labs(title = "Model Survival Curves", y = "Proportion of People Alive")
