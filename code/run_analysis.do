log using master_analytic.log, replace text
log off

clear matrix
clear mata
set maxvar 50000
set matsize 11000

set emptycells drop

use master_analytic.dta,clear

log on
reg ln_wage edu exp i.year
reg ln_wage edu exp i.msa i.year
reg ln_wage edu exp i.soc i.msa i.year
areg ln_wage edu exp i.soc i.msa i.year, absorb(orgid)  
log off
estimates store firm_reg
predict ln_wage_hat if e(sample)
predict org_fe,d
replace org_fe=org_fe+_b[_cons]
predict resid, r
g sqres=resid^2
egen N=count(sqres), by(orgid)
summarize sqres, meanonly
g orgid_se=sqrt(r(mean)*e(N)/e(df_r)/N)
drop resid sqres N
areg ln_wage edu exp i.soc i.msa i.year, absorb(orgid)  

log on
areg ln_wage_hat, absorb(bundleid)
log off
predict bundle_fe,d
replace bundle_fe=bundle_fe+_b[_cons]
predict resid, r
g sqres=resid^2
egen N=count(sqres), by(bundleid)
summarize sqres, meanonly
g bundleid_se=sqrt(r(mean)*e(N)/e(df_r)/N)
drop resid sqres N
keep bundleid orgid bundle_fe bundleid_se orgid_se org_fe
duplicates drop
compress
save org_bundle_fe,replace


foreach yr in 2010 2011 2012 2013 2014 2015 2016 2017 2018 {
    use master_analytic.dta,clear
    log on
    keep if year==`yr'
    reg ln_wage edu exp 
    reg ln_wage edu exp i.msa 
    reg ln_wage edu exp i.soc i.msa 
    areg ln_wage edu exp i.soc i.msa, absorb(orgid)  
    log off
    predict ln_wage_hat if e(sample)
    predict org_fe,d
    replace org_fe=org_fe+_b[_cons]
    predict resid, r
    g sqres=resid^2
    egen N=count(sqres), by(orgid)
    summarize sqres, meanonly
    g orgid_se=sqrt(r(mean)*e(N)/e(df_r)/N)
    drop resid sqres N
    log on
    areg ln_wage_hat, absorb(bundleid)
    log off
    predict bundle_fe,d
    replace bundle_fe=bundle_fe+_b[_cons]
    predict resid, r
    g sqres=resid^2
    egen N=count(sqres), by(bundleid)
    summarize sqres, meanonly
    g bundleid_se=sqrt(r(mean)*e(N)/e(df_r)/N)
    drop resid sqres N
    keep bundleid orgid bundle_fe bundleid_se orgid_se org_fe
    duplicates drop
    g year = `yr'
    compress
    save org_bundle_fe_`yr',replace
}

