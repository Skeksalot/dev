/* No platform specifics were given, this is built for use within a console on a linux environemnt */
/* Written by Andrew Skeklios, 14/10/2019 */

#include <cstdlib>
#include <cstring>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main( int argc, char* argv[] ) {
	// Declare everything as stated
	int val1;
	int val2;
	char buffer[128];
	string fileName;
	fstream reader;

	// Collect filename
	cout << "Enter the filename (Must be in the same directory as this program):" << endl;
	cin.getline( buffer, 128 );
	fileName = buffer;

	// Process filename
	fileName = fileName.substr( strspn( fileName.c_str(), " " ), fileName.length() );
	
	// Attempt to open file for use
	reader.open( fileName.c_str(), fstream::in );
	
	/*

	'IF' Approach

	// Check for failure, with colour and sound
	if ( !reader.good() ) {
		printf("\x1B[41mError reading file. Check filename and try again: %s\033[0m\7\n", fileName.c_str() );
		return 1;
	}
	*/

	// Check for failure, with colour and sound
	while( !reader.good() ) {
		printf("\x1B[41mError reading file. Check filename and try again: %s\033[0m\7\n", fileName.c_str() );
		
		// Collect filename
		cout << "Enter the filename (Must be in the same directory as this program):" << endl;
		cin.getline( buffer, 128 );
		fileName = buffer;

		// Process filename
		fileName = fileName.substr( strspn( fileName.c_str(), " " ), fileName.length() );
		
		// Attempt to open file for use
		reader.open( fileName.c_str(), fstream::in );
	}

	// Read values, assuming values are on separate consecutive lines
	reader.getline( buffer, 128 );
	val1 = atoi(buffer);
	reader.getline( buffer, 128 );
	val2 = atoi(buffer);
	
	// Close immediately
	reader.close();

	// Calculate average
	cout << ((float)val1 + (float)val2) / 2 << endl;
	//cout << 0 << endl;

	return 0;
}