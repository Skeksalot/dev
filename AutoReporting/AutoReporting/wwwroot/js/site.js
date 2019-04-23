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
	var downLink = document.createElement("a");
	downLink.hidden = true;
	downLink.download = name.trim() + "_Unmarked.xlsx";
	downLink.href = "https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=181&courseid=1&filter_searchtext=" + name.trim() + "&submitbutton=Apply&download=1&format=xls";
	downLink.click();
}

function DownloadSelect(input) {
	// Input Validation done pre-call with HTML5 pattern matching
	
	// Split out individual trainers
	var names = input.split(',');
	// Download reports
	var i = 0;
	var prog = 0;
	var progBar = document.getElementById("progress");
	progBar.style.display = "block";
	for (i; i < names.length; i++) {
		// Calculate progress and update the bar
		prog = Math.round(i / names.length);
		progBar.width = prog + "%";
		progBar.setAttribute("aria-valuenow", prog);
		//setTimeout(DownloadClick(names[i]), 2000);
		//alert("Selected trainer reports downloaded:\n" + names[i].trim());
		//DownloadClick(names[i]);
	}
	// Update progress bar as complete
	progBar.width = "100%";
	progBar.setAttribute("aria-valuenow", 100);
	progBar.innerHTML = "Download Complete";
	//alert("Selected trainer reports downloaded:\n" + input.value);
	return;
}
