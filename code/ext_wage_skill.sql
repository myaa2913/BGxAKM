--extract a unique bgtjobid X skillcluster csv with nonmissing data from SQL tables MAINTEXT and TEMP_SKILLS
\copy (SELECT temp_skills.bgtjobid, temp_skills.soc, temp_skills.year, temp_skills.skill_id, temp_skills.skillcluster, maintext.minsalary, maintext.maxsalary FROM temp_skills INNER JOIN maintext ON temp_skills.bgtjobid = maintext.bgtjobid WHERE maintext.minsalary IS NOT NULL AND maintext.maxsalary IS NOT NULL AND temp_skills.skillcluster IS NOT NULL) to '~/bg_skills/BGxAKM/temp/jobidXskill_wage.csv' with csv header;














