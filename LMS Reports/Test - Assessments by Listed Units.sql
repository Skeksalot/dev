/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=262
*/
SELECT l.intro, c.shortname Course, cs.name Section, a.name Assignment

FROM prefix_label l
JOIN prefix_course_modules cm ON cm.instance = l.id AND cm.course = l.course
JOIN prefix_course c ON c.id = cm.course
JOIN prefix_course_sections cs ON cs.id = cm.section AND cs.course = cm.course 
JOIN prefix_course_modules cma ON cma.course = cs.course AND cma.section = cs.id AND cma.module = 21
JOIN prefix_assign a ON a.course = cma.course AND a.id = cma.instance

WHERE ( (LOWER(l.intro) REGEXP 'siteevt010') OR (LOWER(l.intro) REGEXP 'sitxwhs002') )
AND NOT LOWER(l.intro) REGEXP 'instructions|resource -'
AND TRIM(a.name) REGEXP 'Assessment - (Major Project|Manage Installation|Manage (on-site event operations|Onsite Operations)|Manage Risk|Practical Skills Register|Staging Operations|Identify Hazards )'
-- AND ( TRIM(a.name) REGEXP 'Assessment - (Manage |Recruitment Selection and ){0,1}(W|w)orkforce (P|p)lanning( BSBHRM513){0,1}'
-- 	 OR TRIM(a.name) REGEXP 'Assessment -( Manage (Q|q)uality){0,1} (C|c)ustomer (S|s)ervice( BSBCUS501){0,1}( Part D| Upload| Video){0,1}' )
