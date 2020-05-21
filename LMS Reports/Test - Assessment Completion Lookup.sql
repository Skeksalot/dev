/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=248
*/

SELECT CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', CHAR(63), 'id=', cm.id, '">', gi.itemname, '</a>' ) Assessment,
	gg.finalgrade Grade, FROM_UNIXTIME(gg.timemodified) Time_Graded

FROM prefix_course c
JOIN prefix_enrol e ON e.courseid = c.id
JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
JOIN prefix_user u ON u.id = ue.userid
JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
	/*AND TRIM(gi.itemname) REGEXP '((Assessment - (Case and ){0,1}Client Management)[[:>:]])|(Assessment - Client and Case Management Practice)'*/
	AND TRIM(gi.itemname) REGEXP 'Assessment - (Case and ){0,1}Client Management( 4|$)'
JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = u.id
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
LEFT JOIN prefix_user ug ON ug.id = gg.usermodified

WHERE c.fullname REGEXP 'Diploma of Community Services'
AND gg.finalgrade IS NOT NULL 
AND ( gg.finalgrade = 0 OR gg.finalgrade >= 70 )
AND gg.timemodified > UNIX_TIMESTAMP('2019-10-01 00:00:00')

ORDER BY Time_Graded DESC