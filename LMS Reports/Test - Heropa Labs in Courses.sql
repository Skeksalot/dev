/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=247
*/

SELECT DISTINCT l.name Lab_Name, 
    CONCAT( '<a target="_new" href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '">', c.shortname, '</a>' ) Lab_Link

FROM
prefix_course c
JOIN prefix_lti l ON l.course = c.id
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = l.id AND cm.module = 20

WHERE c.category IN ( 102, 103, 244, 245, 248, 108, 149, 109, 137, 110, 111, 112, 113, 159, 115, 231, 136, 249, 232, 263, 233, 117, 160, 118, 119, 120, 121, 122, 123, 124, 133, 132, 134, 135, 138, 143, 125, 151, 126, 127, 128, 129, 130, 226, 208, 261, 262, 267, 264, 265, 266, 51 )
AND LOWER(l.name) REGEXP '[ ]{0,1}Assessment[ ][\\–\\-]'
AND l.instructorchoiceacceptgrades = 1
/*AND c.shortname LIKE '%201907%' */
/*AND c.visible = 1*/

ORDER BY Lab_Name