/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=289
*/
SELECT l.name,
	-- CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
	CONCAT( u.firstname, ' ', u.lastname ) Student, c.shortname Course,
	FROM_UNIXTIME(ls.datesubmitted) Submit_Time, ls.gradepercent Grade

FROM prefix_lti_submission ls
JOIN prefix_lti l ON l.id = ls.ltiid
JOIN prefix_user u ON u.id = ls.userid
JOIN prefix_course c ON c.id = l.course

WHERE LOWER(l.name) REGEXP 'lln'
	AND c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )

%%FILTER_STARTTIME:ls.datesubmitted:>%%
%%FILTER_ENDTIME:ls.datesubmitted:<%%