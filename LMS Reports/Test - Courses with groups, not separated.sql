/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=293
*/

SELECT CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	GROUP_CONCAT( DISTINCT CONCAT(Groups.name, ' (', Groups.Members, ')' ) SEPARATOR ', ' ) Group_List

FROM prefix_course c
JOIN (
	SELECT g.name, g.courseid, COUNT(gm.id) Members
	FROM prefix_groups g
	LEFT JOIN prefix_groups_members gm ON gm.groupid = g.id

	GROUP BY g.id
) Groups ON Groups.courseid = c.id

WHERE c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
AND Groups.Members = 0

GROUP BY c.id