/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=246
https://www.guru99.com/regular-expressions.html
https://dev.mysql.com/doc/refman/8.0/en/regexp.html
http://www.regular-expressions.info/posixbrackets.html
https://github.com/moodle/moodle/blob/master/availability/classes/info.php#L697
*/

SELECT DISTINCT CONCAT('<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/',
		CASE WHEN cm.module = 13
			THEN 'quiz/report.php'
		WHEN cm.module = 15
			THEN 'scorm/report.php'
		WHEN cm.module = 21
			THEN 'assign/view.php'
		END, CHAR(63), 'id=', cm.id, '">', gi.itemname, '</a><br>'
	) Assessments,
	/*FROM_UNIXTIME(gg.timemodified) Grade_Timestamp,*/
	cm.availability Restrictions, LEFT( cm.availability, 48 ) Type,
	CASE WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}'
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
	END Selector

FROM
(
	SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email, u.lastaccess Lastaccess, ues.timeend Enddate
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
) Student
JOIN prefix_course c ON c.id = Student.Cid
	AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
LEFT JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.Sid
LEFT JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance

WHERE LOWER(gi.itemname) LIKE 'assessment -%'
AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
AND gi.hidden = 0
AND cm.visible = 1
AND cm.availability IS NOT NULL
-- AND CASE
-- 		WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"<","t":[0-9]{1,}},{0,1}){1,}'
-- 		THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
-- 		WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":">=","t":[0-9]{1,}},{0,1}){1,}'
-- 		THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
-- 		WHEN cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains)","v":"[\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"')
-- 		THEN 1
-- 		WHEN cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains)","v":"[\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '^("', Student.Email, '")')
-- 		THEN 1
-- 		ELSE 0
-- 	END
-- AND (
-- 	cm.availability REGEXP CONCAT( '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains)","v":"', Student.Email, '"},{0,1}){1,}' ) OR
-- 	cm.availability REGEXP CONCAT( '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<|>=)","t":[0-9]{1,}},{0,1}){1,}' )
-- )
/*AND ( ( cm.availability IS NULL ) OR ( cm.availability LIKE CONCAT('%"op":"|","c"%', '{"type":"profile","sf":"email","op":"isequalto","v":"', Student.Email, '"}%') ) )*/
/*AND ( ( cm.availability IS NULL ) OR ( cm.availability REGEXP CONCAT('({"op":"[|&]","c":\[)({"type":"profile","sf":"email","op":"isequalto","v":"', Student.Email, '"},?){1,}') ) )*/

/*({"op":"[|&]",)("showc":[\[\]a-z]{1,},)?("c":\[)?({"type":"profile","sf":"email","op":"(isequalto|contains)","v":"[\w.@-]*"},?){1,}*/

ORDER BY Selector DESC