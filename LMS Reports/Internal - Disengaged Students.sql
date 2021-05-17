/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=304
*/

SELECT DISTINCT Enrolment_Identifier, Student, Course, Trainer, DATEDIFF( CURDATE(), FROM_UNIXTIME(Enrolstart) ) Time_On_Course,
	FROM_UNIXTIME(Last_Access_Timestamp) Last_Access, FROM_UNIXTIME(Last_Submit_Timestamp) Last_Submit

FROM (
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast, '</a>' ) ) Trainer,
		CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		Student.Lastaccess Last_Access_Timestamp,
		MAX( asub.timemodified ) Last_Submit_Timestamp,
		CASE 
			WHEN Student.Timestart <> 0 THEN Student.Timestart
			ELSE Student.Timecreated
		END Enrolstart,
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
		AND t.suspended = 0
		AND ue.status = 0
		AND ue.timeend = ''
	) Trainer
	JOIN
	(
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email, u.lastaccess Lastaccess, ues.timestart Timestart, ues.timecreated Timecreated
		FROM prefix_enrol es
		JOIN prefix_user_enrolments ues ON ues.enrolid = es.id
		JOIN prefix_user u ON u.id = ues.userid
		JOIN prefix_role_assignments ras ON ras.userid = u.id AND ras.roleid = 5
		JOIN prefix_context xs ON xs.contextlevel = 50 AND xs.id = ras.contextid AND xs.instanceid = es.courseid
		
		WHERE u.firstname IS NOT NULL
		AND u.lastname IS NOT NULL
		AND u.suspended = 0
		AND ues.status = 0
		AND ues.timeend = ''
	) Student ON Student.Cid = Trainer.Cid AND Student.Sid <> Trainer.Tid
	JOIN prefix_course c ON c.id = Trainer.Cid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
	LEFT JOIN prefix_assign_submission asub ON asub.userid = Student.Sid AND asub.assignment = gi.iteminstance
	LEFT JOIN prefix_groups_members gm ON gm.userid = Student.Sid
	LEFT JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id
	
	WHERE LOWER(gi.itemname) LIKE 'assessment%'
	AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
	AND g.id IS NULL

	GROUP BY Student.Sid, c.id
	)
	UNION
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast, '</a>' ) ) Trainer,
		CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		Student.Lastaccess Last_Access_Timestamp,
		MAX(asub.timemodified) Last_Submit_Timestamp,
		CASE 
			WHEN Student.Timestart <> 0 THEN Student.Timestart
			ELSE Student.Timecreated
		END Enrolstart,
		CONCAT( Student.Sid, c.id ) Enrolment_Identifier

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
		AND t.suspended = 0
		AND ue.status = 0
		AND ue.timeend = ''
	) Trainer
	JOIN
	(
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email, u.lastaccess Lastaccess, ues.timestart Timestart, ues.timecreated Timecreated
		FROM prefix_enrol es
		JOIN prefix_user_enrolments ues ON ues.enrolid = es.id
		JOIN prefix_user u ON u.id = ues.userid
		JOIN prefix_role_assignments ras ON ras.userid = u.id AND ras.roleid = 5
		JOIN prefix_context xs ON xs.contextlevel = 50 AND xs.id = ras.contextid AND xs.instanceid = es.courseid
		
		WHERE u.firstname IS NOT NULL
		AND u.lastname IS NOT NULL
		AND u.suspended = 0
		AND ues.status = 0
		AND ues.timeend = ''
	) Student ON Student.Cid = Trainer.Cid AND Student.Sid <> Trainer.Tid
	JOIN prefix_course c ON c.id = Trainer.Cid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
	LEFT JOIN prefix_assign_submission asub ON asub.userid = Student.Sid AND asub.assignment = gi.iteminstance AND asub.latest = 1
	JOIN prefix_groups_members gm ON gm.userid = Student.Sid
	JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id
	JOIN prefix_groups_members gmt ON gmt.groupid = g.id AND gmt.userid = Trainer.Tid

	WHERE LOWER(gi.itemname) LIKE 'assessment%'
	AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
	AND g.id IS NOT NULL

	GROUP BY Student.Sid, c.id
	)
) Merged

WHERE Merged.Student IS NOT NULL
AND ( DATEDIFF( CURDATE(), FROM_UNIXTIME(Enrolstart) ) > 730
	OR DATEDIFF( CURDATE(), FROM_UNIXTIME(Last_Access_Timestamp) ) > 60
	OR DATEDIFF( CURDATE(), FROM_UNIXTIME(Last_Submit_Timestamp) ) > 60 )
AND Last_Access_Timestamp <> 0

%%FILTER_SEARCHTEXT:Merged.Trainer:~%%

ORDER BY Last_Access_Timestamp DESC, Last_Submit_Timestamp DESC, Time_On_Course Desc