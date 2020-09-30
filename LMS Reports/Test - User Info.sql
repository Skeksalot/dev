/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=181
*/
SELECT DISTINCT CONCAT(u.id, c.id) Enrolment_Id, 
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', IFNULL(c.shortname, '-No Name-'), '</a>' ) Course,
	Groups.groupmemberid Group_Member_Id, FROM_UNIXTIME(Groups.timeadded) Time_Added, Groups.linkedgroupid Joined_Group, Groups.groupid Group_Id, Groups.name Group_Name,
	CASE 
		WHEN ra.roleid = 5 THEN 'Participant'
		WHEN ra.roleid = 3 THEN 'Editing Trainer - Primary'
		WHEN ra.roleid = 4 THEN 'Trainer - Primary'
		WHEN ra.roleid = 17 THEN 'Editing Trainer - Secondary'
		WHEN ra.roleid = 18 THEN 'Trainer - Secondary'
		ELSE ''
	END Role_Assignment
	-- , ue.status Status, ue.timeend End_Date, x.instanceid Context_Instanceid

FROM prefix_enrol e
JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
JOIN prefix_user u ON u.id = ue.userid
JOIN prefix_course c ON c.id = e.courseid
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

%%FILTER_SEARCHTEXT:CONCAT(u.firstname, ' ', u.lastname):~%%

ORDER BY u.id