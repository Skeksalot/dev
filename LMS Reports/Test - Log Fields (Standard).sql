/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=301
*/

SELECT DISTINCT log.userid, log.realuserid, log.relateduserid, log.courseid, log.action, log.target, log.timecreated

FROM prefix_logstore_standard_log log

WHERE DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 1
AND log.target NOT REGEXP 'webservice_function'