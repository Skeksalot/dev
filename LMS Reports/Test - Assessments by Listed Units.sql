/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=262
*/
SELECT l.intro, c.shortname Course, cs.name Section, a.name Assignment

FROM prefix_label l
JOIN prefix_course_modules cm ON cm.instance = l.id AND cm.course = l.course
JOIN prefix_course c ON c.id = cm.course AND c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293, 55, 181 )
-- JOIN prefix_course c ON c.id = cm.course AND c.fullname REGEXP 'Diploma of Business 2'
-- JOIN prefix_course c ON c.id = cm.course AND c.fullname REGEXP 'Diploma of Event Management'
-- JOIN prefix_course c ON c.id = cm.course AND c.shortname REGEXP '(Dual_Dip|DUAL_DIP)_((HR_Bus)|(LM_Bus)|(LM_BUS)|(LM_BA)|(LM__BA))'
JOIN prefix_course_sections cs ON cs.id = cm.section AND cs.course = cm.course
JOIN prefix_course_modules cma ON cma.course = cs.course AND cma.section = cs.id AND cma.module = 21
JOIN prefix_assign a ON a.course = cma.course AND a.id = cma.instance

-- WHERE ( (LOWER(l.intro) REGEXP 'bsbmgt403') OR (LOWER(l.intro) REGEXP 'bsbcus501') OR (LOWER(l.intro) REGEXP 'bsbwor501') OR (LOWER(l.intro) REGEXP 'bsbpmg522') OR (LOWER(l.intro) REGEXP 'bsbrsk501') )
-- WHERE ( (LOWER(l.intro) REGEXP 'cuafoh501') OR (LOWER(l.intro) REGEXP 'sitxmpr006') )
-- WHERE ( (LOWER(l.intro) REGEXP 'bsbhrm506') OR (LOWER(l.intro) REGEXP 'bsbhrm513') )
WHERE ( LOWER(l.intro) REGEXP 'bsbled401' )
	AND NOT LOWER(l.intro) REGEXP 'instructions|resource -'
	-- AND TRIM(a.name) REGEXP 'Assessment - (Manage ){0,1}(([rR]ecr(ui|iu)tment [sS]election)|(Selection Process)|([wW]orkforce [pP]lanning)).* Upload'
	-- AND ( TRIM(a.name) REGEXP 'Assessment - Implement Continuous (I|i)mprovement'
	-- 	OR TRIM(a.name) REGEXP 'Assessment -( Manage (Q|q)uality){0,1} (C|c)ustomer (S|s)ervice( BSBCUS501){0,1}( Part D| Upload| Video){0,1}'
	-- 	OR TRIM(a.name) REGEXP 'Assessment - (Audio recording|Part B|Manage (personal work priorities|Priorities and Development))'
	-- 	OR TRIM(a.name) REGEXP 'Assessment - Undertake (P|p)roject (W|w)ork'
	-- 	OR TRIM(a.name) REGEXP 'Assessment - Manage (R|r)isk')
	-- TRIM(a.name) REGEXP 'Assessment - (Manage front of house services|Manage Staff Teams and Customers)'
	-- 	OR TRIM(a.name) REGEXP 'Assessment - Establish and Conduct Business Relationship'