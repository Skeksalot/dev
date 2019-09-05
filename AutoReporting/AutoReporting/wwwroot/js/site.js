//import { setTimeout } from "timers";

// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.

// Handler for maintaining state changes when buttons are clicked.
function checkboxStateHandler(checkBox, container) {
	checkBox.checked = !checkBox.checked;
	// In order to keep the opacity change on mouseover, the background is altered instead
	if (checkBox.checked) {
		if ( container.className.includes('bus') ) {
			container.style.background = 'linear-gradient( 225deg, rgba(22,150,236,0.8), rgba(21,72,224,0.75) )';
		} else if ( container.className.includes('chc') ) {
			container.style.background = 'linear-gradient( 225deg, rgba(236,34,98,0.8), rgba(144,16,76,0.75) )';
		} else if ( container.className.includes('ict') ) {
			container.style.background = 'linear-gradient( 225deg, rgba(242,184,30,0.8), rgba(204,132,10,0.75) )';
		}
	} else {
		if ( container.className.includes('bus') ) {
			container.style.background = 'linear-gradient( 225deg, rgba(22,150,236,1), rgba(21,72,224,1) )';
		} else if ( container.className.includes('chc') ) {
			container.style.background = 'linear-gradient( 225deg, rgba(236,34,98,1), rgba(144,16,76,1) )';
		} else if ( container.className.includes('ict') ) {
			container.style.background = 'linear-gradient( 225deg, rgba(242,184,30,1), rgba(204,132,10,1) )';
		}
	}
}

// Method to retrieve all selected trainers. Returns an array of trainer names selected as strings.
function getSelectedTrainers() {
	// Iterate over all buttons, check if they're selected, collect and return the results
	// Collecting buttons
	var buttons = [document.getElementsByClassName('btn-bus'), document.getElementsByClassName('btn-chc'), document.getElementsByClassName('btn-ict')];
	var selected = [];
	// Iterating over them all
	for (var i = 0; i < buttons.length; i++ ) {
		for (var j = 0; j < buttons[i].length; j++ ) {
			// Check selection state
			var temp = buttons[i][j].getElementsByTagName('input')[0];
			if (temp.checked) {
				// Gather into dataset selected trainers
				selected.push( temp.id.substring(0, temp.id.length-5).replace('_', ' ') );
			}
		}
	}
	//alert(selected.toString());
	return selected;
}

// Selects all trainer buttons
function allTrainers() {
	var buttons = [document.getElementsByClassName('btn-bus'), document.getElementsByClassName('btn-chc'), document.getElementsByClassName('btn-ict')];
	// Iterating over them all
	for (var i = 0; i < buttons.length; i++) {
		for (var j = 0; j < buttons[i].length; j++) {
			// Check selection state
			var temp = buttons[i][j].getElementsByTagName('input')[0];
			if (!temp.checked) {
				// If not selected, flip state
				checkboxStateHandler(temp, buttons[i][j]);
			}
		}
	}
}

// Clears selection of trainer buttons
function clearTrainers() {
	var buttons = [document.getElementsByClassName('btn-bus'), document.getElementsByClassName('btn-chc'), document.getElementsByClassName('btn-ict')];
	// Iterating over them all
	for (var i = 0; i < buttons.length; i++) {
		for (var j = 0; j < buttons[i].length; j++) {
			// Check selection state
			var temp = buttons[i][j].getElementsByTagName('input')[0];
			if (temp.checked) {
				// If selected, flip state
				checkboxStateHandler(temp, buttons[i][j]);
			}
		}
	}
}

function sleep(milliseconds) {
	var start = new Date().getTime();
	for (var i = 0; i < 1e7; i++) {
		if ((new Date().getTime() - start) > milliseconds) {
			break;
		}
	}
}

// Helper for DownloadSelected below
function DownloadClick(name) {
	var downLink = document.createElement("a");
	downLink.hidden = true;
	downLink.download = name.trim() + "_Unmarked.xlsx";
	downLink.href = "https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=181&courseid=1&filter_searchtext=" + name.trim() + "&submitbutton=Apply&download=1&format=xls";
	downLink.click();
}

// Gets list of selected trainers and downloads reports
function downloadReports() {
	// No input validation needed
	
	// Get list of selected trainers
	var names = getSelectedTrainers();
	if( names.length < 1 ) {
		return;
	}
	// Download reports
	var prog = 0;
	var progOuter = document.getElementById("progressOuter");
	progOuter.style.display = "block";
	var progBar = document.getElementById("progress");
	progBar.style.display = "block";
	for (var i = 0; i < names.length; i++) {
		// Calculate progress and update the bar
		prog = Math.round(i / names.length);
		progBar.style.width = prog + "%";
		progBar.setAttribute("aria-valuenow", prog);
		//setTimeout(DownloadClick(names[i]), 2000);
		//alert("Selected trainer reports downloaded:\n" + names[i].trim());
		sleep(1000);
		//DownloadClick(names[i]);
	}
	// Update progress bar as complete
	progBar.style.width = "100%";
	progBar.setAttribute("aria-valuenow", 100);
	progBar.innerHTML = "Download Complete";
	//alert("Selected trainer reports downloaded:\n" + input.value);
	//setTimeout(function(){ document.getElementById("progressOuter").style.display = "none"; }, 2000);
}
