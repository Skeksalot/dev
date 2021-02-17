/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=294
*/
SELECT DISTINCT s.name,	cm.id SCORM_ID, c.shortname Course

FROM prefix_course c
JOIN prefix_scorm s ON s.course = c.id
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = s.id

WHERE c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293, 55, 181 )
	AND s.name LIKE '%WHS%'

ORDER BY s.name DESC