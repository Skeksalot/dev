/*
https://upskilledtest30.androgogic.com.au/blocks/configurable_reports/editcomp.php?id=210&comp=customsql
*/
CREATE OR REPLACE VIEW Trainers AS
	SELECT DISTINCT t.firstname, t.lastname, t.id, e.courseid, ra.roleid
	FROM prefix_enrol e
	JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
	JOIN prefix_user t ON t.id = ue.userid
	JOIN prefix_role_assignments ra ON ra.userid = t.id AND ra.roleid IN (3, 4, 17, 18)
	JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
-- Live site uses group_members, test site uses groups_members
	-- LEFT JOIN prefix_group_members gm ON gm.userid = t.id
	LEFT JOIN prefix_groups_members gm ON gm.userid = t.id
	LEFT JOIN prefix_groups g ON g.id = gm.groupid AND g.courseid = e.courseid
	WHERE t.firstname IS NOT NULL
		AND t.lastname IS NOT NULL
		AND t.suspended = 0
		AND ue.status = 0
		AND ue.timeend = ''

SELECT *
FROM Trainers

CREATE OR REPLACE VIEW Courses AS
SELECT DISTINCT c.fullname, c.shortname, c.idnumber, c.category, c.id
FROM prefix_course c

SELECT *
FROM Courses