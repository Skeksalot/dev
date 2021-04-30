/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=299
*/

SELECT DISTINCT CONCAT(u.firstname, ' ', u.lastname) User, CONCAT(realuser.firstname, ' ', realuser.lastname) Real_User, CONCAT(related.firstname, ' ', related.lastname) Related_User,
	c.shortname Course, log.action, log.target, FROM_UNIXTIME(log.timecreated) Time_Created

FROM prefix_logstore_standard_log log
JOIN prefix_user u ON log.userid = u.id
JOIN prefix_user realuser ON log.realuserid = realuser.id
JOIN prefix_user related ON log.relateduserid = related.id
JOIN prefix_course c ON log.courseid = c.id

WHERE log.relateduserid IS NOT NULL
%%FILTER_SEARCHTEXT:CONCAT(related.firstname, ' ', related.lastname):~%%
%%FILTER_STARTTIME:log.timecreated:>%%
%%FILTER_ENDTIME:log.timecreated:<%%