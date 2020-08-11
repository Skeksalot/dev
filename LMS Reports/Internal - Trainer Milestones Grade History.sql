/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=265
*/
SELECT DISTINCT Enrolment_Identifier, Trainer, Course, Student, Assessment, Grade, FROM_UNIXTIME(Merged.Grade_Timestamp) Time_Graded, Grader, Assessment_Type

FROM
(
	(
		SELECT DISTINCT
			CONCAT( Student.id, c.id ) Enrolment_Identifier,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.id, '">', Trainer.firstname, ' ', Trainer.lastname, '</a>' ) Trainer,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.id, '">', Student.firstname, ' ', Student.lastname, '</a>' ) Student,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
				CASE
					WHEN cm.module = 13 THEN CONCAT( 'quiz/report.php', CHAR(63), 'id=', cm.id, '">' )
					WHEN cm.module = 15 THEN CONCAT( 'scorm/report.php', CHAR(63), 'id=', cm.id, '">' )
					WHEN cm.module = 21 THEN CONCAT( 'assign/view.php', CHAR(63), 'id=', cm.id, '">' )
					ELSE CONCAT( '"></a><a target="_new" href="%%WWWROOT%%/course/modedit.php?up', 'date=', cm.id, '">' )
				END, gi.itemname, '</a>' ) Assessment,
			IFNULL( gh.finalgrade, 'No Grade') Grade,
			gh.timemodified Grade_Timestamp,
			CASE
				WHEN ( ug.id != Student.id AND gh.finalgrade IS NOT NULL AND cm.module = 21 ) THEN CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', ug.id, '">', ug.firstname, ' ', ug.lastname, '</a>' )
				WHEN ( ug.id = Student.id AND gh.finalgrade IS NOT NULL AND cm.module = 20 ) THEN 'External'
				WHEN ( ug.id = Student.id AND gh.finalgrade IS NOT NULL AND cm.module <> 20 ) THEN 'Auto'
				-- WHEN gh.finalgrade IS NULL THEN ''
				ELSE IFNULL( CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', ug.id, '">', ug.firstname, ' ', ug.lastname, '</a>' ), '' )
			END Grader,
			CASE
				WHEN cm.module = 21 THEN 'Assignment upload'
				WHEN cm.module = 20 THEN 'LTI'
				WHEN cm.module = 15 THEN 'SCORM'
				WHEN cm.module = 13 THEN 'Quiz'
				ELSE 'Unknown' 
			END Assessment_Type,
			CONCAT(Trainer.firstname, ' ', Trainer.lastname) Raw_Trainer_Name

		FROM
		(
			SELECT DISTINCT t.firstname, t.lastname, t.id, e.courseid Cid
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
			SELECT DISTINCT u.firstname, u.lastname, u.id, es.courseid Cid, u.email
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
		) Student ON Student.Cid = Trainer.Cid AND Student.id <> Trainer.id
		JOIN prefix_course c ON c.id = Trainer.Cid
			AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
		JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
		-- JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.id
		JOIN prefix_grade_grades_history gh ON gh.itemid = gi.id AND gh.userid = Student.id
		JOIN prefix_user ug ON ug.id = gh.usermodified
		JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
		LEFT JOIN prefix_groups_members gm ON gm.userid = Student.id
		LEFT JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id

		WHERE LOWER(gi.itemname) LIKE 'assessment -%'
		AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
		AND gi.hidden = 0
		AND g.id IS NULL
		AND gh.finalgrade IS NOT NULL
		AND gh.action IN (1, 2)
		AND ug.id IS NOT NULL
	)
	UNION
	(
		SELECT DISTINCT
			CONCAT( Student.id, c.id ) Enrolment_Identifier,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.id, '">', Trainer.firstname, ' ', Trainer.lastname, '</a>' ) Trainer,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.id, '">', Student.firstname, ' ', Student.lastname, '</a>' ) Student,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
				CASE
					WHEN cm.module = 13 THEN CONCAT( 'quiz/report.php', CHAR(63), 'id=', cm.id, '">' )
					WHEN cm.module = 15 THEN CONCAT( 'scorm/report.php', CHAR(63), 'id=', cm.id, '">' )
					WHEN cm.module = 21 THEN CONCAT( 'assign/view.php', CHAR(63), 'id=', cm.id, '">' )
					ELSE CONCAT( '"></a><a target="_new" href="%%WWWROOT%%/course/modedit.php?up', 'date=', cm.id, '">' )
				END, gi.itemname, '</a>' ) Assessment,
			IFNULL( gh.finalgrade, 'No Grade') Grade,
			gh.timemodified Grade_Timestamp,
			CASE
				WHEN ( ug.id != Student.id AND gh.finalgrade IS NOT NULL AND cm.module = 21 ) THEN CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', ug.id, '">', ug.firstname, ' ', ug.lastname, '</a>' )
				WHEN ( ug.id = Student.id AND gh.finalgrade IS NOT NULL AND cm.module = 20 ) THEN 'External'
				WHEN ( ug.id = Student.id AND gh.finalgrade IS NOT NULL AND cm.module <> 20 ) THEN 'Auto'
				-- WHEN gh.finalgrade IS NULL THEN ''
				ELSE IFNULL( CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', ug.id, '">', ug.firstname, ' ', ug.lastname, '</a>' ), '' )
			END Grader,
			CASE
				WHEN cm.module = 21 THEN 'Assignment upload'
				WHEN cm.module = 20 THEN 'LTI'
				WHEN cm.module = 15 THEN 'SCORM'
				WHEN cm.module = 13 THEN 'Quiz'
				ELSE 'Unknown' 
			END Assessment_Type,
			CONCAT(Trainer.firstname, ' ', Trainer.lastname) Raw_Trainer_Name
		
		FROM
		(
			SELECT DISTINCT t.firstname, t.lastname, t.id, e.courseid Cid
			FROM prefix_enrol e
			JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
			JOIN prefix_user t ON t.id = ue.userid
			JOIN prefix_role_assignments ra ON ra.userid = t.id AND ra.roleid IN (3, 4, 17, 18)
			JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
			
			WHERE t.firstname IS NOT NULL
			AND t.lastname IS NOT NULL
			AND t.suspended = 0
			AND ue.status = 0
			AND ue.timeend = ''
		) Trainer
		JOIN
		(
			SELECT DISTINCT u.firstname, u.lastname, u.id, es.courseid Cid, u.email
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
		) Student ON Student.Cid = Trainer.Cid AND Student.id <> Trainer.id
		JOIN prefix_course c ON c.id = Trainer.Cid
			AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
		JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
		JOIN prefix_grade_grades_history gh ON gh.itemid = gi.id AND gh.userid = Student.id
		JOIN prefix_user ug ON ug.id = gh.usermodified
		JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
		JOIN prefix_groups_members gm ON gm.userid = Student.id
		JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id
		JOIN prefix_groups_members gmt ON gmt.groupid = g.id AND gmt.userid = Trainer.id

		WHERE LOWER(gi.itemname) LIKE 'assessment -%'
		AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
		AND gi.hidden = 0
		AND g.id IS NOT NULL
		AND gh.action IN (1, 2)
		AND gh.finalgrade IS NOT NULL
		AND ug.id IS NOT NULL
	)
) Merged

WHERE Merged.Student IS NOT NULL

%%FILTER_SEARCHTEXT:Merged.Raw_Trainer_Name:~%%
%%FILTER_STARTTIME:Merged.Grade_Timestamp:>%%
%%FILTER_ENDTIME:Merged.Grade_Timestamp:<%%

ORDER BY Merged.Raw_Trainer_Name ASC, Enrolment_Identifier DESC, Merged.Grade_Timestamp DESC