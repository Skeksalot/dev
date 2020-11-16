/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=283
*/
SELECT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	CASE WHEN auf.locked = 0
		THEN 'Unlocked'
		ELSE 'Locked'
	END Locked,
	auf.mailed,
	CASE WHEN auf.extensionduedate = 0
		THEN ''
		ELSE FROM_UNIXTIME(auf.extensionduedate)
	END Extension

FROM prefix_assign_user_flags auf
JOIN prefix_assign a ON a.id = auf.assignment
JOIN prefix_user u ON u.id = auf.userid
JOIN prefix_course c ON c.id = a.course
JOIN prefix_course_modules cm ON cm.instance = a.id AND cm.course = a.course

WHERE auf.locked = 1