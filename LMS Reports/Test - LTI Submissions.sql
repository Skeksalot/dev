/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=281
*/
SELECT l.name,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) Student,
	FROM_UNIXTIME(ls.datesubmitted), FROM_UNIXTIME(ls.dateupdated), ls.gradepercent, ls.originalgrade, ls.launchid, ls.state

FROM prefix_lti_submission ls
JOIN prefix_lti l ON l.id = ls.ltiid
JOIN prefix_user u ON u.id = ls.userid