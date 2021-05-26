/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=299
*/

SELECT DISTINCT CONCAT(u.firstname, ' ', u.lastname) User, c.shortname Course, FROM_UNIXTIME(Logs.timecreated) Time_Created, Logs.action, Logs.objecttable, lab.intro

FROM (
	SELECT log.userid, log.courseid, log.timecreated, log.action, log.eventname, log.objecttable, log.objectid
	FROM prefix_logstore_standard_log log

	-- WHERE DATEDIFF( FROM_UNIXTIME(log.timecreated), "2021-05-15 00:00:00" ) <= 7
	WHERE DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 1095
	AND LOWER(log.action) REGEXP 'updated'
	AND log.eventname REGEXP 'course_module_completion'
	AND log.userid = 14031
) Logs
JOIN prefix_user u ON Logs.userid = u.id
JOIN prefix_course c ON Logs.courseid = c.id
JOIN prefix_course_modules_completion cmc ON cmc.id = Logs.objectid
JOIN prefix_course_modules cm ON cm.id = cmc.coursemoduleid
LEFT JOIN prefix_label lab ON lab.id = cm.instance

ORDER BY Logs.timecreated ASC