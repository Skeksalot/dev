SELECT DISTINCT
CASE
	WHEN cm.module = 13 THEN a.name
	WHEN cm.module = 15 THEN s.name
	ELSE q.name
END Name
/*CASE 
	WHEN cm.module =  THEN GROUP_CONCAT( DISTINCT ' ', CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', c.shortname, '</a>' ) ) assessment_link
	WHEN cm.module =  THEN 
	ELSE 
END Link*/

FROM
prefix_course c
JOIN prefix_assign a ON a.course = c.id
JOIN prefix_scorm s ON s.course = c.id
JOIN prefix_quiz q ON q.course = c.id
JOIN prefix_course_modules cm ON cm.course = c.id AND ( cm.instance = a.id OR cm.instance = s.id OR cm.instance = q.id )

WHERE a.cutoffdate <> 0
OR s.timeclose <> 0
OR q.timeclose <> 0

GROUP BY Name

ORDER BY Name DESC