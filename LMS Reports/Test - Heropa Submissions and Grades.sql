/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=311
*/

SELECT DISTINCT CONCAT( u.firstname, ' ', u.lastname ) Student,
	CONCAT( '<a href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '" target="_blank">Profile Link</a>' ) Profile_Link,
	l.name Lab_Name,
	CONCAT( '<a href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '" target="_blank">Lab Link</a>' ) Lab_Module_Link,
	FROM_UNIXTIME(ls.datesubmitted) Date_Submitted, ls.gradepercent Grade

FROM prefix_lti_submission ls
JOIN prefix_lti l ON l.id = ls.ltiid
JOIN prefix_user u ON u.id = ls.userid
JOIN prefix_course_modules cm ON cm.course = l.course AND cm.instance = l.id AND cm.module = 20

WHERE LOWER(l.name) REGEXP '[ ]{0,1}Assessment[ ][\\–\\-]'

ORDER BY Student, Date_Submitted