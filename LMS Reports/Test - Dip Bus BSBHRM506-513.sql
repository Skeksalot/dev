/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=260&comp=customsql
https://upskilledtest30.androgogic.com.au/blocks/configurable_reports/editcomp.php?id=213&comp=customsql
*/
SELECT DISTINCT Student.Course_Link, Student.Student_Link, Student.Status Student_Status, cs.name Section_Name, cs.section Section_Number,
	GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, ' ~ ', gg.finalgrade, '</a>' ) ORDER BY cm.id SEPARATOR ', <br>' ) Assessment_Link

FROM
(
	SELECT DISTINCT c.id, c.fullname, c.shortname
	FROM prefix_course c
	WHERE c.fullname REGEXP 'Diploma of Business 2'
	AND NOT c.shortname REGEXP 'CVI_'
) Course
JOIN (
	SELECT DISTINCT c.id courseid, u.id userid, u.firstname, u.lastname,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student_Link,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course_Link,
		CASE
			WHEN ( u.suspended = 0 AND ue.status = 0 AND ue.timeend = '' ) THEN 'Active'
			ELSE 'Inactive'
		END Status,
		CONCAT( u.id, c.id ) Enrolment_Identifier

	FROM prefix_course c
	JOIN prefix_enrol e ON e.courseid = c.id
	JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
	JOIN prefix_user u ON u.id = ue.userid
	WHERE c.fullname REGEXP 'Diploma of Business 2'
) Student ON Student.courseid = Course.id
JOIN prefix_course_sections cs ON cs.course = Course.id AND cs.visible = 1
-- AND LOWER(cs.name) REGEXP 'manage workforce planning & manage recruitment, selection & induction processes'
JOIN prefix_course_modules cm ON cm.course = Course.id AND cm.section = cs.id
JOIN prefix_assign a ON a.course = Course.id AND a.id = cm.instance
JOIN prefix_grade_items gi ON gi.courseid = Course.id AND gi.itemname = a.name
JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.userid

WHERE NOT ( a.name REGEXP 'Identification Evidence'
		OR a.name REGEXP 'RPL Kit'
		OR a.name REGEXP 'Credit Transfer'
		OR a.name REGEXP 'LLN Results' )

GROUP BY Student.userid, Course.id, cs.id

ORDER BY Course.id ASC, CONCAT(Student.lastname, Student.firstname) ASC, cs.section ASC