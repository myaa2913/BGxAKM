*prep crosswalks for merge
use id_skillclusterfamily_cross,clear
export delimited using id_skillclusterfamily_cross.csv,replace

use id_bundle_cross_skillclusterfamily,clear
sort bundleid
tempfile id_bundle_cross
save "`id_bundle_cross'"

/*
use org_bundle_fe,clear
keep bundleid bundle_fe
duplicates drop
sort bundleid
merge bundleid using "`id_bundle_cross'"
tab _merge
keep if _merge==3
drop _merge

export delimited using org_bundle_fe.csv,replace
*/

use org_bundle_fe_compiled,clear
keep bundleid bundle_fe year
duplicates drop
sort bundleid
merge bundleid using "`id_bundle_cross'"
tab _merge
keep if _merge==3
drop _merge

export delimited using org_bundle_fe_compiled.csv,replace

