/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=308
*/

SELECT DISTINCT CONCAT(u.firstname, ' ', u.lastname) User, c.shortname Course, FROM_UNIXTIME(Logs.timecreated) Time_Created, Logs.action, Logs.objecttable Type,
    CASE
        WHEN cm.module = 12 THEN CONCAT('<a target="_new" href="%%WWWROOT%%/course/view.php', CHAR(63), 'id=', c.id, '&section=', cs.section, '">', p.name, '</a>')
        WHEN cm.module = 13 THEN CONCAT('<a target="_new" href="%%WWWROOT%%/mod/quiz/report.php', CHAR(63), 'id=', cm.id, '">', q.name, '</a>')
        WHEN cm.module = 14 THEN CONCAT('<a target="_new" href="%%WWWROOT%%/course/view.php', CHAR(63), 'id=', c.id, '&section=', cs.section, '">', res.name, '</a>')
        WHEN cm.module = 15 THEN CONCAT('<a target="_new" href="%%WWWROOT%%/mod/scorm/report.php', CHAR(63), 'id=', cm.id, '">', sco.name, '</a>')
        WHEN cm.module = 20 THEN CONCAT('<a target="_new" href="%%WWWROOT%%/course/view.php', CHAR(63), 'id=', c.id, '&section=', cs.section, '">', l.name, '</a>')
        WHEN cm.module = 21 THEN CONCAT('<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', CHAR(63), 'id=', cm.id, '">', a.name, '</a>')
        ELSE cm.module
    END Item

FROM (
	SELECT log.userid, log.courseid, log.timecreated, log.action, log.eventname, log.objecttable, log.objectid, log.contextid
	FROM prefix_logstore_standard_log log

	-- WHERE DATEDIFF( FROM_UNIXTIME(log.timecreated), "2021-05-15 00:00:00" ) <= 7
	-- WHERE DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 180
	WHERE log.userid = 17229
	-- AND log.userid = 15874
) Logs
JOIN prefix_user u ON Logs.userid = u.id
JOIN prefix_course c ON Logs.courseid = c.id
JOIN prefix_course_modules cm ON cm.instance = Logs.objectid AND cm.course = c.id
JOIN prefix_course_sections cs ON cs.id = cm.section and cs.course = c.id
LEFT OUTER JOIN prefix_lti l ON l.id = cm.instance AND l.course = c.id
LEFT OUTER JOIN prefix_assignment a ON a.id = cm.instance AND a.course = c.id
LEFT OUTER JOIN prefix_scorm sco ON sco.id = cm.instance AND sco.course = c.id
LEFT OUTER JOIN prefix_quiz q ON q.id = cm.instance AND q.course = c.id
LEFT OUTER JOIN prefix_page p ON q.id = cm.instance AND p.course = c.id
LEFT OUTER JOIN prefix_resource res ON res.id = cm.instance AND res.course = c.id

ORDER BY Logs.timecreated ASC