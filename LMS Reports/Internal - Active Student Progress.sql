/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=243
https://www.guru99.com/regular-expressions.html
*/

SELECT DISTINCT Enrolment_Identifier, Student, Course, Trainer, Assessments,
	FROM_UNIXTIME(Last_Submit_Timestamp) Last_Submit, FROM_UNIXTIME(Last_Grade_Timestamp) Last_Grade,
	Completed_Assessment_Items, Total_Assessment_Items,
	( Completed_Assessment_Items / (Total_Assessment_Items - CT_Granted) ) * 100 Completion
--	, Restrictions
--	, Selector
--	, Group_Name

FROM (
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast, '</a>' ) ) Trainer,
		CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
			CASE
				WHEN cm.module = 13 THEN CONCAT( 'quiz/report.php', CHAR(63), 'id=', cm.id, '">' )
				WHEN cm.module = 15 THEN CONCAT( 'scorm/report.php', CHAR(63), 'id=', cm.id, '">' )
				WHEN cm.module = 21 THEN CONCAT( 'assign/view.php', CHAR(63), 'id=', cm.id, '">' )
				ELSE CONCAT( '"></a><a target="_new" href="%%WWWROOT%%/course/modedit.php?up', 'date=', cm.id, '">' )
			END, gi.itemname, ' <b>(', 
			CASE
				WHEN ( ug.id = Student.Sid AND gg.finalgrade IS NOT NULL AND cm.module = 21 ) THEN CONCAT( Trainer.Tfirst, ' ', Trainer.Tlast, ' ' )
				WHEN ( ug.id = Student.Sid AND gg.finalgrade IS NOT NULL AND cm.module = 20 ) THEN 'External '
				WHEN ( ug.id = Student.Sid AND gg.finalgrade IS NOT NULL AND cm.module <> 20 ) THEN 'Auto '
				WHEN gg.finalgrade IS NULL THEN ''
				ELSE IFNULL( CONCAT( ug.firstname, ' ', ug.lastname, ' ' ), '' )
			END, IFNULL( gg.finalgrade, 'No Grade'), ')</b></a>' ) ORDER BY cm.id SEPARATOR '<br> ' ) Assessments,
		COUNT(gi.iteminstance) Total_Assessment_Items,
		SUM( CASE
				WHEN ( ( gg.finalgrade / gg.rawgrademax > 0.70 ) AND cm.module <> 15 ) THEN 1
				ELSE 0
			END ) Completed_Assessment_Items,
		SUM( CASE
				WHEN gg.finalgrade = 0 THEN 1
				ELSE 0
			END ) CT_Granted,
		MAX(asub.timemodified) Last_Submit_Timestamp,
		MAX(gg.timemodified) Last_Grade_Timestamp,
		g.name Group_Name, c.id Cid,
		CONCAT( Student.Sid, c.id ) Enrolment_Identifier
		/*, GROUP_CONCAT( cm.availability SEPARATOR '<br>' ) Restrictions,
		GROUP_CONCAT( CASE WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}'
			THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
		WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(>=)","t":[0-9]{1,}},{0,1}){1,}'
			THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
		WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 1
		WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 0
		WHEN cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 0
		WHEN cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 1
		WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 0
		WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 1
		END SEPARATOR ' ' ) Selector,
		CONCAT( Student.Sid, c.id ) Enrolment_Identifier */

	FROM
	(
		SELECT DISTINCT t.firstname Tfirst, t.lastname Tlast, t.id Tid, e.courseid Cid
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
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email, u.lastaccess Lastaccess, ues.timeend Enddate
		FROM prefix_enrol es
		JOIN prefix_user_enrolments ues ON ues.enrolid = es.id
		JOIN prefix_user u ON u.id = ues.userid
		JOIN prefix_role_assignments ras ON ras.userid = u.id AND ras.roleid = 5
		JOIN prefix_context xs ON xs.contextlevel = 50 AND xs.id = ras.contextid AND xs.instanceid = es.courseid
		
		WHERE u.firstname IS NOT NULL
		AND u.lastname IS NOT NULL
		AND u.suspended = 0
		AND ues.status = 0
		AND ues.timeend = ''
	) Student ON Student.Cid = Trainer.Cid AND Student.Sid <> Trainer.Tid
	JOIN prefix_course c ON c.id = Trainer.Cid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
	LEFT JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.Sid
	LEFT JOIN prefix_user ug ON ug.id = gg.usermodified
	LEFT JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	LEFT JOIN prefix_assign_submission asub ON asub.userid = Student.Sid AND asub.assignment = gi.iteminstance AND asub.latest = 1
	LEFT JOIN prefix_groups_members gm ON gm.userid = Student.Sid
	LEFT JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id
	
	WHERE LOWER(gi.itemname) LIKE 'assessment%'
	AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
	AND gi.hidden = 0
	AND g.id IS NULL
	AND cm.visible = 1
	AND IFNULL( CASE
					WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
					WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(>=)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
					WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 1
					WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 0
					WHEN cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 0
					WHEN cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 1
					WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 0
					WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 1
				END, 1 ) = 1

	GROUP BY Student.Sid, c.id
-- HAVING Selector IS NOT NULL
	)
	UNION
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast, '</a>' ) ) Trainer,
		CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
			CASE
				WHEN cm.module = 13 THEN CONCAT( 'quiz/report.php', CHAR(63), 'id=', cm.id, '">' )
				WHEN cm.module = 15 THEN CONCAT( 'scorm/report.php', CHAR(63), 'id=', cm.id, '">' )
				WHEN cm.module = 21 THEN CONCAT( 'assign/view.php', CHAR(63), 'id=', cm.id, '">' )
				ELSE CONCAT( '"></a><a target="_new" href="%%WWWROOT%%/course/modedit.php?up', 'date=', cm.id, '">' )
			END, gi.itemname, ' <b>(', 
			CASE
				WHEN ( ug.id = Student.Sid AND gg.finalgrade IS NOT NULL AND cm.module = 21 ) THEN CONCAT( Trainer.Tfirst, ' ', Trainer.Tlast, ' ' )
				WHEN ( ug.id = Student.Sid AND gg.finalgrade IS NOT NULL AND cm.module = 20 ) THEN 'External '
				WHEN ( ug.id = Student.Sid AND gg.finalgrade IS NOT NULL AND cm.module <> 20 ) THEN 'Auto '
				WHEN gg.finalgrade IS NULL THEN ''
				ELSE IFNULL( CONCAT( ug.firstname, ' ', ug.lastname, ' ' ), '' )
			END, IFNULL( gg.finalgrade, 'No Grade'), ')</b></a>' ) ORDER BY cm.id SEPARATOR '<br> ' ) Assessments,
		COUNT(gi.iteminstance) Total_Assessment_Items,
		SUM( CASE WHEN ( gg.finalgrade / gg.rawgrademax > 0.70 )
			THEN 1
		ELSE 0
		END ) Completed_Assessment_Items,
		SUM( CASE WHEN gg.finalgrade = 0
			THEN 1
		ELSE 0
		END ) CT_Granted,
		MAX(asub.timemodified) Last_Submit_Timestamp,
		MAX(gg.timemodified) Last_Grade_Timestamp,
		g.name Group_Name, c.id Cid,
		CONCAT( Student.Sid, c.id ) Enrolment_Identifier
		/*, GROUP_CONCAT( cm.availability SEPARATOR '<br>' ) Restrictions,
		GROUP_CONCAT( CASE WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}'
			THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
		WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(>=)","t":[0-9]{1,}},{0,1}){1,}'
			THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
		WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 1
		WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 0
		WHEN cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 0
		WHEN cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 1
		WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 0
		WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' )
			THEN 1
		END SEPARATOR ' ' ) Selector */

	FROM
	(
		SELECT DISTINCT t.firstname Tfirst, t.lastname Tlast, t.id Tid, e.courseid Cid
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
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email, u.lastaccess Lastaccess, ues.timeend Enddate
		FROM prefix_enrol es
		JOIN prefix_user_enrolments ues ON ues.enrolid = es.id
		JOIN prefix_user u ON u.id = ues.userid
		JOIN prefix_role_assignments ras ON ras.userid = u.id AND ras.roleid = 5
		JOIN prefix_context xs ON xs.contextlevel = 50 AND xs.id = ras.contextid AND xs.instanceid = es.courseid
		
		WHERE u.firstname IS NOT NULL
		AND u.lastname IS NOT NULL
		AND u.suspended = 0
		AND ues.status = 0
		AND ues.timeend = ''
	) Student ON Student.Cid = Trainer.Cid AND Student.Sid <> Trainer.Tid
	JOIN prefix_course c ON c.id = Trainer.Cid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
	LEFT JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.Sid
	LEFT JOIN prefix_user ug ON ug.id = gg.usermodified
	LEFT JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	LEFT JOIN prefix_assign_submission asub ON asub.userid = Student.Sid AND asub.assignment = gi.iteminstance AND asub.latest = 1
	JOIN prefix_groups_members gm ON gm.userid = Student.Sid
	JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = c.id
	JOIN prefix_groups_members gmt ON gmt.groupid = g.id AND gmt.userid = Trainer.Tid

	WHERE LOWER(gi.itemname) LIKE 'assessment%'
	AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
	AND gi.hidden = 0
	AND g.id IS NOT NULL
	AND cm.visible = 1
	AND IFNULL( CASE
					WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
					WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(>=)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
					WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 1
					WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 0
					WHEN cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 0
					WHEN cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 1
					WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 0
					WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) THEN 1
				END, 1 ) = 1

	GROUP BY Student.Sid, c.id
-- HAVING Selector IS NOT NULL
	)
) Merged

WHERE Merged.Student IS NOT NULL
-- AND Restrictions IS NOT NULL

%%FILTER_SEARCHTEXT:Merged.Trainer:~%%
%%FILTER_STARTTIME:Merged.Last_Grade_Timestamp:>%%
%%FILTER_ENDTIME:Merged.Last_Grade_Timestamp:<%%

ORDER BY Last_Grade DESC, Completion DESC