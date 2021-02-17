/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=215
*/
SELECT DISTINCT GROUP_CONCAT( DISTINCT ' ', s.name ) Names,
	GROUP_CONCAT( DISTINCT ' ', CONCAT( '<a target="_new" href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '">', c.shortname, '</a>' ) ) Scorm_Links

FROM prefix_course c
JOIN prefix_scorm s ON s.course = c.id
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = s.id

WHERE c.category IN ( 145, 146, 147, 148, 162, 163, 164, 165, 168, 169, 170, 172, 173, 182, 184, 207, 209, 211, 214, 229, 230 )
AND s.name LIKE '%WHS%'

GROUP BY s.name

ORDER BY s.name DESC