/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=299
*/

SELECT DISTINCT CONCAT(u.firstname, ' ', u.lastname) User, CONCAT(realuser.firstname, ' ', realuser.lastname) Real_User, CONCAT(related.firstname, ' ', related.lastname) Related_User,
	c.shortname Course, Logs.action, Logs.target, FROM_UNIXTIME(Logs.timecreated) Time_Created

FROM (
	SELECT log.userid, log.realuserid, log.relateduserid, log.courseid, log.action, log.target, log.timecreated
	FROM prefix_logstore_standard_log log
-- User ID of affected user
	WHERE ( log.userid = 15790 OR log.relateduserid = 15790 )
	%%FILTER_STARTTIME:Logs.timecreated:>%%
	%%FILTER_ENDTIME:Logs.timecreated:<%%
) Logs
JOIN prefix_user u ON Logs.userid = u.id
JOIN prefix_user realuser ON Logs.realuserid = realuser.id
JOIN prefix_user related ON Logs.relateduserid = related.id
JOIN prefix_course c ON Logs.courseid = c.id

WHERE Logs.relateduserid IS NOT NULL
%%FILTER_SEARCHTEXT:CONCAT(related.firstname, ' ', related.lastname):~%%
