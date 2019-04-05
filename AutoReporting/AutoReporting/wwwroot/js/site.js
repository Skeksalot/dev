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

		// Download reports

		// Inform the user
		alert("Selected trainer reports downloaded:\n" + input.value);
	}
	return;
}