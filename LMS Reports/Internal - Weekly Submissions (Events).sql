SELECT DISTINCT 
	CASE WHEN c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293, 55, 181 )
		THEN 'BSB'
	WHEN c.category IN ( 253, 254, 255, 256, 250, 251, 252, 191, 190, 192, 237, 213, 236 )
		THEN 'CHC'
	WHEN c.category IN ( 102, 103, 244, 245, 248, 108, 149, 109, 137, 110, 111, 112, 113, 159, 115, 231, 136, 249, 232, 263, 233, 117, 160, 118, 119, 120, 121, 122, 123, 124, 133, 132, 134, 135, 138, 143, 125, 151, 126, 127, 128, 129, 130, 226, 208, 261, 262, 267, 264, 265, 266, 51 )
		THEN 'ICT'
	END Faculty,
	DATE(FROM_UNIXTIME(MIN(asub.timemodified))) Week_From, DATE(FROM_UNIXTIME(MAX(asub.timemodified))) Week_To,
	YEARWEEK(FROM_UNIXTIME(asub.timemodified)) Week_Number, COUNT(asub.id) Total_Submissions
	/*CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', CHAR(63), 'id=', Students.id, '">', Students.firstname, ' ', Students.lastname, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', CHAR(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', CHAR(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
	FROM_UNIXTIME(log.timecreated) Time_Submitted
	, log.eventname, log.component, log.action, log.target, log.objecttable, log.objectid, log.contextlevel, log.contextinstanceid, log.userid, log.realuserid, log.relateduserid, log.courseid*/

FROM prefix_logstore_standard_log log
JOIN (
	SELECT DISTINCT e.courseid, u.*
	FROM prefix_enrol e
	JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
	JOIN prefix_user u ON u.id = ue.userid
	JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
	JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
	WHERE u.suspended = 0
	AND ue.status = 0
	AND ue.timeend = ''
) Students ON Students.id = log.userid
JOIN prefix_course c ON c.id = log.courseid 
	AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
JOIN prefix_assign_submission asub ON asub.id = log.objectid
JOIN prefix_assign a ON a.id = asub.assignment AND a.course = log.courseid
/*JOIN prefix_course_modules cm ON cm.instance = a.id AND cm.course = c.id*/

WHERE LOWER(log.action) LIKE '%submitted%'
AND LOWER(log.objecttable) LIKE '%assign_submission%'
AND ( LOWER(a.name) LIKE 'assessment%' OR LOWER(a.name) LIKE 'assessment%' )
AND DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 30

%%FILTER_SEARCHTEXT:Faculty:~%%
%%FILTER_STARTTIME:asub.timemodified:>%%
%%FILTER_ENDTIME:asub.timemodified:<%%

GROUP BY Faculty, Week_Number

ORDER BY Faculty ASC, Week_Number DESC