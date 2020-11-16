/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=285&comp=customsql
*/
SELECT DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', char(63), 'id=', c.id, '">', c.fullname, '</a>' ) Course,
	c.shortname Course_Shortname,
	COUNT( Students.id ) Students

FROM (
	SELECT DISTINCT e.courseid course_id, u.id, CONCAT(u.firstname, ' ', u.lastname) student_name, u.suspended, 
	ue.status, ue.timeend, g.id student_groupid, g.name student_group, x.instanceid student_context_instanceid
	
	FROM prefix_enrol e
	JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
	JOIN prefix_user u ON u.id = ue.userid
	JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
	JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
	LEFT JOIN prefix_groups_members gm ON gm.userid = u.id
	LEFT JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = e.courseid
) Students
JOIN prefix_course c ON c.id = Students.course_id
		AND c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293, 55, 181 )

WHERE Students.status = 0
AND Students.timeend = ''
AND Students.suspended = 0

GROUP BY c.id

ORDER BY c.shortname