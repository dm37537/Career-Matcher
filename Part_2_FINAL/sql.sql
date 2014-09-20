SELECT distinct AllowedResume.userID, AllowedResume.resumeID, U.name, U.email 
						FROM Users U, Resume_Post R,
							(SELECT R.userID, R.resumeID
							FROM Resume_Post R
							WHERE R.gpa >= (SELECT J.requiredGPA 
											FROM Job_Post J
											WHERE J.userID = 'Holy_name_hospital' AND J.jobID = '1') OR
											(SELECT J.requiredGPA 
											FROM Job_Post J
											WHERE J.userID = 'Holy_name_hospital' AND J.jobID = '1') IS NULL
							INTERSECT
							(
								SELECT R.userID, R.resumeID
								FROM Resume_Post R
								WHERE (R.degree = 'Bachelor' OR R.degree = 'Doctorate' OR R.degree = 'Master') AND EXISTS 
												 (SELECT J.requiredDegree 
												  FROM Job_Post J
												  WHERE J.userID = 'Holy_name_hospital' AND J.jobID = '1' AND J.requiredDegree = 'Bachelor')
								UNION
								SELECT R.userID, R.resumeID
								FROM Resume_Post R
								WHERE (R.degree = 'Doctorate' OR R.degree = 'Master') AND EXISTS 
												 (SELECT J.requiredDegree 
												  FROM Job_Post J
												  WHERE J.userID = 'Holy_name_hospital' AND J.jobID = '1' AND J.requiredDegree = 'Master')
								UNION
								SELECT R.userID, R.resumeID
								FROM Resume_Post R
								WHERE (R.degree = 'Doctorate') AND EXISTS 
												 (SELECT J.requiredDegree 
												  FROM Job_Post J
												  WHERE J.userID = 'Holy_name_hospital' AND J.jobID = '1' AND J.requiredDegree = 'Doctorate')
								UNION
								SELECT R.userID, R.resumeID
								FROM Resume_Post R
								WHERE (SELECT J.requiredDegree 
									   FROM Job_Post J
									   WHERE J.userID = 'Holy_name_hospital' AND J.jobID = '1') IS NULL
							)
							INTERSECT
							Select R.userID, R.resumeID
							FROM Resume_Post R
							WHERE NOT EXISTS(
								(SELECT JRS.skill_ID 
								 FROM Job_Post J, Job_Require_Skill JRS
								 WHERE J.userID = 'Holy_name_hospital' AND J.jobID = '1' AND J.jobID = JRS.jobID AND J.userID = JRS.userID)
								 MINUS(
								 Select RHS.skill_ID
								 FROM Resume_Have_Skill RHS, Job_Require_Skill JRS
								 WHERE RHS.resumeID = R.resumeID AND RHS.userID = R.userID AND JRS.userID = 'Holy_name_hospital' AND JRS.jobID = '1'
									AND JRS.skill_ID = RHS.skill_ID AND (JRS.knowledgeLevel <= RHS.knowledgeLevel OR JRS.knowledgeLevel IS NULL)))) AllowedResume
						WHERE AllowedResume.userID = U.userID AND AllowedResume.resumeID = R.resumeID AND R.status = '1' AND AllowedResume.userID NOT IN (SELECT userID FROM JobSeeker_Apply_Job WHERE jobID='1' AND job_post_userID='Holy_name_hospital')
