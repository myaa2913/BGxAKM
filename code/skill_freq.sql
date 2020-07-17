\copy (SELECT skill, skill_id,COUNT(bgtjobid) FROM temp_skills GROUP BY	skill,skill_id) to '~/bg_skills/BGxAKM/temp/skill_freq.csv' with csv header;

