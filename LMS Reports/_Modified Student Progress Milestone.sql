/* https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=243&courseid=1 */

SELECT *
FROM (
	SELECT
		Trainer,
		Course,
		Student,
		Enrolment_Identifier,
		FROM_UNIXTIME(Last_Grade_Timestamp) Last_Grade,
		/*Assessments,*/
		Completed_Assessment_Items,
		Total_Assessment_Items,
		( Completed_Assessment_Items / Total_Assessment_Items ) * 100 Percent_Complete,
		CASE WHEN ( Completed_Assessment_Items >= 3 )
			THEN 'Yes'
			ELSE 'No'
		END Milestone1_Status,
		CASE WHEN ( Completed_Assessment_Items >= ROUND( Total_Assessment_Items * 0.6 ) )
			THEN 'Yes'
			ELSE 'No'
		END Milestone2_Status
		/*, Restrictions*/
		/*, Group_Name*/
	FROM (
		SELECT
			(
				SELECT GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', t.id, '">', t.firstname, ' ', t.lastname, '</a>' ) )
				FROM prefix_user t
				JOIN prefix_context x ON x.contextlevel = 50
				JOIN prefix_role_assignments ra ON ra.contextid = x.id AND ra.userid = t.id AND ra.roleid IN (3, 4)
				WHERE x.instanceid = c.id
			) Trainer,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', CHAR(63), 'id=', c.id, '">', c.id, ' : ', c.shortname, '</a>' ) Course,
			CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', u.id, '">', u.id, ' : ', u.firstname, ' ', u.lastname, '</a>' ) Student,
			GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
				CASE
					WHEN cm.module = 13
						THEN 'quiz/report.php'
					WHEN cm.module = 15
						THEN 'scorm/report.php'
					WHEN cm.module = 21
						THEN 'assign/view.php'
					END, CHAR(63), 'id=', cm.id, '">', gi.itemname, ' - ', IFNULL(gg.finalgrade, 0), '</a><br>' ) ORDER BY cm.id  SEPARATOR '' ) Assessments,
			/*GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', gi.itemname, ' : ', CASE WHEN cm.availability IS NOT NULL THEN cm.availability ELSE '' END, '</a><br>' ) ORDER BY a.name  SEPARATOR '' ) Assessments,*/
			COUNT(gi.iteminstance) Total_Assessment_Items,
			SUM( CASE
				WHEN (gg.finalgrade/gg.rawgrademax >= 0.70) 
					THEN 1
				ELSE 0 
			END	) Completed_Assessment_Items,
			MAX(gg.timemodified) AS Last_Grade_Timestamp,
			CASE
				WHEN cc.timecompleted IS NOT NULL THEN 'yes'
				ELSE 'no'
			END Completed_Course,
			GROUP_CONCAT( cm.availability SEPARATOR '\n' ) Restrictions,
			CONCAT( u.id, c.id ) Enrolment_Identifier
		FROM
		prefix_user u
		JOIN prefix_user_enrolments ue ON ue.userid = u.id
		JOIN prefix_enrol e ON e.id = ue.enrolid
		JOIN prefix_course c ON c.id = e.courseid AND c.shortname NOT LIKE '%LLN%'
			AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
		JOIN prefix_context x ON x.contextlevel = 50 AND x.instanceid = c.id
		JOIN prefix_role_assignments ra ON ra.contextid = x.id AND ra.userid = u.id AND ra.roleid = 5
		JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
		LEFT JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = u.id
		LEFT JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
		LEFT JOIN prefix_course_completions cc ON cc.userid = u.id AND cc.course = c.id

		WHERE LOWER(gi.itemname) LIKE 'assessment%'
		AND gi.itemname <> 'Assessment - IT Foundations Course'
		AND ue.status = 0
		AND ue.timeend = ''
		AND cm.visible = 1
		AND ( ( cm.availability IS NULL ) OR ( cm.availability LIKE CONCAT('%"op":"|","c"%', '{"type":"profile","sf":"email","op":"isequalto","v":"', u.email, '"}%') ) )
		
		GROUP BY Course, Student, Completed_Course
	) cmp
	WHERE Student IS NOT NULL
) cmp60
WHERE (Milestone1_Status LIKE 'Yes' OR Milestone2_Status LIKE 'Yes')

%%FILTER_SEARCHTEXT:cmp.Trainer:~%%
%%FILTER_STARTTIME:cmp.Last_Grade_Timestamp:>%%
%%FILTER_ENDTIME:cmp.Last_Grade_Timestamp:<%%

ORDER BY Milestone2_Status ASC, Last_Grade DESC, Percent_Complete DESC