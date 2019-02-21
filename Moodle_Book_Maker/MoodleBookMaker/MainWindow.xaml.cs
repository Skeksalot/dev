using Microsoft.Win32;
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Forms;

namespace MoodleBookMaker {
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window {

		private string srcPath;
		private DialogResult overwrite = System.Windows.Forms.DialogResult.Cancel;

		public MainWindow() {
			InitializeComponent();
		}

		private void Load_Click( object sender, RoutedEventArgs e ) {
			// Open a file dialog to locate source file
			Microsoft.Win32.OpenFileDialog srcFileDialog = new Microsoft.Win32.OpenFileDialog();

			//srcFileDialog.InitialDirectory = @"C:\";
			srcFileDialog.Title = "Select Source File";
			srcFileDialog.CheckFileExists = true;
			srcFileDialog.CheckPathExists = true;
			srcFileDialog.DefaultExt = "html";
			srcFileDialog.Filter = "HTML files (*.html)|*.html|All files (*.*)|*.*";
			srcFileDialog.FilterIndex = 2;
			srcFileDialog.RestoreDirectory = true;
			srcFileDialog.ReadOnlyChecked = true;
			srcFileDialog.ShowReadOnly = true;
			// Update the textbox with the name
			//if ( srcFileDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK ) {
			if ( srcFileDialog.ShowDialog() == true ) {
				srcPath = srcFileDialog.FileName;
				Source.Text = srcPath;
				Sample.Text = File.ReadAllText( srcPath );
			}

		}

		private void Create_Click( object sender, RoutedEventArgs e ) {
			
			if ( Source.Text.Equals( "Source File" ) ) {

				System.Windows.MessageBox.Show( "Please select a source file" );

			} else if ( PageName.Text == "Base Name For Output Pages" ) {

				System.Windows.MessageBox.Show( "Give a base name for the pages" );

			} else {
				// Separate path for new files from srcPath
				string newPath = srcPath.Remove( srcPath.LastIndexOf( '\\' ) + 1 );
				//System.Windows.MessageBox.Show( newPath );

				// Construct the necessary wrapper for each page
				string head = Sample.Text.Remove( Sample.Text.IndexOf( "<div" ) );
				//System.Windows.MessageBox.Show( head );
				string tail = Sample.Text.Substring( Sample.Text.LastIndexOf( "</div>" ) + 6 );
				//System.Windows.MessageBox.Show( tail );

				// Split into individual pages
				string[] separator = { "<div class=\"slide\"" };
				string[] pages = Sample.Text.Split( separator, System.StringSplitOptions.RemoveEmptyEntries );

				// Set up progress bar
				Progress.Visibility = System.Windows.Visibility.Visible;

				for( int i = 1; i < pages.Length; i++ ) {
					// Write page to same directory as source
					string fullPage = head + separator[0] + pages[i] + tail;
					//System.Windows.MessageBox.Show( fullPage );

					// Check for existing file clashes
					string curFile = newPath + PageName.Text + " - Page " + i + ".html";

					if( System.IO.File.Exists( curFile ) ) {
						// Found a file clash

						if ( overwrite == System.Windows.Forms.DialogResult.No ) {
							// User has chosen not to overwrite files

						} else if( overwrite == System.Windows.Forms.DialogResult.Yes ) {
							// User has chosen to overwrite files
							System.IO.File.WriteAllText( curFile, fullPage );
						} else {
							// overwrite set to Cancel, first clash found
							overwrite = System.Windows.Forms.MessageBox.Show( curFile + " already exists. Do you want to overwrite any existing files?", "File already exists", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question );
							if ( overwrite == System.Windows.Forms.DialogResult.Cancel ) {
								// User cancelled the process, stop writing pages
								break;
							} else if ( overwrite == System.Windows.Forms.DialogResult.Yes ) {
								// Write the file and continue
								System.IO.File.WriteAllText( curFile, fullPage );
							} else {
								// Don't write the file, but still continue
							}
						}
					} else {
						// Not a clash, go and write the file
						System.IO.File.WriteAllText( curFile, fullPage );
					}
					Progress.Value = i / pages.Length;
				}
				System.Windows.MessageBox.Show( "End of printing." );
				overwrite = System.Windows.Forms.DialogResult.Cancel;
				Progress.Visibility = System.Windows.Visibility.Hidden;
				Progress.Value = 0;
			}
		}
	}
}
