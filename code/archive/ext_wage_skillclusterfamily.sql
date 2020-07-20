--extract a unique bgtjobid X skillclusterfamily csv with nonmissing data from SQL tables MAINTEXT and TEMP_SKILLS
\copy (SELECT temp_skills.bgtjobid, temp_skills.soc, temp_skills.year, temp_skills.skillclusterfamily, maintext_with_employer.minsalary, maintext_with_employer.maxsalary, maintext_with_employer.msa, maintext_with_employer.edu, maintext_with_employer.degree, maintext_with_employer.exp, maintext_with_employer.fuzzyemployer FROM temp_skills INNER JOIN maintext_with_employer ON temp_skills.bgtjobid = maintext_with_employer.bgtjobid WHERE maintext_with_employer.minsalary IS NOT NULL AND maintext_with_employer.maxsalary IS NOT NULL AND maintext_with_employer.internship IS NOT true AND maintext_with_employer.msa IS NOT NULL AND maintext_with_employer.fuzzyemployer IS NOT NULL AND temp_skills.soc IS NOT NULL AND NULLIF(temp_skills.skillclusterfamily,'') IS NOT NULL) to '~/bg_skills/BGxAKM/temp/jobidXskillclusterfamily_wage.csv' with csv header;














