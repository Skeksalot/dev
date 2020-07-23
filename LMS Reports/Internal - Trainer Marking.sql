/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=255
https://upskilledtest30.androgogic.com.au/blocks/configurable_reports/editcomp.php?id=212&comp=customsql&courseid=1
*/
SELECT DISTINCT
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', Trainer.id, '">', Trainer.firstname, ' ', Trainer.lastname, '</a>' ) Trainer,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', User.id, '">', User.firstname, ' ', User.lastname, '</a>' ) Student,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', Course.id, '">', Course.shortname, '</a>' ) Course,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/mod/assign/view.php', char(63), 'id=', Module.id, '">', Assign.name, '</a>' ) Assessment,
	FROM_UNIXTIME(Submission.timemodified) Submit_Time,
	Grade.grade Grade,
	FROM_UNIXTIME(Logs.timecreated) Time_Graded,
	CASE
		WHEN DATEDIFF( FROM_UNIXTIME(Logs.timecreated), FROM_UNIXTIME(Submission.timemodified) ) > 14 THEN "Yes"
		ELSE "No"
	END Overdue

FROM (
	SELECT log.relateduserid, log.realuserid, log.userid, log.courseid, log.objectid, log.timecreated
	FROM prefix_logstore_standard_log log
	WHERE LOWER(log.action) LIKE '%graded%'
	AND LOWER(log.target) LIKE '%submission%'
	AND DATEDIFF( CURDATE(), FROM_UNIXTIME(log.timecreated) ) <= 30
) Logs
JOIN (
	SELECT u.firstname, u.lastname, u.id
	FROM prefix_user u
) User ON User.id = Logs.relateduserid
JOIN (
	SELECT t.firstname, t.lastname, t.id
	FROM prefix_user t
) Trainer ON CASE WHEN Logs.realuserid IS NOT NULL THEN Trainer.id = Logs.realuserid ELSE Trainer.id = Logs.userid END
JOIN (
	SELECT c.fullname, c.shortname, c.id
	FROM prefix_course c
) Course ON Course.id = Logs.courseid
JOIN (
	SELECT ag.id, ag.assignment, ag.grade, ag.attemptnumber, ag.timemodified
	FROM prefix_assign_grades ag
) Grade ON Grade.id = Logs.objectid
JOIN (
	SELECT a.name, a.id
	FROM prefix_assign a
) Assign ON Assign.id = Grade.assignment
JOIN (
	SELECT cm.id, cm.instance, cm.course
	FROM prefix_course_modules cm
) Module ON Module.instance = Assign.id AND Module.course = Course.id
JOIN (
	SELECT s.id, s.userid, s.assignment, s.attemptnumber, s.timemodified
	FROM prefix_assign_submission s
) Submission ON Submission.userid = User.id AND Submission.assignment = Assign.id AND Submission.attemptnumber = Grade.attemptnumber

WHERE ( LOWER(Assign.name) LIKE 'assessment -%' OR LOWER(Assign.name) LIKE 'kcheck -%' )

%%FILTER_SEARCHTEXT:CONCAT(Trainer.firstname, ' ', Trainer.lastname):~%%
%%FILTER_STARTTIME:Logs.timecreated:>%%
%%FILTER_ENDTIME:Logs.timecreated:<%%

ORDER BY Trainer.lastname, Trainer.firstname, Time_Graded DESC