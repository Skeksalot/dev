/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=253
*/
SELECT DISTINCT a.name, GROUP_CONCAT( DISTINCT c.shortname ORDER BY c.id SEPARATOR ', ' ) Courses

FROM prefix_course c
JOIN prefix_assign a ON a.course = c.id

WHERE c.fullname REGEXP 'Diploma of Business'
AND LOWER(a.name) LIKE 'assessment -%'

GROUP BY a.name

ORDER BY a.name ASC