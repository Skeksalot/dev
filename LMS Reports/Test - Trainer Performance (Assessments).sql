/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=182
*/

(
-- MARKED ASSESSMENTS updated 11-6-20
SELECT DISTINCT
-- CONCAT(u.id, a.id, Logs.timecreated) Matcher,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainers.trainer_id, '">', Trainers.trainer_name, '</a>' ) Trainer,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
	FROM_UNIXTIME(s.timemodified) Submit_Time,
	ag.grade Grade,
	FROM_UNIXTIME(Logs.timecreated) Time_Graded,
	CASE
		WHEN DATEDIFF( FROM_UNIXTIME(Logs.timecreated), FROM_UNIXTIME(s.timemodified) ) > 14 THEN "Yes"
		ELSE "No"
	END Overdue,
	'' Total_Submissions
	/*, log.eventname Name, log.component, log.action, log.target, log.objecttable,	log.objectid, log.contextlevel, log.contextinstanceid, log.userid, log.realuserid, log.relateduserid, log.courseid*/

FROM (
	SELECT log.relateduserid, log.realuserid, log.userid, log.courseid, log.objectid, log.timecreated
	FROM prefix_logstore_standard_log log
	WHERE DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 60
	AND LOWER(log.action) LIKE '%graded%'
	AND LOWER(log.target) LIKE '%submission%'
) Logs
JOIN prefix_user u ON u.id = Logs.relateduserid
JOIN prefix_course c ON c.id = Logs.courseid
-- JOIN prefix_user t ON CASE WHEN Logs.realuserid IS NOT NULL THEN t.id = Logs.realuserid ELSE t.id = Logs.userid END
-- JOIN prefix_role_assignments ra ON ra.userid = t.id AND ra.roleid IN (3, 4, 17, 18)
-- JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = c.id
JOIN (
	SELECT DISTINCT e.courseid course_id, t.id trainer_id, CONCAT(t.firstname, ' ', t.lastname) trainer_name,
	uet.status trainer_status, uet.timeend trainer_end, gt.id trainer_groupid, gt.name trainer_group, xt.instanceid trainer_context_instanceid
	FROM prefix_enrol e
	JOIN prefix_user_enrolments uet ON uet.enrolid = e.id
	JOIN prefix_user t ON t.id = uet.userid
	JOIN prefix_role_assignments rat ON rat.userid = t.id AND rat.roleid IN (3, 4, 17, 18)
	JOIN prefix_context xt ON xt.contextlevel = 50 AND xt.id = rat.contextid AND xt.instanceid = e.courseid
	LEFT JOIN prefix_groups_members gmt ON gmt.userid = t.id
	LEFT JOIN prefix_groups gt ON gt.id = gmt.groupid AND gt.courseid = e.courseid
	AND t.suspended = 0
	AND uet.status = 0
	AND uet.timeend = ''
) Trainers ON Trainers.course_id = c.id AND CASE WHEN Logs.realuserid IS NOT NULL THEN Trainers.trainer_id = Logs.realuserid ELSE Trainers.trainer_id = Logs.userid END
JOIN prefix_assign_grades ag ON ag.id = Logs.objectid
JOIN prefix_assign a ON a.id = ag.assignment
JOIN prefix_course_modules cm ON cm.instance = a.id AND cm.course = c.id
JOIN prefix_assign_submission s ON s.userid = u.id AND s.assignment = a.id AND s.attemptnumber = ag.attemptnumber

WHERE LOWER(a.name) LIKE 'assessment%'
)
UNION
(
-- UNMARKED ASSESSMENTS (NO GROUPS) updated 11-6-20
SELECT DISTINCT
	GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainers.trainer_id, '">', Trainers.trainer_name, '</a>' ) SEPARATOR ' ' ) Trainer,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Students.student_id, '">', Students.student_name, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
	FROM_UNIXTIME(s.timemodified) Submit_Time,
	ag.grade Grade,
	'' Time_Graded,
	CASE
		WHEN DATEDIFF( CURDATE(), FROM_UNIXTIME(s.timemodified) ) > 14 THEN "Yes"
		ELSE "No"
	END Overdue,
	'' Total_Submissions
	
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
JOIN prefix_assign_submission s ON s.userid = Students.student_id AND s.assignment = a.id AND s.latest = 1
LEFT JOIN prefix_assign_grades ag ON ag.assignment = a.id AND ag.userid = Students.student_id AND (ag.attemptnumber = s.attemptnumber OR s.attemptnumber IS NULL)

WHERE (s.timemodified IS NOT NULL
AND (s.timemodified >= ag.timemodified OR ag.timemodified IS NULL OR ag.grade IS NULL) OR ag.grade = -1)
AND LOWER(TRIM(a.name)) LIKE 'assessment -%'
AND (ag.grade < 70 OR ag.grade IS NULL)
AND s.status = 'submitted'
AND Students.student_status = 0
AND Students.student_end = ''
AND Trainers.trainer_status = 0
AND Trainers.trainer_end = ''
AND Students.student_groupid IS NULL

GROUP BY Student, Assessment
)
UNION
(
-- UNMARKED ASSESSMENTS (GROUPS) updated 11-6-20
SELECT DISTINCT 
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', t.id, '">', t.firstname, ' ', t.lastname, '</a>' ) Trainer,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
	FROM_UNIXTIME(s.timemodified) Submit_Time,
	ag.grade Grade,
	'' Time_Graded,
	CASE
		WHEN DATEDIFF( CURDATE(), FROM_UNIXTIME(s.timemodified) ) > 14 THEN "Yes"
		ELSE "No"
	END Overdue,
	'' Total_Submissions

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
/*JOIN prefix_enrol et ON et.id = uet.enrolid AND et.courseid = c.id*/
JOIN prefix_assign a ON a.course = c.id
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = a.id
JOIN prefix_assign_submission s ON s.userid = u.id AND s.assignment = a.id AND s.latest = 1
LEFT JOIN prefix_assign_grades ag ON ag.assignment = a.id AND ag.userid = u.id AND (ag.attemptnumber = s.attemptnumber OR s.attemptnumber IS NULL)

WHERE ue.status = 0
AND ue.timeend = ''
AND uet.status = 0
AND uet.timeend = ''
AND (s.timemodified IS NOT NULL
AND (s.timemodified >= ag.timemodified OR ag.timemodified IS NULL OR ag.grade IS NULL) OR ag.grade = -1)
AND LOWER(TRIM(a.name)) LIKE 'assessment -%'
AND (ag.grade < 70 OR ag.grade IS NULL)
AND s.status = 'submitted'
)
UNION
(
-- COUNT TOTAL SUBMISSIONS - Updated 11-6-20
SELECT Trainer, '' Student, '' Course, '' Assessment, '' Submit_Time, '' Grade, '' Time_Graded, '' Overdue, COUNT(Submissions) Total_Submissions

FROM (
(
	SELECT DISTINCT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainers.trainer_id, '">', Trainers.trainer_name, '</a>' ) Trainer,
		Students.student_id Student,
		c.id Course,
		a.id Assessment,
		s.timemodified Submit_Time,
		'' Grade,
		'' Time_Graded,
		'' Overdue,
		'1' Submissions
		
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

	WHERE LOWER(TRIM(a.name)) LIKE 'assessment -%'
	AND s.status = 'submitted'
	AND Students.student_status = 0
	AND Students.student_end = ''
	AND Trainers.trainer_status = 0
	AND Trainers.trainer_end = ''
	AND Students.student_groupid IS NULL
	AND DATEDIFF( CURDATE(), FROM_UNIXTIME(s.timemodified) ) <= 60
)
UNION
(
	SELECT DISTINCT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', t.id, '">', t.firstname, ' ', t.lastname, '</a>' ) Trainer,
		u.id Student,
		c.id Course,
		a.id Assessment,
		s.timemodified Submit_Time,
		'' Grade,
		'' Time_Graded,
		'' Overdue,
		'1' Submissions
	
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
	AND ue.timeend = ''
	AND uet.status = 0
	AND uet.timeend = ''
	AND LOWER(TRIM(a.name)) LIKE 'assessment -%'
	AND s.status = 'submitted'
	AND DATEDIFF( CURDATE(), FROM_UNIXTIME(s.timemodified) ) <= 60
)
) Merged

GROUP BY Trainer
)

ORDER BY Trainer, Total_Submissions, Overdue DESC, Submit_Time DESC, Time_Graded DESC