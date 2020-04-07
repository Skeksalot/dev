/* https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=245 */

SELECT DISTINCT REPLACE( l.name, ",", "" ) Name, l.toolurl LTI_Tool,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '">', c.shortname, '</a>' ) Tool_Link,
	cm.id Module_ID, cm.module Module_Type, c.id Course_ID, cs.section, cm.instance

FROM
prefix_course c
JOIN prefix_lti l ON l.course = c.id
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = l.id AND cm.module = 20
JOIN prefix_course_sections cs ON cs.id = cm.section AND cs.course = c.id

WHERE c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101, 52, 30, 31, 32, 23, 26 )
/*  */
/*c.category IN ( 16, 17, 18, 22, 40, 43, 145, 146, 147, 148, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 182, 184, 185, 186, 187, 188, 211, 214, 219, 220, 222, 223, 229, 230, 260 )*/
/* TEMPLATES */
/*c.category IN ( 145, 146, 147, 148, 162, 163, 164, 165, 168, 169, 170, 172, 173, 182, 184, 207, 209, 211, 214, 229, 230 )*/
AND LOWER(l.toolurl) LIKE '%app.pluralsight.com%'
/*AND c.shortname LIKE '%201907%' */
/*AND c.visible = 1*/

ORDER BY LTI_Tool ASC, Name