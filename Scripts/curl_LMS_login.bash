#!/bin/bash
prev=$(pwd)
cookie="./Out/cookies.txt"
html="./Out/html.html"
report="./Out/report.html"
table="./Out/table.html"
csv="./Out/data.csv"
edit="./Out/edited.csv"
timestamp=$(date "+%Y%m%d-%H%M%S")
log="./Out/log_$timestamp.txt"
cd /mnt/c/Users/andrews/Downloads/
mkdir -p ./Out
rm ./Out/*
touch $log
#
# Login to LMS, store cookies for session data
curl "https://lms.upskilled.edu.au/login/index.php" --data-urlencode "username=sir.skeksalot@gmail.com" --data-urlencode "password==DElicious1" --cookie $cookie --cookie-jar $cookie --location --verbose > $html
# Retrieve relevant report
curl "https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=245" --cookie $cookie --cookie-jar $cookie > $report
# Parse report and extract data table
grep -E -w -i "<td|<th" $report > $table
sed -r "s/<\/td>|<\/th>/,/g" $table > $csv
sed -i -r "s/<[0-9a-zA-Z\"'=:; _-]{1,}>|<\/td>//g" $csv
sed -i -r "s/<\/tr>|<\/thead>//g" $csv
sed -i -r "s/,\n|,$|//g" $csv
#sed -i -r "s/\/app\./\/sso\./g" $csv
# Iterate over data entries and make updates via POST
IFS=","
while read i; do
	read -ra strarr <<< "$i"
	# Perform update here, and log changes
	echo "FROM Name: ${strarr[0]} Tool: ${strarr[1]}" >> $log
	#strarr[0]=${strarr[0]//((- )?\(?([0-9]+)\s?(hrs|hr|h)\)?)/- $3hr}
	strarr[0]=$(echo "${strarr[0]}" | sed -rn "s/(((- )?|(– )?)\(?([0-9]+)\s?(hrs|hr|h)\)?)/- \5hr/p" | sed -rn "s/(([0-9]+)\s?(mins|min|m)\)?)/\2min/p")
	strarr[1]=${strarr[1]//\/schools/}
	strarr[1]=${strarr[1]//\/app./\/sso.}
	# Push update to LMS
	#
	echo "TO Name: ${strarr[0]} Tool: ${strarr[1]}" >> $log
done < $csv
#
cd $prev
#
### REFERENCES ###
#https://ec.haxx.se/http/http-post
#https://coderwall.com/p/iy3iqw/use-curl-to-login-to-a-site-with-cookie-sessions
#https://www.howtogeek.com/496056/how-to-use-the-grep-command-on-linux/
#https://askubuntu.com/questions/962551/extract-the-content-from-a-file-between-two-match-patterns-extract-only-html-fr
#https://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash
#https://regexr.com/
#https://www.tutorialkart.com/bash-shell-scripting/bash-split-string/
#https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
#https://www.thegeekstuff.com/2010/07/bash-string-manipulation/
#https://stackoverflow.com/questions/2777579/how-to-output-only-captured-groups-with-sed
#https://unix.stackexchange.com/questions/93674/how-to-assign-result-of-sed-to-variable