/*
https://lms.upskilled.edu.au/blocks/configurable_reports/editcomp.php?id=288
*/
SELECT l.name, cm.id

FROM prefix_label l
JOIN prefix_course_modules cm ON cm.instance = l.id AND cm.course = l.course

WHERE LOWER(l.intro) REGEXP 'http(s){0,1}://rebrand.ly'