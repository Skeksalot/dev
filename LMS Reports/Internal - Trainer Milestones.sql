/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=243
https://www.guru99.com/regular-expressions.html
*/
SELECT DISTINCT Trainer, Course, Student, Enrolment_Identifier, FROM_UNIXTIME(Last_Grade_Timestamp) Last_Grade,
	REGEXP_SUBSTR( Last_Grader, "[a-zA-Z)(\\' -]{1,}" ) Last_Grader,
	Assessments,
	Completed_Assessment_Items, CT_Granted, RPL_Granted, Total_Assessment_Items,
	( Completed_Assessment_Items / Total_Assessment_Items ) * 100 Completion,
	( Completed_Assessment_Items / (Total_Assessment_Items - CT_Granted - Auto_Marked) ) * 100 True_Completion,
	CASE
		WHEN ( Completed_Assessment_Items >= 3 ) THEN 'Yes'
		ELSE 'No'
	END Milestone1_Status,
	CASE
		WHEN ( Completed_Assessment_Items >= CEILING( (Total_Assessment_Items - CT_Granted - Auto_Marked) * 0.6 ) ) THEN 'Yes'
		ELSE 'No'
	END Milestone2_Status,
	Last_Grader Last_Grader_Full

FROM (
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.id, '">', Trainer.Tfirst, ' ', Trainer.Tlast, '</a>' ) ) Trainer,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.id, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
			CASE
				WHEN cm.module = 13 THEN CONCAT( 'quiz/report.php', CHAR(63), 'id=', cm.id, '">' )
				WHEN cm.module = 15 THEN CONCAT( 'scorm/report.php', CHAR(63), 'id=', cm.id, '">' )
				WHEN cm.module = 21 THEN CONCAT( 'assign/view.php', CHAR(63), 'id=', cm.id, '">' )
				ELSE CONCAT( '"></a><a target="_new" href="%%WWWROOT%%/course/modedit.php?up', 'date=', cm.id, '">' )
			END, gi.itemname, ' <b>(', 
			CASE
				WHEN ( ug.id = Student.id AND gg.finalgrade IS NOT NULL AND cm.module = 21 ) THEN CONCAT( Trainer.Tfirst, ' ', Trainer.Tlast, ' ' )
				WHEN ( ug.id = Student.id AND gg.finalgrade IS NOT NULL AND cm.module = 20 ) THEN 'External '
				WHEN ( ug.id = Student.id AND gg.finalgrade IS NOT NULL AND cm.module <> 20 ) THEN 'Auto '
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
		SUM( CASE
				WHEN gg.finalgrade = 70 THEN 1
				ELSE 0
			END ) RPL_Granted,
		SUM( CASE
				WHEN ( ( gg.finalgrade / gg.rawgrademax > 0.70 ) AND cm.module = 15 ) THEN 1
				ELSE 0
			END ) Auto_Marked,
		MAX(gg.timemodified) Last_Grade_Timestamp,
		GROUP_CONCAT( CASE
						WHEN ( ug.id != Student.id AND gg.finalgrade IS NOT NULL ) THEN CONCAT( gg.timemodified, '~', ug.firstname, ' ', ug.lastname )
						ELSE ''
					END ORDER BY gg.timemodified DESC SEPARATOR '|' ) Last_Grader,
		Student.Gname Group_Name, c.id Cid,
		GROUP_CONCAT( cm.availability SEPARATOR '<br>' ) Restrictions,
		GROUP_CONCAT( CASE
						WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
						WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(>=)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
						WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
						WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
					END SEPARATOR ' ' ) Selector,
		CONCAT( Student.id, c.id ) Enrolment_Identifier

	FROM
	(
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id, e.courseid Cid, u.email, Groups.groupid Gid, Groups.name Gname
		FROM prefix_enrol e
		JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
		JOIN prefix_user u ON u.id = ue.userid
		JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
		JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
		LEFT JOIN (
			SELECT gm.id groupmemberid, gm.timeadded, gm.groupid linkedgroupid, gm.userid, g.id groupid, g.name, g.courseid
			FROM prefix_groups_members gm
			JOIN prefix_groups g ON g.id = gm.groupid
		) Groups ON Groups.userid = u.id AND Groups.courseid = e.courseid
		-- WHERE u.suspended = 0
		-- AND ue.status = 0
		-- AND ue.timeend = ''
	) Student
	JOIN
	(
		SELECT DISTINCT t.firstname Tfirst, t.lastname Tlast, t.id, et.courseid Cid, Groupst.groupid Gid
		FROM prefix_enrol et
		JOIN prefix_user_enrolments uet ON uet.enrolid = et.id
		JOIN prefix_user t ON t.id = uet.userid
		JOIN prefix_role_assignments rat ON rat.userid = t.id AND rat.roleid IN (3, 4)
		JOIN prefix_context xt ON xt.contextlevel = 50 AND xt.id = rat.contextid AND xt.instanceid = et.courseid
		LEFT JOIN (
			SELECT gm.id groupmemberid, gm.timeadded, gm.groupid linkedgroupid, gm.userid, g.id groupid, g.name, g.courseid
			FROM prefix_groups_members gm
			JOIN prefix_groups g ON g.id = gm.groupid
		) Groupst ON Groupst.userid = t.id AND Groupst.courseid = et.courseid
		-- WHERE t.suspended = 0
		-- AND ue.status = 0
		-- AND ue.timeend = ''
	) Trainer ON Trainer.Cid = Student.Cid AND Trainer.id <> Student.id
	JOIN prefix_course c ON c.id = Trainer.Cid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
	LEFT JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.id
	LEFT JOIN prefix_user ug ON ug.id = gg.usermodified
	LEFT JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	
	WHERE LOWER(gi.itemname) LIKE 'assessment -%'
	AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
	AND gi.hidden = 0
	AND Student.Gid IS NULL
	AND cm.visible = 1
	AND IFNULL( CASE
					WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
					WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(>=)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
					WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
					WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
					WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
					WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
					WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
					WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
				END, 1 ) = 1

	GROUP BY Student.id, c.id
	)
	UNION
	(
	SELECT DISTINCT
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Trainer.id, '">', Trainer.Tfirst, ' ', Trainer.Tlast, '</a>' ) ) Trainer,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.id, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
			CASE
				WHEN cm.module = 13 THEN CONCAT( 'quiz/report.php', CHAR(63), 'id=', cm.id, '">' )
				WHEN cm.module = 15 THEN CONCAT( 'scorm/report.php', CHAR(63), 'id=', cm.id, '">' )
				WHEN cm.module = 21 THEN CONCAT( 'assign/view.php', CHAR(63), 'id=', cm.id, '">' )
				ELSE CONCAT( '"></a><a target="_new" href="%%WWWROOT%%/course/modedit.php?up', 'date=', cm.id, '">' )
			END, gi.itemname, ' <b>(', 
			CASE
				WHEN ( ug.id = Student.id AND gg.finalgrade IS NOT NULL AND cm.module = 21 ) THEN CONCAT( Trainer.Tfirst, ' ', Trainer.Tlast, ' ' )
				WHEN ( ug.id = Student.id AND gg.finalgrade IS NOT NULL AND cm.module = 20 ) THEN 'External '
				WHEN ( ug.id = Student.id AND gg.finalgrade IS NOT NULL AND cm.module <> 20 ) THEN 'Auto '
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
		SUM( CASE
				WHEN gg.finalgrade = 70 THEN 1
				ELSE 0
			END ) RPL_Granted,
		SUM( CASE
				WHEN ( ( gg.finalgrade / gg.rawgrademax > 0.70 ) AND cm.module = 15 ) THEN 1
				ELSE 0
			END ) Auto_Marked,
		MAX(gg.timemodified) Last_Grade_Timestamp,
		GROUP_CONCAT( CASE
						WHEN ( ug.id != Student.id AND gg.finalgrade IS NOT NULL ) THEN CONCAT( gg.timemodified, '~', ug.firstname, ' ', ug.lastname )
						ELSE ''
					END ORDER BY gg.timemodified DESC SEPARATOR '|' ) Last_Grader,
		Student.Gname Group_Name, c.id Cid,
		GROUP_CONCAT( cm.availability SEPARATOR '<br>' ) Restrictions,
		GROUP_CONCAT( CASE
						WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
						WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(>=)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
						WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
						WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
					END SEPARATOR ' ' ) Selector,
		CONCAT( Student.id, c.id ) Enrolment_Identifier

	FROM
	(
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id, e.courseid Cid, u.email, Groups.groupid Gid, Groups.name Gname
		FROM prefix_enrol e
		JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
		JOIN prefix_user u ON u.id = ue.userid
		JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
		JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
		LEFT JOIN (
			SELECT gm.id groupmemberid, gm.timeadded, gm.groupid linkedgroupid, gm.userid, g.id groupid, g.name, g.courseid
			FROM prefix_groups_members gm
			JOIN prefix_groups g ON g.id = gm.groupid
		) Groups ON Groups.userid = u.id AND Groups.courseid = e.courseid
		-- WHERE u.suspended = 0
		-- AND ue.status = 0
		-- AND ue.timeend = ''
	) Student
	JOIN
	(
		SELECT DISTINCT t.firstname Tfirst, t.lastname Tlast, t.id, et.courseid Cid, Groupst.groupid Gid
		FROM prefix_enrol et
		JOIN prefix_user_enrolments uet ON uet.enrolid = et.id
		JOIN prefix_user t ON t.id = uet.userid
		JOIN prefix_role_assignments rat ON rat.userid = t.id AND rat.roleid IN (3, 4, 17, 18)
		JOIN prefix_context xt ON xt.contextlevel = 50 AND xt.id = rat.contextid AND xt.instanceid = et.courseid
		LEFT JOIN (
			SELECT gm.id groupmemberid, gm.timeadded, gm.groupid linkedgroupid, gm.userid, g.id groupid, g.name, g.courseid
			FROM prefix_groups_members gm
			JOIN prefix_groups g ON g.id = gm.groupid
		) Groupst ON Groupst.userid = t.id AND Groupst.courseid = et.courseid
		-- WHERE t.suspended = 0
		-- AND ue.status = 0
		-- AND ue.timeend = ''
	) Trainer ON Trainer.Cid = Student.Cid AND Trainer.id <> Student.id AND Trainer.Gid = Student.Gid
	JOIN prefix_course c ON c.id = Trainer.Cid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
	LEFT JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.id
	LEFT JOIN prefix_user ug ON ug.id = gg.usermodified
	LEFT JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance

	WHERE LOWER(gi.itemname) LIKE 'assessment -%'
	AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
	AND gi.hidden = 0
	AND Student.Gid IS NOT NULL
	AND cm.visible = 1
	AND IFNULL( CASE
					WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
					WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(>=)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
					WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
					WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
					WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
					WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
					WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 0
					WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.email, '"' ) ) THEN 1
				END, 1 ) = 1

	GROUP BY Student.id, c.id
	)
) Merged

WHERE Merged.Student IS NOT NULL
AND ( Merged.Completed_Assessment_Items >= 3 OR ( Merged.Completed_Assessment_Items >= CEILING( Merged.Total_Assessment_Items * 0.6 ) ) )

%%FILTER_SEARCHTEXT:Merged.Trainer:~%%
%%FILTER_STARTTIME:Merged.Last_Grade_Timestamp:>%%
%%FILTER_ENDTIME:Merged.Last_Grade_Timestamp:<%%

ORDER BY Milestone2_Status DESC, Last_Grade DESC, Completion DESC