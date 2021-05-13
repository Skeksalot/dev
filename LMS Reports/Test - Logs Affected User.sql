/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=299
*/

SELECT DISTINCT CONCAT(u.firstname, ' ', u.lastname) User, CONCAT(realuser.firstname, ' ', realuser.lastname) Real_User, CONCAT(related.firstname, ' ', related.lastname) Related_User,
	c.shortname Course, FROM_UNIXTIME(Logs.timecreated) Time_Created

FROM (
	SELECT log.userid, log.realuserid, log.relateduserid, log.courseid, log.timecreated
	FROM prefix_logstore_standard_log log

	WHERE DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 365
	AND LOWER(log.action) REGEXP 'user updated'
	AND log.relateduserid = 15790
	-- WHERE DATEDIFF( FROM_UNIXTIME(log.timecreated), "2021-05-15 00:00:00" ) <= 7
) Logs
JOIN prefix_user u ON Logs.userid = u.id
JOIN prefix_user realuser ON Logs.realuserid = realuser.id
JOIN prefix_user related ON Logs.relateduserid = related.id
JOIN prefix_course c ON Logs.courseid = c.id

WHERE Logs.relateduserid IS NOT NULL
