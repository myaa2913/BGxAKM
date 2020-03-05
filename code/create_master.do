cd "/ifs/gsb/mcorrito/"

log using "create_master", text replace
log off

import delimited using "/ifs/gsb/mcorrito/jobidXskillclusterfamily_wage.csv", clear 

*drop missing values
foreach var in soc skillclusterfamily fuzzyemployer {
    drop if `var' == .
}
drop if msa==-999 | msa==. 

*recode missing edu and exp value to 0 per Kahn/Deming
replace edu = 0 if edu==.
replace exp = 0 if exp==.

egen orgid = group(fuzzyemployer) /* create orgid var */
drop fuzzyemployer

replace soc = subinstr(soc, "-", "",.)  /* create numeric soc var */
destring soc,replace

*drop any jobid,skillclusterfamily duplicates (due to different skills within the family)
duplicates drop bgtjobid skillclusterfamily,force

/* create a skillclusterfamily id and save a crosswalk */
egen skillid = group(skillclusterfamily)
preserve
keep skillid skillclusterfamily
duplicates drop
order skillid skillclusterfamily
sort skillid
compress
saveold "id_skillclusterfamily_cross.dta",replace
restore
drop skillclusterfamily

/* sort skill names within bgtjobid to ensure that the same "bundled" FE is same order */
sort bgtjobid skillid

/* recode skillid to a character var with dash seperators */
tostring skillid,replace
g und_1 = "-"
g und_2 = "-"
g new_skillid = und_1 + skillid + und_2
drop und_* skillid
ren new_skillid skillid

bysort bgtjobid: g little_n = _n
reshape wide skillid, i(bgtjobid) j(little_n)

/* create FE bundles */
egen skill_bundle = concat(skillid*)
drop skillid*

/* create a bundle id and save crosswalk */
egen bundleid = group(skill_bundle)
preserve
keep bundleid skill_bundle
duplicates drop
order bundleid skill_bundle
sort bundleid
compress
saveold "id_bundle_cross_skillclusterfamily.dta",replace
restore
drop skill_bundle

log on
sum
foreach var of varlist * {
sum `var',d
}
log off

log on
distinct soc
distinct msa
distinct year
distinct orgid
distinct bundleid
log off

*create wage var
g ln_wage = ln((minsalary + maxsalary) / 2)

sort bgtjobid
compress
saveold master_skillclusterfamily.dta,replace

log close

