--this command counts the number of UNIQUE skills, according to the various skill granularities, by bgtjobid,soc,year
SELECT COUNT(DISTINCT(NULLIF(skill,''))) as num_skills,COUNT(DISTINCT(NULLIF(skillcluster,''))) as num_skillcluster,COUNT(DISTINCT(NULLIF(skillclusterfamily,''))) as num_skillclusterfamily,bgtjobid,soc,year INTO skill_count FROM temp_skills GROUP BY bgtjobid,soc,year;

-- this command will calculate the mean and std of the unique # of skills by soc,year
\copy (SELECT AVG(num_skills) as mean_skills,AVG(num_skillcluster) as mean_skillcluster,AVG(num_skillclusterfamily) as mean_skillclusterfamily,STDDEV(num_skills) as std_skills,STDDEV(num_skillcluster) as std_skillcluster,STDDEV(num_skillclusterfamily) as std_skillclusterfamily,soc,year FROM skill_count GROUP BY soc,year) to '~/bg_skills/BGxAKM/temp/num_skill_stats.csv' with csv header;














