cd "/Users/matthewcorritore/Dropbox/BG_Skills/temp"

log using "explore_FE_models",replace text
log off

import delimited using complete_fes.csv,clear
set matsize 10000

*name variables
ren v1 bgtjobid
ren v2 soc
ren v3 year
ren v4 msa
ren v5 edu
ren v6 exp
ren v7 orgid
ren v8 bundleid
ren v9 ln_wage
ren v10 soc_fes
ren v11 org_fes
ren v12 skill_fes
ren v13 msa_fes
ren v14 intercept
ren v15 edu_beta
ren v16 exp_beta

tostring soc,replace
g soc3 = substr(soc,1,3) /* create 3 digit soc code */
destring soc3 soc,replace
*egen soc3_group = group(soc3)
*egen soc_group = group(soc)

compress
saveold complete_fes.dta,replace

sum

*year-to-year correlations of the various FEs
preserve
keep soc year soc_fes
duplicates drop 
duplicates report
xtset soc year
correlate soc_fes l.soc_fes  /* 0.76 */
restore

preserve
keep orgid year org_fes
duplicates drop 
duplicates report
xtset orgid year
correlate org_fes l.org_fes  /* 0.77 once again */
restore

preserve
keep bundleid year skill_fes
duplicates drop 
duplicates report
xtset bundleid year
correlate skill_fes l.skill_fes  /* 0.60, more variance, which probably makes sense */
restore

g p_hat = intercept + soc_fe + org_fe + skill_fe + msa_fe + (edu*edu_beta) + (exp*exp_beta)

*look at soc3 trends over time
collapse (mean) soc_fe org_fe skill_fe msa_fe edu exp,by(soc3 year intercept edu_beta exp_beta)

g p_hat = intercept + soc_fe + org_fe + skill_fe + msa_fe + (edu*edu_beta) + (exp*exp_beta)

reg soc_fes i.soc3
reg soc_fes c.year i.soc3
reg soc_fes c.year##i.soc3

reg org_fes i.soc3               /* the most action over time is changes in the org_fes */
reg org_fes c.year i.soc3
reg org_fes c.year##i.soc3
margins,dydx(year) over(soc3)

reg skill_fes i.soc3
reg skill_fes c.year i.soc3
reg skill_fes c.year##i.soc3
margins,dydx(year) over(soc3)

*look at soc6 trends over time
use complete_fes.dta,clear
collapse (mean) soc_fe org_fe skill_fe msa_fe edu exp,by(soc year intercept edu_beta exp_beta)

reg soc_fes i.soc
reg soc_fes c.year i.soc
reg soc_fes c.year##i.soc

reg org_fes i.soc            /* the most action over time is changes in the org_fes */
reg org_fes c.year i.soc
reg org_fes c.year##i.soc
margins,dydx(year) over(soc)

reg skill_fes i.soc
reg skill_fes c.year i.soc
reg skill_fes c.year##i.soc
margins,dydx(year) over(soc)





/*
*correlations across the FE classes by year
*orgs and occupations -- probably expect less variance across time 
preserve
collapse (sd) org_fes soc_fes skill_fes,by(year)
log on
list in 1/10
log off
restore



*are there soc FEs that are changing a lot over time?
preserve
keep soc year soc_fes
duplicates drop
collapse (mean) soc_fes,by(soc year)
keep if year==2010 | year==2018
sort soc year
bysort soc: g chg = soc_fes[_n] - soc_fes[_n-1]
drop if year==2010
tostring soc,replace
g soc3 = substr(soc,1,3) /* create 3 digit soc code */
collapse (mean) soc_fes,by(soc3)
restore

*are there skill FEs that are changing a lot over time?
preserve
keep bundleid year skill_fes
duplicates drop
collapse (mean) skill_fes,by(bundleid year)
keep if year==2010 | year==2018
sort bundleid year
bysort bundleid: g chg = skill_fes[_n] - skill_fes[_n-1]
drop if year==2010
g miss = 1 if chg==.
replace miss = 0 if chg!=.
drop if miss==1
drop miss
sort chg
sort bundleid
merge bundleid using id_bundle_cross_skillclusterfamily
tab _merge
keep if _merge==3
drop _merge
gsort -chg
restore

*high payoff skills
preserve
keep year bundleid skill_fes
duplicates drop
sort bundleid year
restore

*by soc3: print correlations between firm FEs and skill FEs to log file (soc3)
preserve
tostring soc,replace
g soc3 = substr(soc,1,3) /* create 3 digit soc code */
collapse (mean) org_fes skill_fes soc_fes,by(soc3 year)
g diff = org_fes - skill_fes
gsort -diff
sort soc3 year
egen soc3_group = group(soc3)
xtset soc3_group year
correlate diff l.diff
correlate diff year /* 0.36 -- interesting.   0.23 exempting 2018 */
restore

*by soc: print correlations between firm FEs and skill FEs to log file (soc3)
preserve
collapse (mean) org_fes skill_fes,by(soc year)
g diff = org_fes - skill_fes
gsort -diff
sort soc year
egen soc_group = group(soc)
xtset soc_group year
correlate diff l.diff
correlate diff year /* 0.48 -- interesting.   only 0.17 exempting 2018 */
reg diff year i.soc
reg diff year i.soc if year!=2018
reg diff i.year i.soc if year!=2018
reg diff i.year i.soc 
restore


*I don't see much change
reg soc_fes year
reg soc_fes year i.soc3_group  




collapse (mean) soc_fes,by(soc year)
reg soc_fes year 
reg soc_fes year i.soc



collapse (mean) soc_fes skill_fes,by(orgid org_fe year soc)
correlate
reg skill_fes year



import delimited using complete_fes.csv,clear
collapse (mean) skill_fes,by(year soc orgid soc_fes org_fes)
egen org_soc = group(orgid soc)
xtset org_soc year
xtreg skill_fes i.year,fe


import delimited using complete_fes.csv,clear
collapse (mean) skill_fes soc_fes,by(year orgid org_fes)
xtset orgid year
xtreg org_fes i.year,fe cluster(orgid)
xtreg soc_fes i.year,fe cluster(orgid)
xtreg skill_fes year,fe cluster(orgid)
xtreg skill_fes i.year,fe cluster(orgid)




import delimited using complete_fes.csv,clear
tostring soc,replace
g soc3 = substr(soc,1,3) /* create 3 digit soc code */
collapse (mean) org_fes skill_fes soc_fes,by(soc3 year)
correlate year org_fes-soc_fes
/*
             |     year  org_fes skill_~s  soc_fes
-------------+------------------------------------
        year |   1.0000
     org_fes |   0.2686   1.0000
   skill_fes |   0.0204   0.5575   1.0000
     soc_fes |  -0.0010   0.6137   0.7642   1.0000 */

egen soc3_group = group(soc3)	 
xtset soc3_group year
xtreg org_fes year,fe cluster(soc3_group)	 /* positive time trend */
xtreg org_fes i.year,fe cluster(soc3_group)	 
xtreg soc_fes year,fe cluster(soc3_group)	 /* null */
xtreg soc_fes i.year,fe cluster(soc3_group)	 
xtreg skill_fes year,fe cluster(soc3_group)	 /* smaller positive time trend */
xtreg skill_fes i.year,fe cluster(soc3_group)	

*is the firm component growing a lot for certain occupations more than others?
reg org_fes c.year##i.soc3_group
margins,dydx(year) over(soc3_group)

reg skill_fes c.year##i.soc3_group
margins,dydx(year) over(soc3_group)



import delimited using complete_fes.csv,clear
collapse (mean) org_fes skill_fes soc_fes,by(soc year)
xtset soc year
xtreg org_fes year,fe cluster(soc)
xtreg org_fes i.year,fe cluster(soc)

xtreg soc_fes year,fe cluster(soc)
xtreg skill_fes year,fe cluster(soc)
xtreg skill_fes i.year,fe cluster(soc)

*look at mean and variance in the skill_fes by soc3

/*
import delimited using org_bundle_fe.csv,clear

split skill_bundle, p("--")
foreach var of varlist skill_bundle1-skill_bundle23 {
	replace `var' = subinstr(`var', "-", "",.)
	destring `var',replace
}

forval i=1/23 {
	g skill`i' = 1 if skill_bundle1==`i' | ///
					  skill_bundle2==`i' | ///
					  skill_bundle3==`i' | ///
					  skill_bundle4==`i' | ///
					  skill_bundle5==`i' | ///
					  skill_bundle6==`i' | ///
					  skill_bundle7==`i' | ///
					  skill_bundle8==`i' | ///
					  skill_bundle9==`i' | ///
					  skill_bundle10==`i' | ///
					  skill_bundle11==`i' | ///
					  skill_bundle12==`i' | ///
					  skill_bundle13==`i' | ///
					  skill_bundle14==`i' | ///
					  skill_bundle15==`i' | ///
					  skill_bundle16==`i' | ///
					  skill_bundle17==`i' | ///
					  skill_bundle18==`i' | ///
					  skill_bundle19==`i' | ///
					  skill_bundle20==`i' | ///
					  skill_bundle21==`i' | ///
					  skill_bundle22==`i' | ///
					  skill_bundle23==`i' 
    replace skill`i' = 0 if skill`i'==.
}

drop skill_bundle* 
*breadth
egen num_skill=rowtotal(skill*)

reg bundle_fe num_skill skill* 




import delimited using org_bundle_fe_compiled.csv,clear
egen std_skillfe = std(bundle_fe)
xtset bundleid year
correlate bundle_fe l.bundle_fe

split skill_bundle, p("--")
foreach var of varlist skill_bundle1-skill_bundle23 {
	replace `var' = subinstr(`var', "-", "",.)
	destring `var',replace
}

forval i=1/23 {
	g skill`i' = 1 if skill_bundle1==`i' | ///
					  skill_bundle2==`i' | ///
					  skill_bundle3==`i' | ///
					  skill_bundle4==`i' | ///
					  skill_bundle5==`i' | ///
					  skill_bundle6==`i' | ///
					  skill_bundle7==`i' | ///
					  skill_bundle8==`i' | ///
					  skill_bundle9==`i' | ///
					  skill_bundle10==`i' | ///
					  skill_bundle11==`i' | ///
					  skill_bundle12==`i' | ///
					  skill_bundle13==`i' | ///
					  skill_bundle14==`i' | ///
					  skill_bundle15==`i' | ///
					  skill_bundle16==`i' | ///
					  skill_bundle17==`i' | ///
					  skill_bundle18==`i' | ///
					  skill_bundle19==`i' | ///
					  skill_bundle20==`i' | ///
					  skill_bundle21==`i' | ///
					  skill_bundle22==`i' | ///
					  skill_bundle23==`i' 
    replace skill`i' = 0 if skill`i'==.
}

drop skill_bundle* 
*breadth
egen num_skill=rowtotal(skill*)

duplicates report bundleid year
correlate skillfe year num_skill 
reg std_skillfe skill1 num_skill i.year

reg std_skillfe c.num_skill##i.year
margins,dydx(num_skill) over(year)
