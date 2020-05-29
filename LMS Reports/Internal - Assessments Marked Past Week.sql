/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=230
*/

SELECT DISTINCT
-- CONCAT(u.id, a.id, Logs.timecreated) Matcher,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', t.id, '">', t.firstname, ' ', t.lastname, '</a>' ) Trainer,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
	ag.grade Grade,
	FROM_UNIXTIME(Logs.timecreated) Time_Graded,
	CASE
		WHEN DATEDIFF( CURDATE(), FROM_UNIXTIME(Logs.timecreated) ) > 10 THEN "Yes"
		ELSE "No"
	END Overdue,
	'' Total_Submissions
	/*, log.eventname Name, log.component, log.action, log.target, log.objecttable,	log.objectid, log.contextlevel, log.contextinstanceid, log.userid, log.realuserid, log.relateduserid, log.courseid*/

FROM (
	SELECT *
	FROM prefix_logstore_standard_log log
	WHERE DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 7
	AND LOWER(log.action) LIKE '%graded%'
	AND LOWER(log.target) LIKE '%submission%'
) Logs
JOIN prefix_user u ON u.id = Logs.relateduserid
JOIN prefix_user t ON CASE WHEN Logs.realuserid IS NOT NULL THEN t.id = Logs.realuserid ELSE t.id = Logs.userid END
JOIN prefix_course c ON c.id = Logs.courseid
JOIN prefix_assign_grades ag ON ag.id = Logs.objectid
JOIN prefix_assign a ON a.id = ag.assignment
JOIN prefix_course_modules cm ON cm.instance = a.id AND cm.course = c.id

WHERE LOWER(a.name) LIKE 'assessment%'

%%FILTER_SEARCHTEXT:CONCAT(t.firstname, ' ', t.lastname):~%%

ORDER BY t.lastname, t.firstname, Time_Graded DESC