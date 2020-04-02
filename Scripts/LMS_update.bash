#!/bin/bash
prev=$(pwd)
cookie="./Out/cookies.txt"
html="./Out/html.html"
result="./Out/result.html"
cd /mnt/c/Users/andrews/Downloads/
mkdir -p ./Out
rm ./Out/*
#
# Login to LMS, store cookies for session data
curl "https://lms.upskilled.edu.au/login/index.php" --data-urlencode "username=sir.skeksalot@gmail.com" --data-urlencode "password==DElicious1" --cookie $cookie --cookie-jar $cookie --location --verbose > $html
# Update
curl "https://lms.upskilled.edu.au/course/modedit.php?update=546660" --data-urlencode "name=eLearning - Windows 10 Configuring (70-697) : Part 9 - Manage Updates and Recovery - 2hr 56min" --data-urlencode "typeid=0" --data-urlencode "toolurl=https://sso.pluralsight.com/lti/courses/windows-10-configuring-70-697-manage-updates-recovery" --data-urlencode "launchcontainer=1" --data-urlencode "icon=" --cookie $cookie --cookie-jar $cookie --location --verbose > $result
#
cd $prev
# POST to https://lms.upskilled.edu.au/course/modedit.php
# {
# 	"Form data":{
# 		"urlmatchedtypeid":"4",
# 		"completionunlocked":"1",
# 		"course":"3930",
# 		"coursemodule":"546658",
# 		"section":"1",
# 		"module":"20",
# 		"modulename":"lti",
# 		"instance":"87644",
# 		"add":"0",
# 		"update":"546658",
# 		"return":"0",
# 		"sr":"0",
# 		"sesskey":"2Tvc0oqS4p",
# 		"_qf__mod_lti_mod_form":"1",
# 		"mform_showmore_id_general":"1",
# 		"mform_showmore_id_modstandardelshdr":"1",
# 		"mform_isexpanded_id_general":"1",
# 		"mform_isexpanded_id_privacy":"1",
# 		"mform_isexpanded_id_modstandardgrade":"0",
# 		"mform_isexpanded_id_modstandardelshdr":"1",
# 		"mform_isexpanded_id_availabilityconditionsheader":"1",
# 		"mform_isexpanded_id_activitycompletionheader":"1",
# 		"name":"eLearning+-+Windows+10+Configuring+(70-697):+Part+7+-+Manage+Remote+Access+-+2hr+14min",
# 		"introeditor[text]":"",
# 		"introeditor[format]":"1",
# 		"introeditor[itemid]":"954907485",
# 		"showtitlelaunch":"1",
# 		"typeid":"0",
# 		"toolurl":"https://sso.pluralsight.com/lti/courses/windows-10-configuring-70-697-manage-remote-access",
# 		"securetoolurl":"",
# 		"launchcontainer":"1",
# 		"resourcekey":"",
# 		"password":"",
# 		"instructorcustomparameters":"",
# 		"icon":"",
# 		"secureicon":"",
# 		"instructorchoicesendname":"0",
# 		"instructorchoicesendemailaddr":"0",
# 		"instructorchoiceacceptgrades":"0",
# 		"grade[modgrade_type]":"none",
# 		"visible":"1",
# 		"cmidnumber":"",
# 		"availabilityconditionsjson":"{\"op\":\"&\",\"c\":[],\"showc\":[]}",
# 		"completion":"1",
# 		"submitbutton2":"Save+and+return+to+course"
# 	},
#	"Request payload":{
# 		"EDITOR_CONFIG":{
# 			"text":"urlmatchedtypeid=4&completionunlocked=1&course=3930&coursemodule=546658&section=1&module=20&modulename=lti&instance=87644&add=0&update=546658&return=0&sr=0&sesskey=2Tvc0oqS4p&_qf__mod_lti_mod_form=1&mform_showmore_id_general=1&mform_showmore_id_modstandardelshdr=1&mform_isexpanded_id_general=1&mform_isexpanded_id_privacy=1&mform_isexpanded_id_modstandardgrade=0&mform_isexpanded_id_modstandardelshdr=1&mform_isexpanded_id_availabilityconditionsheader=1&mform_isexpanded_id_activitycompletionheader=1&name=eLearning+-+Windows+10+Configuring+%2870-697%29%3A+Part+7+-+Manage+Remote+Access+-+2hr+14min&introeditor%5Btext%5D=&introeditor%5Bformat%5D=1&introeditor%5Bitemid%5D=954907485&showtitlelaunch=1&typeid=0&toolurl=https%3A%2F%2Fsso.pluralsight.com%2Flti%2Fcourses%2Fwindows-10-configuring-70-697-manage-remote-access&securetoolurl=&launchcontainer=1&resourcekey=&password=&instructorcustomparameters=&icon=&secureicon=&instructame=0&instrorchoicesendnuctorchoicesendemailaddr=0&instructorchoiceacceptgrades=0&grade%5Bmodgrade_type%5D=none&visible=1&cmidnumber=&availabilityconditionsjson=%7B%22op%22%3A%22%26%22%2C%22c%22%3A%5B%5D%2C%22showc%22%3A%5B%5D%7D&completion=1&submitbutton2=Save+and+return+to+course",
#			"mode":"text/html"
# 		}
# 	}
# }