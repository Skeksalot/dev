/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=173
*/

SELECT DISTINCT
	CONCAT( Student.Sid, a.id, gg.timemodified ) Matcher,
	/*CONCAT( t.firstname, ' ', t.lastname ) Trainer,*/
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
	/*FROM_UNIXTIME(s.timemodified) Submit_Time,*/
	ROUND( gg.finalgrade, 1 ) Grade,
	FROM_UNIXTIME(gg.timemodified) Time_Graded
	/*, CASE
		WHEN DATEDIFF( FROM_UNIXTIME(gg.timemodified), FROM_UNIXTIME(s.timemodified) ) >= 10 THEN "Yes"
		ELSE "No"
	END Overdue, '' Total_Submissions*/
	
FROM (
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email, u.lastaccess Lastaccess, ues.timeend Enddate
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
) Student
JOIN prefix_grade_grades gg ON gg.userid = Student.Sid AND DATEDIFF( CURDATE(), FROM_UNIXTIME(gg.timemodified) ) <= 7
JOIN prefix_grade_items gi ON gi.id = gg.itemid
JOIN prefix_course c ON gi.courseid = c.id
	AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
JOIN prefix_assign a ON a.course = c.id AND a.name = gi.itemname
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = a.id
LEFT JOIN prefix_assign_submission s ON s.userid = Student.Sid AND s.assignment = a.id AND s.latest = 1

WHERE gi.itemname IS NOT NULL
AND (gi.itemtype = 'mod' OR gi.itemtype = 'manual')
-- AND gi.itemmodule <> 'scorm'
AND gg.timemodified IS NOT NULL
AND LOWER(gi.itemname) LIKE 'assessment -%'

ORDER BY Time_Graded DESC