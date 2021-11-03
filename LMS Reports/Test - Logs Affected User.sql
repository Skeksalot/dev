/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=299
*/

SELECT DISTINCT CONCAT(u.firstname, ' ', u.lastname) User, c.shortname Course, FROM_UNIXTIME(Logs.timecreated) Time_Created, Logs.action, Logs.objecttable

FROM (
	SELECT log.userid, log.courseid, log.timecreated, log.action, log.eventname, log.objecttable, log.objectid
	FROM prefix_logstore_standard_log log

	-- WHERE DATEDIFF( FROM_UNIXTIME(log.timecreated), "2021-05-15 00:00:00" ) <= 7
	WHERE DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 180
	AND log.userid = 18221
) Logs
JOIN prefix_user u ON Logs.userid = u.id
JOIN prefix_course c ON Logs.courseid = c.id

ORDER BY Logs.timecreated ASC