SELECT DISTINCT Trainer, Course, Student, Enrolment_Identifier, FROM_UNIXTIME(Last_Grade_Timestamp) Last_Grade, 
	/*Assessments,*/
	Completed_Assessment_Items, Total_Assessment_Items, ( Completed_Assessment_Items / Total_Assessment_Items ) * 100 Percent_Complete,
	CASE WHEN ( Completed_Assessment_Items >= 3 )
		THEN 'Yes'
		ELSE 'No'
	END Milestone1_Status,
	CASE WHEN ( Completed_Assessment_Items >= ROUND( Total_Assessment_Items * 0.6 ) )
		THEN 'Yes'
		ELSE 'No'
	END Milestone2_Status
	/*, Restrictions*/
	/*, Group_Name*/

FROM (
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast, '</a>' ) ) Trainer,
		CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
			CASE
				WHEN cm.module = 13
					THEN 'quiz/report.php'
				WHEN cm.module = 15
					THEN 'scorm/report.php'
				WHEN cm.module = 21
					THEN 'assign/view.php'
				END, CHAR(63), 'id=', cm.id, '">', gi.itemname, ' - ', IFNULL(gg.finalgrade, 0), '</a><br>' ) ORDER BY cm.id  SEPARATOR '' ) Assessments,
		COUNT(gi.iteminstance) Total_Assessment_Items,
		SUM( CASE
			WHEN (gg.finalgrade/gg.rawgrademax >= 0.70) 
				THEN 1
			ELSE 0 
		END	) Completed_Assessment_Items,
		MAX(gg.timemodified) Last_Grade_Timestamp,
		CASE
			WHEN cc.timecompleted IS NOT NULL THEN 'Yes'
			ELSE 'No'
		END Completed_Course,
		g.name Group_Name, c.id Cid,
		GROUP_CONCAT( cm.availability SEPARATOR '\n' ) Restrictions,
		CONCAT( Student.Sid, c.id ) Enrolment_Identifier

	FROM
	(
		SELECT DISTINCT t.firstname Tfirst, t.lastname Tlast, t.id Tid, e.courseid Cid
		FROM prefix_enrol e
		JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
		JOIN prefix_user t ON t.id = ue.userid
		JOIN prefix_role_assignments ra ON ra.userid = t.id AND ra.roleid IN (3, 4)
		JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
		
		WHERE t.firstname IS NOT NULL
		AND t.lastname IS NOT NULL
		/*AND t.suspended = 0
		AND ue.status = 0
		AND ue.timeend = ''*/
	) Trainer
	JOIN
	(
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email, u.lastaccess Lastaccess, ues.timeend Enddate
		FROM prefix_enrol es
		JOIN prefix_user_enrolments ues ON ues.enrolid = es.id
		JOIN prefix_user u ON u.id = ues.userid
		JOIN prefix_role_assignments ras ON ras.userid = u.id AND ras.roleid = 5
		JOIN prefix_context xs ON xs.contextlevel = 50 AND xs.id = ras.contextid AND xs.instanceid = es.courseid
		
		WHERE u.firstname IS NOT NULL
		AND u.lastname IS NOT NULL
		/*AND u.suspended = 0
		AND ues.status = 0
		AND ues.timeend = ''*/
	) Student ON Student.Cid = Trainer.Cid AND Student.Sid <> Trainer.Tid
	JOIN prefix_course c ON c.id = Trainer.Cid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
	LEFT JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.Sid
	LEFT JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	JOIN prefix_course_completions cc ON cc.userid = Student.Sid AND cc.course = c.id
	LEFT JOIN prefix_groups_members gm ON gm.userid = Student.Sid
	LEFT JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id
	
	WHERE LOWER(gi.itemname) LIKE 'assessment%'
	AND gi.hidden = 0
	AND g.id IS NULL
	AND cm.visible = 1
	AND ( ( cm.availability IS NULL ) OR ( cm.availability LIKE CONCAT('%"op":"|","c"%', '{"type":"profile","sf":"email","op":"isequalto","v":"', Student.Email, '"}%') ) )
	
  	GROUP BY Student.Sid, c.id
	)
	UNION
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT(  '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast,  '</a>'  ) ) Trainer,
		CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
			CASE
				WHEN cm.module = 13
					THEN 'quiz/report.php'
				WHEN cm.module = 15
					THEN 'scorm/report.php'
				WHEN cm.module = 21
					THEN 'assign/view.php'
				END, CHAR(63), 'id=', cm.id, '">', gi.itemname, ' - ', IFNULL(gg.finalgrade, 0), '</a><br>' ) ORDER BY cm.id  SEPARATOR '' ) Assessments,
		COUNT(gi.iteminstance) Total_Assessment_Items,
		SUM( CASE
			WHEN (gg.finalgrade/gg.rawgrademax >= 0.70) 
				THEN 1
			ELSE 0 
		END	) Completed_Assessment_Items,
		MAX(gg.timemodified) Last_Grade_Timestamp,
		CASE
			WHEN cc.timecompleted IS NOT NULL THEN 'Yes'
			ELSE 'No'
		END Completed_Course,
		g.name Group_Name, c.id Cid,
		GROUP_CONCAT( cm.availability SEPARATOR '\n' ) Restrictions,
		CONCAT( Student.Sid, c.id ) Enrolment_Identifier

	FROM
	(
		SELECT DISTINCT t.firstname Tfirst, t.lastname Tlast, t.id Tid, e.courseid Cid
		FROM prefix_enrol e
		JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
		JOIN prefix_user t ON t.id = ue.userid
		JOIN prefix_role_assignments ra ON ra.userid = t.id AND ra.roleid IN (3, 4)
		JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
		
		WHERE t.firstname IS NOT NULL
		AND t.lastname IS NOT NULL
		/*AND t.suspended = 0
		AND ue.status = 0
		AND ue.timeend = ''*/
	) Trainer
	JOIN
	(
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email, u.lastaccess Lastaccess, ues.timeend Enddate
		FROM prefix_enrol es
		JOIN prefix_user_enrolments ues ON ues.enrolid = es.id
		JOIN prefix_user u ON u.id = ues.userid
		JOIN prefix_role_assignments ras ON ras.userid = u.id AND ras.roleid = 5
		JOIN prefix_context xs ON xs.contextlevel = 50 AND xs.id = ras.contextid AND xs.instanceid = es.courseid
		
		WHERE u.firstname IS NOT NULL
		AND u.lastname IS NOT NULL
		/*AND u.suspended = 0
		AND ues.status = 0
		AND ues.timeend = ''*/
	) Student ON Student.Cid = Trainer.Cid AND Student.Sid <> Trainer.Tid
	JOIN prefix_course c ON c.id = Trainer.Cid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
	LEFT JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.Sid
	LEFT JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	JOIN prefix_course_completions cc ON cc.userid = Student.Sid AND cc.course = c.id
	JOIN prefix_groups_members gm ON gm.userid = Student.Sid
	JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id
	JOIN prefix_groups_members gmt ON gmt.groupid = g.id AND gmt.userid = Trainer.Tid
	
	WHERE LOWER(gi.itemname) LIKE 'assessment%'
	AND gi.hidden = 0
	AND g.id IS NOT NULL
	AND cm.visible = 1
	AND ( ( cm.availability IS NULL ) OR ( cm.availability LIKE CONCAT('%"op":"|","c"%', '{"type":"profile","sf":"email","op":"isequalto","v":"', Student.Email, '"}%') ) )
	
  	GROUP BY Student.Sid, c.id
	)
) Merged

WHERE Merged.Student IS NOT NULL
AND ( Merged.Completed_Assessment_Items >= 3 OR ( Merged.Completed_Assessment_Items >= ROUND( Merged.Total_Assessment_Items * 0.6 ) ) )

%%FILTER_SEARCHTEXT:Merged.Trainer:~%%
%%FILTER_STARTTIME:Merged.Last_Grade_Timestamp:>%%
%%FILTER_ENDTIME:Merged.Last_Grade_Timestamp:<%%

ORDER BY Milestone2_Status ASC, Last_Grade DESC, Percent_Complete DESC