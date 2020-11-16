/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=263
*/
SELECT DISTINCT
	CONCAT( Student.Sid, c.id ) Enrolment_Identifier,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast, '</a>' ) Trainer,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
		CASE
			WHEN cm.module = 13 THEN CONCAT( 'quiz/report.php', CHAR(63), 'id=', cm.id, '">' )
			WHEN cm.module = 15 THEN CONCAT( 'scorm/report.php', CHAR(63), 'id=', cm.id, '">' )
			WHEN cm.module = 21 THEN CONCAT( 'assign/view.php', CHAR(63), 'id=', cm.id, '">' )
			ELSE CONCAT( '"></a><a target="_new" href="%%WWWROOT%%/course/modedit.php?up', 'date=', cm.id, '">' )
		END, gi.itemname, '</a>' ) Assessment,
	IFNULL( gg.finalgrade, 'No Grade') Grade,
	FROM_UNIXTIME(gg.timemodified) Grade_Time,
	CASE
		WHEN ( ug.id != Student.Sid AND gg.finalgrade IS NOT NULL AND cm.module = 21 ) THEN CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', ug.id, '">', ug.firstname, ' ', ug.lastname, '</a>' )
		WHEN ( ug.id = Student.Sid AND gg.finalgrade IS NOT NULL AND cm.module = 20 ) THEN 'External '
		WHEN ( ug.id = Student.Sid AND gg.finalgrade IS NOT NULL AND cm.module <> 20 ) THEN 'Auto '
		WHEN gg.finalgrade IS NULL THEN ''
		ELSE IFNULL( CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', ug.id, '">', ug.firstname, ' ', ug.lastname, '</a>' ), '' )
	END Grader,
	CASE
		WHEN cm.module = 21 THEN 'Assignment upload'
		WHEN cm.module = 20 THEN 'LTI'
		WHEN cm.module = 15 THEN 'SCORM'
		WHEN cm.module = 13 THEN 'Quiz'
		ELSE 'Unknown'
	END Assessment_Type

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
	SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email
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
JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.Sid
JOIN prefix_user ug ON ug.id = gg.usermodified
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
LEFT JOIN prefix_groups_members gm ON gm.userid = Student.Sid
LEFT JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id

WHERE LOWER(gi.itemname) LIKE 'assessment -%'
AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
AND gi.hidden = 0
AND g.id IS NULL

%%FILTER_SEARCHTEXT:CONCAT(ug.firstname, ' ', ug.lastname):~%%
%%FILTER_STARTTIME:gg.timemodified:>%%
%%FILTER_ENDTIME:gg.timemodified:<%%

ORDER BY CONCAT(Trainer.Tfirst, ' ', Trainer.Tlast) ASC, Enrolment_Identifier DESC, Grade_Time DESC