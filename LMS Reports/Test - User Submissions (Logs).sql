/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=305
*/

SELECT DISTINCT CONCAT(u.firstname, ' ', u.lastname) User, c.shortname Course, FROM_UNIXTIME(Logs.timecreated) Time_Created, Logs.action, Logs.objecttable, a.name

FROM (
	SELECT log.userid, log.courseid, log.timecreated, log.action, log.eventname, log.objecttable, log.objectid
	FROM prefix_logstore_standard_log log

	WHERE log.userid = 15874
	AND log.action = 'submitted'
	-- AND DATEDIFF( FROM_UNIXTIME(log.timecreated), "2021-05-15 00:00:00" ) <= 7
	-- AND DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 180

) Logs
JOIN prefix_user u ON Logs.userid = u.id
JOIN prefix_course c ON Logs.courseid = c.id
JOIN prefix_assign_submission asub ON asub.id = Logs.objectid
JOIN prefix_assign a ON a.id = asub.assignment

ORDER BY Logs.timecreated ASC