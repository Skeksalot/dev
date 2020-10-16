/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=279
*/

SELECT DISTINCT Assessments.fullname Course_Name,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', Assessments.Course_ID, '">', Assessments.shortname, '</a>' ) Course_Link,
	GROUP_CONCAT( DISTINCT Assessments.Link ORDER BY Assessments.Module_ID SEPARATOR ' <br>' ) Assessment_Names,
	COUNT(Assessments.Link) Assessment_Count
	
FROM (
	(
	SELECT DISTINCT 'Assignment' Module_Type, c.fullname, c.shortname, c.id Course_ID, cm.id Module_ID,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '">', a.name, '</a>' ) Link
	
	FROM
	prefix_course c
	JOIN prefix_assign a ON a.course = c.id
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = a.id
	
	WHERE c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101, 242, 154, 180, 161 )
	AND c.shortname REGEXP '2020'
	AND ( LOWER(a.name) LIKE 'assessment -%' OR LOWER(a.name) LIKE 'kcheck -%')
	
	)
	UNION
	(
	SELECT DISTINCT 'Quiz' Module_Type, c.fullname, c.shortname, c.id Course_ID, cm.id Module_ID,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '">', q.name, '</a>' ) Link
	
	FROM
	prefix_course c
	JOIN prefix_quiz q ON q.course = c.id
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = q.id
	
	WHERE c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101, 242, 154, 180, 161 )
	AND c.shortname REGEXP '2020'
	AND LOWER(q.name) LIKE 'assessment -%'
	
	)
	UNION
	(
	SELECT DISTINCT 'Scorm' Module_Type, c.fullname, c.shortname, c.id Course_ID, cm.id Module_ID,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '">', s.name, '</a>' ) Link
	FROM
	prefix_course c
	JOIN prefix_scorm s ON s.course = c.id
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = s.id
	
	WHERE c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101, 242, 154, 180, 161 )
	AND c.shortname REGEXP '2020'
	AND LOWER(s.name) LIKE 'assessment -%'
	
	)
	UNION
	(
	SELECT DISTINCT 'LTI' Module_Type, c.fullname, c.shortname, c.id Course_ID, cm.id Module_ID,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '">', l.name, '</a>' ) Link
	FROM
	prefix_course c
	JOIN prefix_lti l ON l.course = c.id
	JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = l.id
	
	WHERE c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101, 242, 154, 180, 161 )
	AND c.shortname REGEXP '2020'
	AND LOWER(l.name) LIKE 'assessment -%'
	
	)
) Assessments

GROUP BY Assessments.Course_ID

ORDER BY Assessments.fullname