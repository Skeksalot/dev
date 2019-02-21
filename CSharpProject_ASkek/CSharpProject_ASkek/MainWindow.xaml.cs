using System;
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
using System.IO;
using System.Windows.Forms;

namespace CSharpProject_ASkek
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{

		public MainWindow()
		{
			InitializeComponent();
		}

		// Method for opening CSV stock file
		private void ReadStock()
		{
			// Open a dialog box, default location set to C://
			string path = "";
			
			OpenFileDialog fileDialog = new OpenFileDialog();
			fileDialog.InitialDirectory = "C://";
			fileDialog.Filter = "text files|*.txt; comma separated value files|*.csv";
			if (fileDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
			{
				// If all is ok from the fileDialog, set the path for the file
				path = fileDialog.FileName;
			}
			// Open a FileStream to read from the csv file
			FileStream fs = null;
			try {
				fs = File.Open(path, FileMode.Open, FileAccess.Read);
			}
			finally
			{
				fs.Close();
			}
		}
		// Method to handle saving adjusted stock to a new file
		private void SaveStock()
		{

		}
		// Event handler for open menu item
		private void Menu_Open_Click( object sender, RoutedEventArgs e )
		{
			ReadStock();
		}
		// Event handler for save menu item
		private void Menu_Save_Click( object sender, RoutedEventArgs e )
		{
			SaveStock();
		}
	}
}
