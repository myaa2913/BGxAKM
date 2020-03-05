--create bgtjobid by skill table 
SELECT unique_skills.skill_id,unique_skills.skill,unique_skills.skillcluster,unique_skills.skillclusterfamily,bgtjobid_skills.bgtjobid,maintext.soc,date_part('year',maintext.jobdate) AS year INTO temp_skills FROM unique_skills,bgtjobid_skills,maintext WHERE unique_skills.skill_id=bgtjobid_skills.skill_id AND bgtjobid_skills.bgtjobid=maintext.bgtjobid;  















