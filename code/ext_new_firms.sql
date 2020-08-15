--extract a unique bgtjobid csv with nonmissing data from SQL tables MAINTEXT that explores new firm data
\copy (SELECT maintext_with_employer.firsttime_cleantitle, maintext_with_employer.employer_age, maintext_with_employer.job_sequence_number, maintext_with_employer.job_sequence_number_2010, maintext_with_employer.employer_age_2010, maintext_with_employer.bgtjobid, maintext_with_employer.soc, maintext_with_employer.jobdate, maintext_with_employer.msa, maintext_with_employer.bestfitmsa, maintext_with_employer.edu, maintext_with_employer.degree, maintext_with_employer.exp, maintext_with_employer.fuzzyemployer LIMIT 10000 FROM maintext_with_employer WHERE maintext_with_employer.internship IS NOT true AND (maintext_with_employer.msa IS NOT NULL OR maintext_with_employer.bestfitmsa IS NOT NULL) AND maintext_with_employer.fuzzyemployer IS NOT NULL AND maintext_with_employer.soc IS NOT NULL AND maintext_with_employer.employer_age IS NOT NULL) to '~/bg_skills/BGxAKM/temp/new_firm_vars.csv' with csv header;














