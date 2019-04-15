//import { setTimeout } from "timers";

// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.

function DownloadAll() {

	// Load full trainer list

	// Cycle through list and download reports

	// Inform the user
	alert("All trainer reports downloaded.");
	return;
}

function DownloadClick(name) {
	var downLink = document.getElementById("download");
	downLink.download = name.trim() + "_Unmarked.xlsx";
	downLink.href = "https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=181&courseid=1&filter_searchtext=" + name.trim() + "&submitbutton=Apply";
	downLink.click();
}

function DownloadSelected() {

	// Grab trainer lsit from input
	var input = document.getElementById("trainer-list");

	// Input Validation with HTML5 pattern matching
	if ( !input.checkValidity() ) {
		// Invalid input, report back to the user
		alert(input.validationMessage);
	} else {
		// Names entered and ok
		// Split out individual trainers
		var names = input.value.split(',');
		// Download reports
		var i = 0;
		for (i; i < names.length; i++) {
			//setTimeout(DownloadClick(names[i]), 2000);
			
			alert("Selected trainer reports downloaded:\n" + names[i].trim());
			DownloadClick(names[i]);
		}
		// Inform the user
		//alert("Selected trainer reports downloaded:\n" + input.value);
	}
	return;
}
