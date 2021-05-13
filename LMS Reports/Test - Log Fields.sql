/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=303
*/

SELECT DISTINCT log.userid, log.course, log.module, log.info, log.action, log.url, log.time

FROM prefix_log log

WHERE DATEDIFF( CURDATE(), FROM_UNIXTIME(log.time) ) <= 1