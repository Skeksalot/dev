/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=291
*/
SELECT DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', char(63), 'id=', Course.id, '">', Course.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', User.id, '">', User.firstname, ' ', User.lastname, '</a>' ) User,
	User.department, FROM_UNIXTIME(UserEnrol.timecreated) Enrol_Date

FROM (
	SELECT DISTINCT *
	FROM prefix_course c
	WHERE c.category = 192
) Course
JOIN prefix_enrol e ON e.courseid = Course.id
JOIN (
	SELECT DISTINCT *
	FROM prefix_user_enrolments ue
	WHERE ue.status = 0
		AND ue.timeend = ''
) UserEnrol ON UserEnrol.enrolid = e.id
JOIN (
	SELECT DISTINCT *
	FROM prefix_user u
	WHERE u.suspended = 0
) User ON User.id = UserEnrol.userid
JOIN prefix_role_assignments ra ON ra.userid = User.id AND ra.roleid = 5
JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid

ORDER BY Course.id DESC