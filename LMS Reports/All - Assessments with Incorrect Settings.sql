/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=167
*/
SELECT DISTINCT a.name Assessment, a.attemptreopenmethod Extra_Attempts,
	CASE
		WHEN a.maxattempts = -1 THEN 'Unlimited'
		ELSE a.maxattempts
	END Max_Attempts,
	CASE
		WHEN a.submissiondrafts = 0 THEN 'No'
		ELSE 'Yes'
	END Allow_Drafts,
	CASE
		WHEN a.requiresubmissionstatement = 0 THEN 'No'
		ELSE 'Yes'
	END Require_Submit,
	GROUP_CONCAT( DISTINCT ' ', CONCAT( '<a target="_new" href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '">', c.shortname, '</a>' ) ) Assessment_Link

FROM
prefix_course c
JOIN prefix_assign a ON a.course = c.id
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = a.id

-- WHERE c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
WHERE c.category IN ( 16, 17, 18, 22, 40, 43, 145, 146, 147, 148, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 182, 184, 185, 186, 187, 188, 211, 214, 219, 220, 222, 223, 229, 230, 260 )
AND ( a.attemptreopenmethod <> 'manual'
	OR NOT ( a.maxattempts < 0 OR a.maxattempts > 2 )
	OR NOT ( a.submissiondrafts OR a.requiresubmissionstatement )
	OR ( a.cutoffdate <> 0 OR a.duedate <> 0 OR a.allowsubmissionsfromdate <> 0 ) )
AND LOWER(a.name) REGEXP 'assessment -'

GROUP BY Assessment, Extra_Attempts, Max_Attempts, Allow_Drafts, Require_Submit

ORDER BY Assessment, Extra_Attempts, Max_Attempts, Allow_Drafts, Require_Submit