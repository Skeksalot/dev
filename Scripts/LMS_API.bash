#!/bin/bash
prev=$(pwd)
cookie="./Out/cookies.txt"
html="./Out/html.html"
result="./Out/result.json"
response="./Out/response.xml"
cd /mnt/c/Users/andrews/Downloads/
mkdir -p ./Out
rm ./Out/*
#
# Login to LMS, store cookies for session data
curl "https://lms.upskilled.edu.au/login/index.php" --data-urlencode "username=sir.skeksalot@gmail.com" --data-urlencode "password==DElicious1" --cookie $cookie --cookie-jar $cookie --location --verbose > $html
# Pre-load the edit page
curl "https://lms.upskilled.edu.au/login/token.php?service=Web+Service+Access&username=webserviceaccess&password=Webservice101" --cookie $cookie --cookie-jar $cookie --location --verbose > $result
# Set up form data
token=$(grep -E -o -i ":\"[a-zA-Z0-9]+\"" $result)
token=$(echo $token | grep -E -o -i "[a-zA-Z0-9]+")
#echo $token
curl "https://lms.upskilled.edu.au/webservice/rest/server.php?wstoken=$token&functionname=core_grades_get_grades&options[courseid]=4883&options[component]=&options[activityid]=&options[userids][0]=12431&moodlewsrestformat=json" --cookie $cookie --cookie-jar $cookie --location --verbose > $response
#
cd $prev
#
#https://benit.github.io/blog/2017/03/29/consumming-a-moodle-webservice/