/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=295
*/
SELECT CONCAT( '<a target="_new" href="%%WWWROOT%%/course/view.php', char(63), 'id=', c.id, '">', c.shortname, '</a>' ) Course,
	cs.id Section_ID, cs.name Section, REPLACE(cs.summary, '<', '>') Summary

FROM prefix_course c
JOIN prefix_course_sections cs ON cs.course = c.id

WHERE cs.summary REGEXP '<script [a-zA-Z0-9 \-_=".:/]{0,}><\/script>'
-- Everything not archived
AND c.category NOT IN (50, 55, 236, 51, 257)