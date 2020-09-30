/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=186
*/
SELECT DISTINCT Student_Name, Student_ID, Student_Email, Last_Access, Days_Since_Login,
	Trainer_Name, Course, Course_Identifier, Course_ID, Enrolment_Identifier
	/*, Group_Name*/

FROM (
(
	SELECT DISTINCT
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Student.Sid, '">', Student.Sfirst, ' ', Student.Slast, '</a>' ) Student_Name,
		Student.Sid Student_ID, Student.Email Student_Email,
		CASE 
			WHEN Student.Lastaccess IS NULL THEN ''
			WHEN Student.Lastaccess = 0 THEN ''
			ELSE DATE_FORMAT( FROM_UNIXTIME(Student.Lastaccess), '%Y-%m-%d')
		END Last_Access,
		CASE 
			WHEN Student.Lastaccess IS NULL THEN ''
			WHEN Student.Lastaccess = 0 THEN ''
			ELSE DATEDIFF( SYSDATE(), FROM_UNIXTIME( Student.Lastaccess ) )
		END Days_Since_Login,
		GROUP_CONCAT( DISTINCT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainer.Tid, '">', Trainer.Tfirst, ' ', Trainer.Tlast,  '</a>' ) ) Trainer_Name,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
		c.idnumber Course_Identifier, c.id Course_ID, CONCAT( Student.Sid, c.id ) Enrolment_Identifier, c.shortname Course_Short, Student.Sgroup Group_Name
  	
	FROM
	(
		SELECT DISTINCT t.firstname Tfirst, t.lastname Tlast, t.id Tid, e.courseid Cid, Groupst.groupid Tgroupid, Groupst.name Tgroup
		FROM prefix_enrol e
		JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
		JOIN prefix_user t ON t.id = ue.userid
		JOIN prefix_role_assignments ra ON ra.userid = t.id AND ra.roleid IN (3, 4)
		JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
		LEFT JOIN (
			SELECT gm.id groupmemberid, gm.timeadded, gm.groupid linkedgroupid, gm.userid, g.id groupid, g.name, g.courseid
			FROM prefix_groups_members gm
			JOIN prefix_groups g ON g.id = gm.groupid
		) Groupst ON Groupst.userid = t.id AND Groupst.courseid = e.courseid
		
		WHERE t.firstname IS NOT NULL
		AND t.lastname IS NOT NULL
		AND t.suspended = 0
		AND ue.status = 0
		AND ue.timeend = ''
	) Trainer
	JOIN
	(
		SELECT DISTINCT u.firstname Sfirst, u.lastname Slast, u.id Sid, e.courseid Cid, u.email Email, u.lastaccess Lastaccess, ue.timeend Enddate, Groups.groupid Sgroupid, Groups.name Sgroup
		
		FROM prefix_enrol e
		JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
		JOIN prefix_user u ON u.id = ue.userid
		JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
		JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
		LEFT JOIN (
			SELECT gm.id groupmemberid, gm.timeadded, gm.groupid linkedgroupid, gm.userid, g.id groupid, g.name, g.courseid
			FROM prefix_groups_members gm
			JOIN prefix_groups g ON g.id = gm.groupid
		) Groups ON Groups.userid = u.id AND Groups.courseid = e.courseid

		WHERE u.suspended = 0
		AND ue.status = 0
		AND ue.timeend = ''
	) Student ON Student.Cid = Trainer.Cid AND Student.Sid <> Trainer.Tid
	JOIN prefix_course c ON c.id = Trainer.Cid
			AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	
	WHERE c.shortname IS NOT NULL
	AND Student.Sgroupid IS NULL
  
  	GROUP BY Student.Sid, c.id
)
UNION ALL
(
	SELECT DISTINCT 
  		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student_Name,
		u.id Student_ID, u.email Student_Email,
		CASE 
			WHEN u.lastaccess IS NULL THEN ''
			WHEN u.lastaccess = 0 THEN ''
			ELSE DATE_FORMAT( FROM_UNIXTIME(u.lastaccess), '%Y-%m-%d')
		END Last_Access,
		CASE 
			WHEN u.lastaccess IS NULL THEN ''
			WHEN u.lastaccess = 0 THEN ''
			ELSE DATEDIFF( SYSDATE(), FROM_UNIXTIME( u.lastaccess ) )
		END Days_Since_Login,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', t.id, '">', t.firstname, ' ', t.lastname,  '</a>' ) Trainer_Name,
		CONCAT( '<a target="_new" href="%%WWWROOT%%/enrol/users.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
		c.idnumber Course_Identifier, c.id Course_ID, CONCAT( u.id, c.id ) Enrolment_Identifier, c.shortname Course_Short, g.name Group_Name

	FROM prefix_user u
	JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
	JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid
	JOIN prefix_groups_members gm ON gm.userid = u.id
	JOIN prefix_groups g ON g.id = gm.groupid
	JOIN prefix_course c ON c.id = g.courseid AND c.id = x.instanceid
		AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
	JOIN prefix_groups_members gmt ON gmt.groupid = g.id AND gmt.id <> gm.id
	JOIN prefix_user t ON t.id = gmt.userid AND t.id <> u.id
	JOIN prefix_role_assignments rat ON rat.userid = t.id AND rat.roleid IN (3, 4, 17, 18) AND rat.contextid = x.id
	JOIN prefix_user_enrolments ue ON ue.userid = u.id
	JOIN prefix_enrol e ON e.id = ue.enrolid AND e.courseid = c.id
	JOIN prefix_user_enrolments uet ON uet.userid = t.id
	JOIN prefix_enrol et ON et.id = uet.enrolid AND et.courseid = c.id
	
	WHERE u.suspended = 0
  	AND ue.status = 0
	AND ue.timeend = ''
	AND t.suspended = 0
  	AND uet.status = 0
	AND uet.timeend = ''
) ) Merged

WHERE 1=1

%%FILTER_SEARCHTEXT:Merged.Trainer_Name:~%%

ORDER BY Days_Since_Login DESC, Merged.Course_Short, Student_Name