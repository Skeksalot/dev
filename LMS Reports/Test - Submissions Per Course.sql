/* https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=242&courseid=1 */

SELECT DISTINCT
	CASE WHEN c.category IN ( 227, 217, 82, 234, 83, 98, 155, 85, 271, 258, 100, 99, 84, 177, 275, 270, 157, 198, 210, 241, 195, 87, 88, 90, 276, 91, 92, 89, 272, 178, 156, 203, 205, 200, 243, 201, 140, 96, 94, 95, 179, 141, 199, 259, 216, 204, 277, 247, 206, 228, 274, 196, 197, 278, 279, 280, 292, 293, 55, 181 )
		THEN 'BSB'
	WHEN c.category IN ( 253, 254, 255, 256, 250, 251, 252, 191, 190, 192, 237, 213, 236 )
		THEN 'CHC'
	WHEN c.category IN ( 102, 103, 244, 245, 248, 108, 149, 109, 137, 110, 111, 112, 113, 159, 115, 231, 136, 249, 232, 263, 233, 117, 160, 118, 119, 120, 121, 122, 123, 124, 133, 132, 134, 135, 138, 143, 125, 151, 126, 127, 128, 129, 130, 226, 208, 261, 262, 267, 264, 265, 266, 51 )
		THEN 'ICT'
	END Faculty,
	/*CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', CONCAT(u.firstname, ' ', u.lastname), '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', cm.id, '">', a.name, '</a>' ) Assessment,
	/*CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainers.trainer_id, '">', Trainers.trainer_name, '</a>' ) Trainer,*/
	/*asub.status, asub.attemptnumber,*/
	DATE(FROM_UNIXTIME(MIN(asub.timemodified))) Week_From, DATE(FROM_UNIXTIME(MAX(asub.timemodified))) Week_To,
	YEARWEEK(FROM_UNIXTIME(asub.timemodified)) Week_Number, COUNT(asub.id) Total_Submissions
	
FROM prefix_course c
JOIN prefix_enrol e ON e.courseid = c.id
JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
JOIN prefix_user u ON u.id = ue.userid
JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
JOIN prefix_assign a ON a.course = c.id
JOIN prefix_assign_submission asub ON asub.assignment = a.id AND asub.userid = u.id
/*JOIN prefix_course_modules cm ON cm.instance = a.id AND cm.course = c.id*/

WHERE u.suspended = 0
AND ue.status = 0
AND ue.timeend = ''
/* Live courses */
AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
/* Live courses + archives */
/*AND c.category NOT IN ( 46, 1, 48, 15, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 50, 5, 44, 9, 101 )*/
AND asub.status = 'submitted'
/*AND DATEDIFF( CURDATE(), FROM_UNIXTIME(asub.timemodified) ) <= 35*/

%%FILTER_SEARCHTEXT:Faculty:~%%
%%FILTER_STARTTIME:asub.timemodified:>%%
%%FILTER_ENDTIME:asub.timemodified:<%%

/*GROUP BY c.id, YEARWEEK(FROM_UNIXTIME(asub.timemodified))*/
GROUP BY Faculty, Week_Number

ORDER BY Faculty ASC, Week_Number DESC