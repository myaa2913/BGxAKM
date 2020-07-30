\copy (SELECT fuzzyemployer,date_part('year',maintext_with_employer.jobdate) AS year,COUNT(bgtjobid) FROM maintext_with_employer GROUP BY fuzzyemployer,date_part('year',maintext_with_employer.jobdate)) to '~/bg_skills/BGxAKM/temp/firm_size.csv' with csv header;

