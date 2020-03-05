log using "C:\Users\Matt\Dropbox\BG_Skills\temp\num_skill_stats", replace text
log off

/* this file inputs a soc-by-year file with the mean and std of the number of skills */
import delimited using "C:\Users\Matt\Dropbox\BG_Skills\temp\num_skill_stats.csv",clear

sum

egen soc_group = group(soc)
xtset soc_group

log on
*mean # skills as a function of time 
*loop through three levels of skill granularity 
foreach var of varlist mean_skills-mean_skillclusterfamily {
	xtreg `var' year,fe  /*mean skills increase over time*/
	xtreg `var' year if year>2007,fe
	xtreg `var' i.year,fe
}

*variance in skills as a function of time 
*loop through three levels of skill granularity 
foreach var of varlist std_skills-std_skillclusterfamily {
	xtreg `var' year,fe  /*mean skills increase over time*/
	xtreg `var' year if year>2007,fe
	xtreg `var' i.year,fe
}
log off

log close
