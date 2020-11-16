/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=253
*/
SELECT DISTINCT a.name, GROUP_CONCAT( DISTINCT cs.name ORDER BY cs.id SEPARATOR ', ' ) Sections, GROUP_CONCAT( DISTINCT c.shortname ORDER BY c.id SEPARATOR ', ' ) Courses

FROM prefix_course c
JOIN prefix_assign a ON a.course = c.id
JOIN prefix_course_modules cm ON cm.instance = a.id and cm.course = c.id
JOIN prefix_course_sections cs ON cs.id = cm.section and cs.course = c.id

-- WHERE c.fullname REGEXP 'Diploma of Business'
WHERE c.shortname REGEXP '(Dual_Dip|DUAL_DIP)_((HR_Bus)|(LM_Bus)|(LM_BUS)|(LM_BA)|(LM__BA))'
AND LOWER(a.name) LIKE 'assessment -%'

GROUP BY a.name

ORDER BY a.name ASC