SELECT CONCAT( '<a target="_new" href="%%WWWROOT%%/user/profile.php', char(63), 'id=', u.id, '">', u.firstname, ' ', u.lastname, '</a>' ) User, u.id, u.maildisplay

FROM prefix_user u

WHERE u.maildisplay <> 0

ORDER BY u.id