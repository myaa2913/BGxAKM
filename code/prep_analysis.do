local skill_freq_th 5000

cd "/ifs/gsb/mcorrito/"

log using "prep_analysis_log_`skill_freq_th'", text replace
log off

import delimited using "/ifs/gsb/mcorrito/jobidXskill_wage_reduced.csv", clear 

drop if skillcluster=="" | fuzzyemployer==""

duplicates drop

log on
duplicates report bgtjobid skill_id
duplicates drop bgtjobid skill_id, force
log off

/* shorten character length of skill values */
ren skillcluster skill 
drop skill_id

log on
duplicates drop
duplicates report bgtjobid skill
duplicates drop bgtjobid skill,force
log off

egen orgid = group(fuzzyemployer) /* create orgid var */
drop fuzzyemployer

destring msa,replace force
drop if msa==-999 | msa==. /* drop records with missing msa */

replace edu = 0 if edu==.
replace exp = 0 if exp==.

replace soc = subinstr(soc, "-", "",.)  /* create numeric soc var */
destring soc,replace

/* examine dist of num ads per skillcluster */
preserve
keep bgtjobid skill
duplicates drop
bysort skill: g num_posts_per_skill = _N
drop bgtjobid
duplicates drop
log on
sum num_posts_per_skill,d
log off
kdensity num_posts_per_skill
graph export "kdens_num_posts_per_skill.eps",replace	
sort skill
tempfile num_posts_per_skill
save "`num_posts_per_skill'"
restore

sort skill  /* merge on the number of posts per skill var to do restriction */
log on
merge skill using "`num_posts_per_skill'"
tab _merge
log off
drop _merge

drop if num_posts_per_skill < `skill_freq_th' /* drop infrequent skills */
drop num_posts_per_skill

/* create a skillclusterid and save a crosswalk */
egen skillid = group(skill)
preserve
keep skill skillid
duplicates drop
order skillid skill
sort skillid
compress
saveold "id_skill_cross_`skill_freq_th'.dta",replace
restore
drop skill

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
reshape wide skill, i(bgtjobid) j(little_n)

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
saveold "id_bundle_cross.dta_`skill_freq_th'",replace
restore
drop skill_bundle

/* basic descriptives */
foreach var in minsalary maxsalary edu exp {
    kdensity `var'
    graph export "kdens_`var'_`skill_freq_th'.eps",replace	
}

log on
sum
foreach var of varlist * {
sum `var',d
}
log off

sort bgtjobid
compress
saveold master_`skill_freq_th'.dta,replace

log close

