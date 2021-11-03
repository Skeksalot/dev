/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=267
*/

SELECT Trainer, Student, Course, Assessment, FROM_UNIXTIME(Submit_Time) Submit_Time, Faculty

FROM (
(
	SELECT DISTINCT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainers.trainer_id, '">', Trainers.trainer_name, '</a>' ) Trainer,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Students.student_id, '">', Students.student_name, '</a>' ) Student,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
		s.timemodified Submit_Time,
		CASE
			WHEN c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293, 55, 181 ) THEN 'BSB'
			WHEN c.category IN ( 253, 254, 255, 256, 250, 251, 252, 191, 190, 192, 237, 213, 236 ) THEN 'CHC'
			WHEN c.category IN ( 102, 103, 244, 245, 248, 108, 149, 109, 137, 110, 111, 112, 113, 159, 115, 231, 136, 249, 232, 263, 233, 117, 160, 118, 119, 120, 121, 122, 123, 124, 133, 132, 134, 135, 138, 143, 125, 151, 126, 127, 128, 129, 130, 226, 208, 261, 262, 267, 264, 265, 266, 51 ) THEN 'ICT'
		END Faculty
		
	FROM (
		SELECT DISTINCT e.courseid course_id, u.id student_id, CONCAT(u.firstname, ' ', u.lastname) student_name,
		ue.status student_status, ue.timeend student_end, g.id student_groupid, g.name student_group, x.instanceid student_context_instanceid
		
		FROM prefix_enrol e
		JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
		JOIN prefix_user u ON u.id = ue.userid
		JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
		JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
		LEFT JOIN prefix_groups_members gm ON gm.userid = u.id
		LEFT JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = e.courseid
	) Students
	JOIN (
		SELECT DISTINCT e.courseid course_id, t.id trainer_id, CONCAT(t.firstname, ' ', t.lastname) trainer_name,
		uet.status trainer_status, uet.timeend trainer_end, gt.id trainer_groupid, gt.name trainer_group, xt.instanceid trainer_context_instanceid
		FROM prefix_enrol e
		JOIN prefix_user_enrolments uet ON uet.enrolid = e.id
		JOIN prefix_user t ON t.id = uet.userid
		JOIN prefix_role_assignments rat ON rat.userid = t.id AND rat.roleid IN (3, 4)
		JOIN prefix_context xt ON xt.contextlevel = 50 AND xt.id = rat.contextid AND xt.instanceid = e.courseid
		LEFT JOIN prefix_groups_members gmt ON gmt.userid = t.id
		LEFT JOIN prefix_groups gt ON gt.id = gmt.groupid AND gt.courseid = e.courseid
	) Trainers ON Trainers.course_id = Students.course_id AND Trainers.trainer_id <> Students.student_id
	JOIN prefix_course c ON c.id = Students.course_id
			AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_assign a ON a.course = c.id
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = a.id
	JOIN prefix_assign_submission s ON s.userid = Students.student_id AND s.assignment = a.id

	WHERE LOWER(TRIM(a.name)) LIKE 'kcheck -%'
	AND s.status = 'submitted'
	AND Students.student_status = 0
	AND ( Students.student_end = '' OR DATEDIFF( CURDATE(), FROM_UNIXTIME(Students.student_end) ) <= 0 )
	AND Trainers.trainer_status = 0
	AND ( Trainers.trainer_end = '' OR DATEDIFF( CURDATE(), FROM_UNIXTIME(Trainers.trainer_end) ) <= 0 )
	AND Students.student_groupid IS NULL
	AND YEAR(FROM_UNIXTIME(s.timemodified)) = YEAR( DATE_SUB( CURDATE(), INTERVAL 1 MONTH ) )
	AND MONTH(FROM_UNIXTIME(s.timemodified)) = MONTH( DATE_SUB( CURDATE(), INTERVAL 1 MONTH ) )
)
UNION
(
	SELECT DISTINCT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', t.id, '">', t.firstname, ' ', t.lastname, '</a>' ) Trainer,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
		s.timemodified Submit_Time,
		CASE
			WHEN c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293, 55, 181 ) THEN 'BSB'
			WHEN c.category IN ( 253, 254, 255, 256, 250, 251, 252, 191, 190, 192, 237, 213, 236 ) THEN 'CHC'
			WHEN c.category IN ( 102, 103, 244, 245, 248, 108, 149, 109, 137, 110, 111, 112, 113, 159, 115, 231, 136, 249, 232, 263, 233, 117, 160, 118, 119, 120, 121, 122, 123, 124, 133, 132, 134, 135, 138, 143, 125, 151, 126, 127, 128, 129, 130, 226, 208, 261, 262, 267, 264, 265, 266, 51 ) THEN 'ICT'
		END Faculty
	
	FROM prefix_user u
	JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
	JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid
	JOIN prefix_groups_members gm ON gm.userid = u.id
	JOIN prefix_groups g ON g.id = gm.groupid
	JOIN prefix_course c ON c.id = g.courseid AND c.id = x.instanceid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_groups_members gmt ON gmt.groupid = g.id AND gmt.id <> gm.id
	JOIN prefix_user t ON t.id = gmt.userid AND t.id <> u.id
	JOIN prefix_role_assignments rat ON rat.userid = t.id AND rat.roleid IN (3, 4, 17, 18) AND rat.contextid = x.id
	JOIN prefix_user_enrolments ue ON ue.userid = u.id
	JOIN prefix_enrol e ON e.id = ue.enrolid AND e.courseid = c.id
	JOIN prefix_user_enrolments uet ON uet.userid = t.id AND uet.enrolid = e.id
	JOIN prefix_assign a ON a.course = c.id
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = a.id
	JOIN prefix_assign_submission s ON s.userid = u.id AND s.assignment = a.id
	
	WHERE ue.status = 0
	AND ( ue.timeend = '' OR DATEDIFF( CURDATE(), FROM_UNIXTIME(ue.timeend) ) <= 0 )
	AND uet.status = 0
	AND ( uet.timeend = '' OR DATEDIFF( CURDATE(), FROM_UNIXTIME(uet.timeend) ) <= 0 )
	AND LOWER(TRIM(a.name)) LIKE 'kcheck -%'
	AND s.status = 'submitted'
	AND YEAR(FROM_UNIXTIME(s.timemodified)) = YEAR( DATE_SUB( CURDATE(), INTERVAL 1 MONTH ) )
	AND MONTH(FROM_UNIXTIME(s.timemodified)) = MONTH( DATE_SUB( CURDATE(), INTERVAL 1 MONTH ) )
)
) Merged

ORDER BY Faculty ASC, Submit_Time ASC