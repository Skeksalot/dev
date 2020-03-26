SELECT DISTINCT Trainer, Course, Student, FROM_UNIXTIME(Last_Grade_Timestamp) Last_Grade, Completed_Assessment_Items, Total_Assessment_Items,
	CASE WHEN ( (Completed_Assessment_Items >= 3) & (Completed_Assessment_Items < ROUND(Total_Assessment_Items * 0.6) ) ) THEN 'yes' ELSE 'no' END AS Completed_3_Items,
	(Completed_Assessment_Items / Total_Assessment_Items)*100 Percent_Complete
	/*, Group_Name*/

FROM (
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT(  '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast,  '</a>'  ) ) Trainer,
		CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', char(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		COUNT(gi.iteminstance) AS Total_Assessment_Items,
		SUM( CASE WHEN ( gg.finalgrade/gg.rawgrademax > 0.7 ) THEN 1 ELSE 0 END ) AS Completed_Assessment_Items,
		MAX(gg.timemodified) AS Last_Grade_Timestamp,
		CASE WHEN cc.timecompleted IS NOT NULL THEN 'yes' ELSE 'no' END AS Completed_Course,
		g.name Group_Name, c.id Cid
  	
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
		AND c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293 )	
	JOIN prefix_grade_items gi ON c.id = gi.courseid
	LEFT JOIN prefix_grade_grades gg ON gi.id = gg.itemid AND gg.userid = Student.Sid
	JOIN prefix_course_completions cc ON cc.userid = Student.Sid AND cc.course = c.id
	LEFT JOIN prefix_groups_members gm ON gm.userid = Student.Sid
	LEFT JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id
	
	WHERE c.shortname IS NOT NULL
	AND gi.itemtype = 'mod'
	AND LOWER(gi.itemname) LIKE 'assessment%'
	AND gi.hidden = 0
	AND g.id IS NULL
	
  	GROUP BY Student.Sid, c.id
	)
	UNION
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT(  '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast,  '</a>'  ) ) Trainer,
		CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', char(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		COUNT(gi.iteminstance) AS Total_Assessment_Items,
		SUM( CASE WHEN ( gg.finalgrade/gg.rawgrademax > 0.7 ) THEN 1 ELSE 0 END ) AS Completed_Assessment_Items,
		MAX(gg.timemodified) AS Last_Grade_Timestamp,
		CASE WHEN cc.timecompleted IS NOT NULL THEN 'yes' ELSE 'no' END AS Completed_Course,
		g.name Group_Name, c.id Cid
  	
	FROM
	(
		SELECT DISTINCT t.firstname Tfirst, t.lastname Tlast, t.id Tid, e.courseid Cid
		FROM prefix_enrol e
		JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
		JOIN prefix_user t ON t.id = ue.userid
		JOIN prefix_role_assignments ra ON ra.userid = t.id AND ra.roleid IN (3, 4, 17, 18)
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
		AND c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293 )
	JOIN prefix_grade_items gi ON c.id = gi.courseid
	LEFT JOIN prefix_grade_grades gg ON gi.id = gg.itemid AND gg.userid = Student.Sid
	JOIN prefix_course_completions cc ON cc.userid = Student.Sid AND cc.course = c.id
	JOIN prefix_groups_members gm ON gm.userid = Student.Sid
	JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id
	JOIN prefix_groups_members gmt ON gmt.groupid = g.id AND gmt.userid = Trainer.Tid
	
	WHERE c.shortname IS NOT NULL
	AND gi.itemtype = 'mod'
	AND LOWER(gi.itemname) LIKE 'assessment%'
	AND gi.hidden = 0
	AND g.id IS NOT NULL
	
  	GROUP BY Student.Sid, c.id
	)
) Merged

WHERE Merged.Student IS NOT NULL
AND Merged.Completed_Assessment_Items >= 3
AND Merged.Completed_Assessment_Items < ROUND(Merged.Total_Assessment_Items * 0.6)

%%FILTER_SEARCHTEXT:Merged.Trainer:~%%
%%FILTER_STARTTIME:Merged.Last_Grade_Timestamp:>%%
%%FILTER_ENDTIME:Merged.Last_Grade_Timestamp:<%%

ORDER BY Last_Grade DESC, Merged.Cid, Student