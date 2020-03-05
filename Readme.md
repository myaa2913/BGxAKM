#### WORKFLOW
1. jobidXskillid.sql: create a unique bgtjobid X skill_id TEMP_SKILLS sql table 

2. skill_stats.sql: counts the number of unique skills for each job post, then calculates the mean and std of this number by soc,year

3. num_skills_stats.do: models the mean and variance of the # of skillclusterfamily across job postings within soc/year over time

4. variants at different levels of skill granularity. All extract a unique bgtjobid X skill csv with nonmissing data from SQL tables MAINTEXT and TEMP_SKILLS. Also excludes internship ads.
- ext_wage_skillcluster.sql
- ext_wage_skillclusterfamily.sql




