/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=284
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
	CASE
		WHEN a.allowsubmissionsfromdate = 0 THEN ''
		ELSE FROM_UNIXTIME(a.allowsubmissionsfromdate)
	END Open_Date,
	CASE
		WHEN a.duedate = 0 THEN ''
		ELSE FROM_UNIXTIME(a.duedate)
	END Due_Date,
	CASE
		WHEN a.cutoffdate = 0 THEN ''
		ELSE FROM_UNIXTIME(a.cutoffdate)
	END Cutoff_Date,
	CASE
		WHEN apcEnabled.value = 0 THEN 'No'
		ELSE 'Yes'
	END Files_Enabled,
	apcMaxFiles.value Files_Max_Files,
	( apcMaxFileSize.value / (1024*1024) ) Files_Max_File_Size,
	CONCAT( '<a target="_new" href="%%WWWROOT%%/course/modedit.php', char(63), 'up', 'date=', cm.id, '">', c.shortname, '</a>' ) Assessment_Link

FROM prefix_course c
JOIN prefix_assign a ON a.course = c.id
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = a.id
JOIN prefix_assign_plugin_config apcEnabled ON apcEnabled.assignment = a.id AND apcEnabled.subtype = 'assignsubmission' AND apcEnabled.plugin = 'file' AND apcEnabled.name = 'enabled'
JOIN prefix_assign_plugin_config apcMaxFiles ON apcMaxFiles.assignment = a.id AND apcMaxFiles.subtype = 'assignsubmission' AND apcMaxFiles.plugin = 'file' AND apcMaxFiles.name = 'maxfilesubmissions'
JOIN prefix_assign_plugin_config apcMaxFileSize ON apcMaxFileSize.assignment = a.id AND apcMaxFileSize.subtype = 'assignsubmission' AND apcMaxFileSize.plugin = 'file' AND apcMaxFileSize.name = 'maxsubmissionsizebytes'

WHERE c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101 )
-- WHERE c.category IN ( 16, 17, 18, 22, 40, 43, 145, 146, 147, 148, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 182, 184, 185, 186, 187, 188, 211, 214, 219, 220, 222, 223, 229, 230, 260 )
AND ( a.attemptreopenmethod <> 'manual'
	OR NOT ( a.maxattempts < 0 OR a.maxattempts > 2 )
	OR NOT ( a.submissiondrafts OR a.requiresubmissionstatement )
	OR ( a.cutoffdate <> 0 OR a.duedate <> 0 OR a.allowsubmissionsfromdate <> 0 ) )
	OR ( apcEnabled.value <> 1 OR apcMaxFiles.value <> 15 OR apcMaxFileSize.value <> 0 )
AND LOWER(a.name) REGEXP 'assessment -'