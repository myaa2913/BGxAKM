--create unique bgtjobid X skill_id TEMP_SKILLS sql table
SELECT unique_skills_tweak.skill_id,
       unique_skills_tweak.skill,
       unique_skills_tweak.skillcluster,
       unique_skills_tweak.skillclusterfamily,
       bgtjobid_skills.bgtjobid,
       maintext.soc,
       date_part('year',maintext.jobdate) AS year
INTO temp_skills
FROM unique_skills_tweak,bgtjobid_skills,maintext
WHERE unique_skills_tweak.skill_id=bgtjobid_skills.skill_id AND bgtjobid_skills.bgtjobid=maintext.bgtjobid;  
















