/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=282
*/
SELECT a.name, apc.plugin, apc.subtype, apc.name, apc.value

FROM prefix_assign a
JOIN prefix_assign_plugin_config apc ON apc.assignment = a.id

WHERE apc.subtype = 'assignsubmission'