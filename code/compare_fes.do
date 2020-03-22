use org_bundle_fe_2010,clear
keep orgid bundleid org_fe bundle_fe year
duplicates drop
compress
save org_bundle_fe_compiled,replace

foreach yr in 2011 2012 2013 2014 2015 2016 2017 2018 {
    use org_bundle_fe_`yr',clear
    keep orgid bundleid org_fe bundle_fe year
    duplicates drop
    compress
    append using org_bundle_fe_compiled
    saveold org_bundle_fe_compiled,replace
} 

/*
collapse (mean) bundle_fe,by(org_fe year)
forvalues i=2010/2018 {
    correlate org_fe bundle_fe if year==`i'
}




/*
*prep id_skill_cross
use id_bundle_cross_skillclusterfamily,clear
sort bundleid
tempfile cross
save "`cross'"

use org_bundle_fe_2010,clear
keep orgid org_fe year
duplicates drop
compress
save org_fe_compiled,replace

foreach yr in 2011 2012 2013 2014 2015 2016 2017 2018 {
    use org_bundle_fe_`yr',clear
    keep orgid org_fe year
    duplicates drop
    compress
    append using org_fe_compiled
    save org_fe_compiled,replace
} 

xtset orgid year
correlate org_fe l.org_fe /* 0.55 year-to-year correlation */ 



use org_bundle_fe_2010,clear
keep bundleid bundle_fe year
duplicates drop
compress
save bundle_fe_compiled,replace

foreach yr in 2011 2012 2013 2014 2015 2016 2017 2018 {
    use org_bundle_fe_`yr',clear
    keep bundleid bundle_fe year
    duplicates drop
    compress
    append using bundle_fe_compiled
    save bundle_fe_compiled,replace
}

xtset bundleid year
correlate bundle_fe l.bundle_fe /* 0.6 year-to-year correlation */ 

sort bundleid
merge bundleid using "`cross'"
tab _merge
drop if _merge==2
drop _merge

gsort -bundle_fe

