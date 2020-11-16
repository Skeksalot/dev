/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=286
*/

SELECT DISTINCT Logs.id, FROM_UNIXTIME(Logs.timecreated), c.fullname, a.name, ag.grade

FROM (
	SELECT log.id, log.courseid, log.objectid, log.timecreated
	FROM prefix_logstore_standard_log log
	WHERE DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 180
	AND LOWER(log.action) LIKE '%graded%'
	AND LOWER(log.target) LIKE '%submission%'
) Logs
JOIN prefix_course c ON c.id = Logs.courseid
JOIN prefix_assign_grades ag ON ag.id = Logs.objectid
JOIN prefix_assign a ON a.id = ag.assignment

WHERE LOWER(a.name) REGEXP 'assessment -'
AND c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293, 55, 181 )