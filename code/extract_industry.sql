\copy (SELECT DISTINCT employer,fuzzyemployer,sector,sectorname,naics6 FROM maintext_with_employer) to '~/bg_skills/BGxAKM/temp/employer_info.csv' with csv header;
