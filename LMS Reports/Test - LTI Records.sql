/*
https://upskilledtest30.androgogic.com.au/blocks/configurable_reports/editcomp.php?id=211&comp=customsql
*/
SELECT l.name, l.toolurl, ls.*

FROM prefix_lti l
JOIN prefix_lti_submission ls ON ls.ltiid = l.id

WHERE LOWER(l.name) LIKE 'assessment -%'