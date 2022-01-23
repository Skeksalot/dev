/*
https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=309
*/

SELECT DISTINCT c.shortname Course, COUNT(Students.student_id) Active_Students

FROM prefix_course c
JOIN prefix_lti l ON l.course = c.id
JOIN prefix_course_modules cm ON cm.course = c.id AND cm.instance = l.id AND cm.module = 20
JOIN (
    SELECT DISTINCT e.courseid course_id, u.id student_id, CONCAT(u.firstname, ' ', u.lastname) student_name,
    u.suspended student_account, ue.status student_status, ue.timeend student_end
    FROM prefix_enrol e
    JOIN prefix_user_enrolments ue ON ue.enrolid = e.id
    JOIN prefix_user u ON u.id = ue.userid
    JOIN prefix_role_assignments ra ON ra.userid = u.id AND ra.roleid = 5
    JOIN prefix_context x ON x.contextlevel = 50 AND x.id = ra.contextid AND x.instanceid = e.courseid
   
    WHERE u.suspended = 0
    AND ue.status = 0
    AND ( ue.timeend = '' OR DATEDIFF( CURDATE(), FROM_UNIXTIME(ue.timeend) ) <= 0 )
) Students ON Students.course_id = c.id

WHERE c.category NOT IN ( 46, 1, 48, 15, 51, 158, 153, 38, 72, 73, 38, 39, 37, 35, 75, 58, 36, 74, 66, 194, 54, 236, 50, 55, 181, 5, 44, 9, 101, 52, 30, 31, 32, 23, 26 )
AND ( ( l.typeid = 13 ) OR ( l.instructorcustomparameters REGEXP 'unit_code=' ) )

GROUP BY c.id

ORDER BY Course ASC