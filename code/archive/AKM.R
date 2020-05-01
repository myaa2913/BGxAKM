setwd("~/bg_skills/BGxAKM/data/")

master = read.csv("master_reduced.csv")

length(unique(soc))
length(unique(orgid))
length(unique(bundleid))

## calculate variance explained by each set of fixed effects
fit_base = lm(ln_wage ~ exp + edu + factor(year), data = master)
fit_soc = lm(ln_wage ~ factor(soc) + exp + edu + factor(year), data = master)
fit_soc_firm = lm(ln_wage ~ factor(soc) + factor(orgid) + exp + edu + factor(year), data = master)
fit_soc_firm_skill = lm(ln_wage ~ factor(skillid) + factor(soc) + factor(orgid) + exp + edu + factor(year), data = master)

summary(fit_base)



