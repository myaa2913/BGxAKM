--extract a unique bgtjobid X skillcluster csv with nonmissing data from SQL tables MAINTEXT and TEMP_SKILLS
\copy (SELECT temp_skills.bgtjobid, temp_skills.skillcluster FROM temp_skills INNER JOIN maintext_with_employer ON temp_skills.bgtjobid = maintext_with_employer.bgtjobid WHERE maintext_with_employer.internship IS NOT true AND (maintext_with_employer.msa IS NOT NULL OR maintext_with_employer.bestfitmsa IS NOT NULL) AND maintext_with_employer.fuzzyemployer IS NOT NULL AND maintext_with_employer.soc IS NOT NULL AND maintext_with_employer.employer_age IS NOT NULL AND NULLIF(temp_skills.skillcluster,'') IS NOT NULL) to '~/bg_skills/BGxAKM/temp/jobidXskillcluster_new_firms.csv' with csv header;

--extract skill vectors for the entire data to calculate soc means
\copy (SELECT temp_skills.bgtjobid, temp_skills.skillcluster FROM temp_skills INNER JOIN maintext_with_employer ON temp_skills.bgtjobid = maintext_with_employer.bgtjobid WHERE maintext_with_employer.internship IS NOT true AND maintext_with_employer.fuzzyemployer IS NOT NULL AND maintext_with_employer.soc IS NOT NULL AND NULLIF(temp_skills.skillcluster,'') IS NOT NULL) to '~/bg_skills/BGxAKM/temp/jobidXskillcluster_all_data.csv' with csv header;












