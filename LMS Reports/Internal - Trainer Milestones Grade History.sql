/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=265&courseid=1 - ALL
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=272&courseid=1 - BSB
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=273&courseid=1 - CHC
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=274&courseid=1 - ICT
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
			-- AND c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 292, 293, 195, 87, 88, 276, 90, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 278, 96, 279, 94, 280, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197 )
			-- AND c.category IN ( 253, 254, 255, 256, 250, 251, 252, 191, 190, 192, 237, 213, 236 )
			-- AND c.category IN ( 102, 103, 244, 245, 248, 108, 149, 109, 137, 110, 111, 112, 113, 159, 115, 231, 136, 249, 232, 263, 233, 117, 160, 118, 119, 120, 121, 122, 123, 124, 133, 132, 134, 135, 138, 143, 125, 151, 126, 127, 128, 129, 130, 226, 208, 261, 262, 267, 264, 265, 266, 51 )
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
			-- AND c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 292, 293, 195, 87, 88, 276, 90, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 278, 96, 279, 94, 280, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197 )
			-- AND c.category IN ( 253, 254, 255, 256, 250, 251, 252, 191, 190, 192, 237, 213, 236 )
			-- AND c.category IN ( 102, 103, 244, 245, 248, 108, 149, 109, 137, 110, 111, 112, 113, 159, 115, 231, 136, 249, 232, 263, 233, 117, 160, 118, 119, 120, 121, 122, 123, 124, 133, 132, 134, 135, 138, 143, 125, 151, 126, 127, 128, 129, 130, 226, 208, 261, 262, 267, 264, 265, 266, 51 )
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

ORDER BY Merged.Grade_Timestamp DESC, Merged.Raw_Trainer_Name ASC, Enrolment_Identifier DESC