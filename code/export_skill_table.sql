--extract the unique skills table to csv
\copy (SELECT * FROM unique_skills) to '~/bg_skills/BGxAKM/temp/unique_skills.csv' with csv header;














