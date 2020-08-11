/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=262
*/
SELECT l.intro, c.shortname Course, cs.name Section, a.name Assignment

FROM prefix_label l
JOIN prefix_course_modules cm ON cm.instance = l.id AND cm.course = l.course
JOIN prefix_course c ON c.id = cm.course AND c.fullname REGEXP 'Diploma of Business 2'
JOIN prefix_course_sections cs ON cs.id = cm.section AND cs.course = cm.course 
JOIN prefix_course_modules cma ON cma.course = cs.course AND cma.section = cs.id AND cma.module = 21
JOIN prefix_assign a ON a.course = cma.course AND a.id = cma.instance

WHERE ( (LOWER(l.intro) REGEXP 'bsbmgt403') OR (LOWER(l.intro) REGEXP 'bsbcus501') OR (LOWER(l.intro) REGEXP 'bsbwor501') OR (LOWER(l.intro) REGEXP 'bsbpmg522') OR (LOWER(l.intro) REGEXP 'bsbrsk501') )
AND NOT LOWER(l.intro) REGEXP 'instructions|resource -'
AND ( TRIM(a.name) REGEXP 'Assessment - Implement Continuous (I|i)mprovement'
	OR TRIM(a.name) REGEXP 'Assessment -( Manage (Q|q)uality){0,1} (C|c)ustomer (S|s)ervice( BSBCUS501){0,1}( Part D| Upload| Video){0,1}'
	OR TRIM(a.name) REGEXP 'Assessment - (Audio recording|Part B|Manage (personal work priorities|Priorities and Development))'
	OR TRIM(a.name) REGEXP 'Assessment - Undertake (P|p)roject (W|w)ork'
	OR TRIM(a.name) REGEXP 'Assessment - Manage (R|r)isk' )