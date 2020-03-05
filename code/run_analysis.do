cd "/ifs/gsb/mcorrito/"

log using "run_analysis_log", replace text
log off

use master,replace

log on
sum
log off

/* select random sample for testing */
*g random = runiform()
*keep if random <= 0.05

/*
twoway kdensity ln_wage if year==2007 || ///
       kdensity ln_wage if year==2010 || ///
       kdensity ln_wage if year==2011 || ///
       kdensity ln_wage if year==2012 || ///
       kdensity ln_wage if year==2013 || ///
       kdensity ln_wage if year==2014 || ///
       kdensity ln_wage if year==2015 || ///
       kdensity ln_wage if year==2016 || ///
       kdensity ln_wage if year==2017 || ///
       kdensity ln_wage if year==2018 
graph export "kdens_wage_yr.eps",replace
*/

/* restrict to a reasonable number of firm and skill FEs */
/* >=10 ads/firm; firms w ads across at least two msas and two socs; skill bundles that appear at least 350 times */
bysort orgid: g rec_per_firm = _N
bysort bundleid: g rec_per_bundle = _N

/*
log on
preserve
keep orgid rec_per_firm
duplicates drop
kdensity rec_per_firm
graph export "kdens_rec_per_firm.eps",replace
sum rec_per_firm,d
restore

preserve
keep bundleid rec_per_bundle
duplicates drop
kdensity rec_per_bundle
graph export "kdens_rec_per_bundle.eps",replace
sum rec_per_bundle,d
restore
log off
*/

drop if rec_per_firm < 10 | rec_per_bundle < 350
sort orgid

*two different socs and msas
preserve
keep orgid msa 
duplicates drop
bysort orgid: g num_msa_per_firm = _N
drop msa
duplicates drop
sort orgid
tempfile num_msa
save "`num_msa'"
restore

preserve
keep orgid soc 
duplicates drop
bysort orgid: g num_soc_per_firm = _N
drop soc
duplicates drop
sort orgid
tempfile num_soc
save "`num_soc'"
restore

log on
merge orgid using "`num_msa'"
tab _merge
keep if _merge==3
drop _merge
sort orgid
merge orgid using "`num_soc'"
tab _merge
keep if _merge==3
drop _merge
log off

drop if num_msa_per_firm < 2
drop if num_soc_per_firm < 2
drop num_msa* num_soc*

log on
distinct orgid
distinct bundleid
distinct soc
distinct msa
log off

/* replace missing values of edu and exp */
replace edu = 0 if edu==.
replace exp = 0 if exp==.
drop miss*

/* create mean, logged wage */
g ln_wage = ln((minsalary + maxsalary) / 2)

log on
sum
log off

compress
saveold master_reduced,replace

export delimited using master_reduced.csv, replace

log close

