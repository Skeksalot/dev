/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=298
*/

SELECT CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course

FROM prefix_course c

WHERE c.shortname REGEXP '2020'