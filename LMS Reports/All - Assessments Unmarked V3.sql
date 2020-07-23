/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=181
*/

SELECT Trainer, Student, Course, Assessment, Submit_Time, Grade, Time_Graded, Overdue, Total_Submissions

FROM (
(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainers.trainer_id, '">', Trainers.trainer_name, '</a>' ) SEPARATOR ' ' ) Trainer,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Students.student_id, '">', Students.student_name, '</a>' ) Student,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
		FROM_UNIXTIME(s.timemodified) Submit_Time, ag.grade Grade, '' Group_Name, s.timemodified Time_Stamp,
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
		WHERE u.suspended = 0
		AND ue.status = 0
		AND ue.timeend = ''
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
		WHERE t.suspended = 0
		AND uet.status = 0
		AND uet.timeend = ''
	) Trainers ON Trainers.course_id = Students.course_id AND Trainers.trainer_id <> Students.student_id
	JOIN prefix_course c ON c.id = Students.course_id
			AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_assign a ON a.course = c.id
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = a.id
	JOIN prefix_assign_submission s ON s.userid = Students.student_id AND s.assignment = a.id AND s.latest = 1
	LEFT JOIN prefix_assign_grades ag ON ag.assignment = a.id AND ag.userid = Students.student_id AND (ag.attemptnumber = s.attemptnumber OR s.attemptnumber IS NULL)
	
	WHERE ( s.timemodified IS NOT NULL AND (s.timemodified >= ag.timemodified OR ag.timemodified IS NULL OR ag.grade IS NULL) OR ag.grade = -1 )
	AND (LOWER(TRIM(a.name)) LIKE 'assessment -%' OR LOWER(TRIM(a.name)) LIKE 'kcheck -%')
	AND (ag.grade < 70 OR ag.grade IS NULL)
	AND s.status = 'submitted'
	AND Students.student_groupid IS NULL
  	
	GROUP BY Student, Assessment
)
UNION /* Union used to pair non-grouped students with grouped students from separate queries */
(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainers.trainer_id, '">', Trainers.trainer_name, '</a>' ) SEPARATOR ' ' ) Trainer,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Students.student_id, '">', Students.student_name, '</a>' ) Student,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
		FROM_UNIXTIME(s.timemodified) Submit_Time, ag.grade Grade, '' Group_Name, s.timemodified Time_Stamp,
		'' Time_Graded,
		CASE
			WHEN DATEDIFF( CURDATE(), FROM_UNIXTIME(s.timemodified) ) > 10 THEN "Yes"
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
		JOIN prefix_groups_members gm ON gm.userid = u.id
		JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = e.courseid
		WHERE u.suspended = 0
		AND ue.status = 0
		AND ue.timeend = ''
	) Students
	JOIN (
		SELECT DISTINCT e.courseid course_id, t.id trainer_id, CONCAT(t.firstname, ' ', t.lastname) trainer_name,
		uet.status trainer_status, uet.timeend trainer_end, gt.id trainer_groupid, gt.name trainer_group, xt.instanceid trainer_context_instanceid
		FROM prefix_enrol e
		JOIN prefix_user_enrolments uet ON uet.enrolid = e.id
		JOIN prefix_user t ON t.id = uet.userid
		JOIN prefix_role_assignments rat ON rat.userid = t.id AND rat.roleid IN (3, 4, 17, 18)
		JOIN prefix_context xt ON xt.contextlevel = 50 AND xt.id = rat.contextid AND xt.instanceid = e.courseid
		JOIN prefix_groups_members gmt ON gmt.userid = t.id
		JOIN prefix_groups gt ON gt.id = gmt.groupid AND gt.courseid = e.courseid
		WHERE t.suspended = 0
		AND uet.status = 0
		AND uet.timeend = ''
	) Trainers ON Trainers.course_id = Students.course_id AND Trainers.trainer_id <> Students.student_id AND Trainers.trainer_groupid = Students.student_groupid
	JOIN prefix_course c ON c.id = Students.course_id
			AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_assign a ON a.course = c.id
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = a.id
	JOIN prefix_assign_submission s ON s.userid = Students.student_id AND s.assignment = a.id AND s.latest = 1
	LEFT JOIN prefix_assign_grades ag ON ag.assignment = a.id AND ag.userid = Students.student_id AND (ag.attemptnumber = s.attemptnumber OR s.attemptnumber IS NULL)
	
	WHERE ( s.timemodified IS NOT NULL AND (s.timemodified >= ag.timemodified OR ag.timemodified IS NULL OR ag.grade IS NULL) OR ag.grade = -1 )
	AND (LOWER(TRIM(a.name)) LIKE 'assessment -%' OR LOWER(TRIM(a.name)) LIKE 'kcheck -%')
	AND (ag.grade < 70 OR ag.grade IS NULL)
	AND s.status = 'submitted'
  	
	GROUP BY Student, Assessment
)
) Merged

WHERE 1=1

%%FILTER_SEARCHTEXT:Merged.Trainer:~%%
%%FILTER_STARTTIME:Merged.Time_Stamp:>%%
%%FILTER_ENDTIME:Merged.Time_Stamp:<%%

ORDER BY Submit_Time DESC, Course, Assessment, Student