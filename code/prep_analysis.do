cd "/ifs/gsb/mcorrito/"

log using "prep_analysis", replace text
log off

use master_skillclusterfamily.dta,replace

/* select random sample for testing */
*g random = runiform()
*keep if random <= 0.05

/* drop low freq firms */
bysort orgid: g rec_per_firm = _N
drop if rec_per_firm < 10

bysort bundleid: g rec_per_bundle = _N
drop if rec_per_bundle < 10

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
sort orgid
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

compress
saveold master_analytic,replace
export delimited using master_analytic.csv, replace

log close

