/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=261
*/
SELECT DISTINCT GROUP_CONCAT( DISTINCT Student.Student ) Student, GROUP_CONCAT( DISTINCT Student.Course ) Course,
	GROUP_CONCAT( DISTINCT CONCAT( BSBMGT403.Assessment, ' ~ ', BSBMGT403.Time_Submitted, ' ~ ', IFNULL(BSBMGT403.Grade, 'Not Graded') ) SEPARATOR '<br>' ) MGT403_Assessment,
	GROUP_CONCAT( DISTINCT CONCAT( BSBCUS501.Assessment, ' ~ ', BSBCUS501.Time_Submitted, ' ~ ', IFNULL(BSBCUS501.Grade, 'Not Graded') ) SEPARATOR '<br>' ) CUS501_Assessment,
	GROUP_CONCAT( DISTINCT CONCAT( BSBWOR501.Assessment, ' ~ ', BSBWOR501.Time_Submitted, ' ~ ', IFNULL(BSBWOR501.Grade, 'Not Graded') ) SEPARATOR '<br>' ) WOR501_Assessment,
	GROUP_CONCAT( DISTINCT CONCAT( BSBPMG522.Assessment, ' ~ ', BSBPMG522.Time_Submitted, ' ~ ', IFNULL(BSBPMG522.Grade, 'Not Graded') ) SEPARATOR '<br>' ) PMG522_Assessment,
	GROUP_CONCAT( DISTINCT CONCAT( BSBRSK501.Assessment, ' ~ ', BSBRSK501.Time_Submitted, ' ~ ', IFNULL(BSBRSK501.Grade, 'Not Graded') ) SEPARATOR '<br>' ) RSK501_Assessment,
	Progress.Completion,
	Student.Status

FROM
(
	SELECT DISTINCT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>') Course,
		CASE
			WHEN ( u.suspended = 0 AND ue.status = 0 AND ue.timeend = '' ) THEN 'Active'
			ELSE 'Inactive'
		END Status,
		CONCAT( u.id, c.id ) Enrolment_Identifier

	FROM prefix_label l
	JOIN prefix_course_modules cm ON cm.instance = l.id AND cm.course = l.course
	JOIN prefix_course c ON c.id = cm.course AND c.fullname REGEXP 'Diploma of Business 2' AND NOT c.fullname REGEXP 'Dual'
	JOIN prefix_course_sections cs ON cs.id = cm.section AND cs.course = cm.course 
	JOIN prefix_course_modules cma ON cma.course = cs.course AND cma.section = cs.id AND cma.module = 21
	JOIN prefix_assign a ON a.course = cma.course AND a.id = cma.instance
	JOIN prefix_enrol e ON e.courseid = c.id
	JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
	JOIN prefix_user u ON u.id = ue.userid

	WHERE ( (LOWER(l.intro) REGEXP 'bsbmgt403') OR (LOWER(l.intro) REGEXP 'bsbcus501') OR (LOWER(l.intro) REGEXP 'bsbwor501') OR (LOWER(l.intro) REGEXP 'bsbpmg522') OR (LOWER(l.intro) REGEXP 'bsbrsk501') )
	AND NOT LOWER(l.intro) REGEXP 'instructions'
	-- AND TRIM(a.name) REGEXP 'Assessment - Implement Continuous (I|i)mprovement'
	AND ( TRIM(a.name) REGEXP 'Assessment - Implement Continuous (I|i)mprovement'
		OR TRIM(a.name) REGEXP 'Assessment -( Manage (Q|q)uality){0,1} (C|c)ustomer (S|s)ervice( BSBCUS501){0,1}( Part D| Upload| Video){0,1}'
		OR TRIM(a.name) REGEXP 'Assessment - (Audio recording|Part B|Manage (personal work priorities|Priorities and Development))'
		OR TRIM(a.name) REGEXP 'Assessment - Undertake (P|p)roject (W|w)ork'
		OR TRIM(a.name) REGEXP 'Assessment - Manage (R|r)isk' )
) Student
JOIN
(
	SELECT DISTINCT Enrolment_Identifier,
		( Completed_Assessment_Items / (Total_Assessment_Items - CT_Granted - RPL_Granted) ) * 100 Completion

	FROM
	(
		SELECT DISTINCT
			COUNT(gi.iteminstance) Total_Assessment_Items,
			SUM( CASE WHEN ( gg.finalgrade / gg.rawgrademax > 0.70 )
				THEN 1
			ELSE 0
			END ) Completed_Assessment_Items,
			SUM( CASE WHEN gg.finalgrade = 0
				THEN 1
			ELSE 0
			END ) CT_Granted,
			SUM( CASE WHEN gg.finalgrade = 70
				THEN 1
			ELSE 0
			END ) RPL_Granted,
			CONCAT( Student.Sid, c.id ) Enrolment_Identifier

		FROM
		(
			SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, es.courseid Cid, u.email Email
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
		JOIN prefix_course c ON c.id = Student.Cid AND c.fullname REGEXP 'Diploma of Business 2' AND NOT c.fullname REGEXP 'Dual'
		JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
		LEFT JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = Student.Sid
		LEFT JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
		
		WHERE LOWER(gi.itemname) LIKE 'assessment -%'
		AND gi.itemname NOT LIKE 'Assessment - IT Foundations Course'
		AND gi.hidden = 0
		AND cm.visible = 1
		AND IFNULL( CASE
						WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(<)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() < CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
						WHEN cm.availability REGEXP '({"op":"[|&]",)("c":\\[){0,1}({"type":"date","d":"(>=)","t":[0-9]{1,}},{0,1}){1,}' THEN ( UNIX_TIMESTAMP() >= CONVERT( REGEXP_SUBSTR( cm.availability, '[0-9]{1,}' ), UNSIGNED ) )
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) ) THEN 1
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) ) THEN 0
						WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) ) THEN 0
						WHEN ( cm.availability REGEXP '({"op":"![|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(isequalto|contains|endswith)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) ) THEN 1
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) ) THEN 0
						WHEN ( cm.availability REGEXP '({"op":"[|&]",)("showc":\\[[a-z]{1,}\\],){0,1}("c":\\[){0,1}({"type":"profile","sf":"email","op":"(doesnotcontain)","v":"[\\w.@-]*"},{0,1}){1,}' AND NOT cm.availability REGEXP CONCAT( '"', Student.Email, '"' ) ) THEN 1
					END, 1 ) = 1

		GROUP BY Student.Sid, c.id
	) Merged
) Progress ON Progress.Enrolment_Identifier = Student.Enrolment_Identifier
LEFT JOIN
(
	SELECT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', CHAR(63), 'id=', cm.id, '">', gi.itemname, '</a>' ) Assessment,
		gg.finalgrade Grade, FROM_UNIXTIME(gg.timemodified) Time_Graded, FROM_UNIXTIME(asub.timemodified) Time_Submitted, CONCAT( asub.userid, c.id ) Enrolment_Identifier

	FROM prefix_course c
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
		AND TRIM(gi.itemname) REGEXP 'Assessment - Implement Continuous (I|i)mprovement'
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	JOIN prefix_assign a ON a.name LIKE gi.itemname AND a.course = c.id AND a.id = cm.instance
	JOIN prefix_assign_submission asub ON asub.assignment = a.id AND asub.latest = 1
	JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = asub.userid

	WHERE c.fullname REGEXP 'Diploma of Business 2'
		AND NOT c.fullname REGEXP 'Dual'
	AND asub.status = 'submitted'
	/*AND gg.finalgrade IS NOT NULL
	AND ( gg.finalgrade = 0 OR gg.finalgrade >= 70 )*/
	-- AND asub.timemodified > UNIX_TIMESTAMP('2019-7-01 00:00:00')
	-- AND asub.timemodified <= UNIX_TIMESTAMP('2020-1-01 00:00:00')
) BSBMGT403 ON Student.Enrolment_Identifier = BSBMGT403.Enrolment_Identifier
LEFT JOIN
(
	SELECT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', CHAR(63), 'id=', cm.id, '">', gi.itemname, '</a>' ) Assessment,
		gg.finalgrade Grade, FROM_UNIXTIME(gg.timemodified) Time_Graded, FROM_UNIXTIME(asub.timemodified) Time_Submitted, CONCAT( asub.userid, c.id ) Enrolment_Identifier

	FROM prefix_course c
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
		AND TRIM(gi.itemname) REGEXP 'Assessment -( Manage (Q|q)uality){0,1} (C|c)ustomer (S|s)ervice( BSBCUS501){0,1}( Part D| Upload| Video){0,1}'
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	JOIN prefix_assign a ON a.name LIKE gi.itemname AND a.course = c.id AND a.id = cm.instance
	JOIN prefix_assign_submission asub ON asub.assignment = a.id AND asub.latest = 1
	JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = asub.userid

	WHERE c.fullname REGEXP 'Diploma of Business 2'
		AND NOT c.fullname REGEXP 'Dual'
	AND asub.status = 'submitted'
	/*AND gg.finalgrade IS NOT NULL
	AND ( gg.finalgrade = 0 OR gg.finalgrade >= 70 )*/
	-- AND asub.timemodified > UNIX_TIMESTAMP('2019-7-01 00:00:00')
	-- AND asub.timemodified <= UNIX_TIMESTAMP('2020-1-01 00:00:00')
) BSBCUS501 ON Student.Enrolment_Identifier = BSBCUS501.Enrolment_Identifier
LEFT JOIN
(
	SELECT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', CHAR(63), 'id=', cm.id, '">', gi.itemname, '</a>' ) Assessment,
		gg.finalgrade Grade, FROM_UNIXTIME(gg.timemodified) Time_Graded, FROM_UNIXTIME(asub.timemodified) Time_Submitted, CONCAT( asub.userid, c.id ) Enrolment_Identifier

	FROM prefix_course c
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
		AND TRIM(gi.itemname) REGEXP 'Assessment - (Audio recording|Part B|Manage (personal work priorities|Priorities and Development))'
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	JOIN prefix_assign a ON a.name LIKE gi.itemname AND a.course = c.id AND a.id = cm.instance
	JOIN prefix_assign_submission asub ON asub.assignment = a.id AND asub.latest = 1
	JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = asub.userid

	WHERE c.fullname REGEXP 'Diploma of Business 2'
		AND NOT c.fullname REGEXP 'Dual'
	AND asub.status = 'submitted'
	/*AND gg.finalgrade IS NOT NULL
	AND ( gg.finalgrade = 0 OR gg.finalgrade >= 70 )*/
	-- AND asub.timemodified > UNIX_TIMESTAMP('2019-7-01 00:00:00')
	-- AND asub.timemodified <= UNIX_TIMESTAMP('2020-1-01 00:00:00')
) BSBWOR501 ON Student.Enrolment_Identifier = BSBWOR501.Enrolment_Identifier
LEFT JOIN
(
	SELECT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', CHAR(63), 'id=', cm.id, '">', gi.itemname, '</a>' ) Assessment,
		gg.finalgrade Grade, FROM_UNIXTIME(gg.timemodified) Time_Graded, FROM_UNIXTIME(asub.timemodified) Time_Submitted, CONCAT( asub.userid, c.id ) Enrolment_Identifier

	FROM prefix_course c
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
		AND TRIM(gi.itemname) REGEXP 'Assessment - Undertake (P|p)roject (W|w)ork'
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	JOIN prefix_assign a ON a.name LIKE gi.itemname AND a.course = c.id AND a.id = cm.instance
	JOIN prefix_assign_submission asub ON asub.assignment = a.id AND asub.latest = 1
	JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = asub.userid

	WHERE c.fullname REGEXP 'Diploma of Business 2'
		AND NOT c.fullname REGEXP 'Dual'
	AND asub.status = 'submitted'
	/*AND gg.finalgrade IS NOT NULL
	AND ( gg.finalgrade = 0 OR gg.finalgrade >= 70 )*/
	-- AND asub.timemodified > UNIX_TIMESTAMP('2019-7-01 00:00:00')
	-- AND asub.timemodified <= UNIX_TIMESTAMP('2020-1-01 00:00:00')
) BSBPMG522 ON Student.Enrolment_Identifier = BSBPMG522.Enrolment_Identifier
LEFT JOIN
(
	SELECT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', CHAR(63), 'id=', cm.id, '">', gi.itemname, '</a>' ) Assessment,
		gg.finalgrade Grade, FROM_UNIXTIME(gg.timemodified) Time_Graded, FROM_UNIXTIME(asub.timemodified) Time_Submitted, CONCAT( asub.userid, c.id ) Enrolment_Identifier

	FROM prefix_course c
	JOIN prefix_grade_items gi ON gi.courseid = c.id AND gi.itemtype = 'mod'
		AND TRIM(gi.itemname) REGEXP 'Assessment - Manage (R|r)isk'
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = gi.iteminstance
	JOIN prefix_assign a ON a.name LIKE gi.itemname AND a.course = c.id AND a.id = cm.instance
	JOIN prefix_assign_submission asub ON asub.assignment = a.id AND asub.latest = 1
	JOIN prefix_grade_grades gg ON gg.itemid = gi.id AND gg.userid = asub.userid

	WHERE c.fullname REGEXP 'Diploma of Business 2'
		AND NOT c.fullname REGEXP 'Dual'
	AND asub.status = 'submitted'
	/*AND gg.finalgrade IS NOT NULL
	AND ( gg.finalgrade = 0 OR gg.finalgrade >= 70 )*/
	-- AND asub.timemodified > UNIX_TIMESTAMP('2019-7-01 00:00:00')
	-- AND asub.timemodified <= UNIX_TIMESTAMP('2020-1-01 00:00:00')
) BSBRSK501 ON Student.Enrolment_Identifier = BSBRSK501.Enrolment_Identifier

-- WHERE (BSBMGT403.Assessment IS NOT NULL) OR (BSBCUS501.Assessment IS NOT NULL) OR (BSBWOR501.Assessment IS NOT NULL) OR (BSBPMG522.Assessment IS NOT NULL) OR (BSBRSK501.Assessment IS NOT NULL)

GROUP BY Student.Enrolment_Identifier

HAVING (MGT403_Assessment IS NOT NULL) OR (CUS501_Assessment IS NOT NULL) OR (WOR501_Assessment IS NOT NULL) OR (PMG522_Assessment IS NOT NULL) OR (RSK501_Assessment IS NOT NULL)
-- HAVING (MGT403_Assessment IS NOT NULL)
-- HAVING (CUS501_Assessment IS NOT NULL)
-- HAVING (WOR501_Assessment IS NOT NULL)
-- HAVING (PMG522_Assessment IS NOT NULL)
-- HAVING (RSK501_Assessment IS NOT NULL)