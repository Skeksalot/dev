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
using System.Data;

namespace CSharpProject_ASkek
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	/// 
	public partial class MainWindow : Window
	{
		private List<Stock> StockList;
		private DataSet StockSet;
		private DataTable StockTable;
		public MainWindow()
		{
			// Initialisation of components
			InitializeComponent();
			StockList = new List<Stock>();
			StockSet = new DataSet("CurrentStock");
			// Creating the backend data structures for storing and displaying data
			StockTable = StockSet.Tables.Add("Stock");
			DataColumn stockID = StockTable.Columns.Add("Item_Code", typeof(string));
			StockTable.Columns.Add("Description", typeof(string));
			StockTable.Columns.Add("Current_Count", typeof(int));
			StockTable.Columns.Add("On_Order", typeof(OrderStatus));
			StockTable.PrimaryKey = new DataColumn[] { stockID };
		}
	
		// Method for opening CSV stock file
		private void ReadStock()
		{
			// Open a dialog box, default location set to C://
			string path = "";
			
			OpenFileDialog fileDialog = new OpenFileDialog();
			fileDialog.InitialDirectory = "C://";
			fileDialog.Filter = "comma separated value files (*.csv)|*.csv|text files (*.txt*)|*.txt";
			if (fileDialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
			{
				// If all is ok from the fileDialog, set the path for the file
				path = fileDialog.FileName;
			}
			// Open a FileStream to read from the csv file
			StreamReader fs = null;
			try {
				fs = new StreamReader(new FileStream(path, FileMode.Open, FileAccess.Read));
				string newLine = "";
				// Pull out headers to use in display
				string[] headers = fs.ReadLine().Trim().Split(',');
				while ( (newLine = fs.ReadLine()) != null )
				{
					// Read all lines and create stock lisitings for each line
					string[] temp = newLine.Trim().Split(',');
					//StockList.Append(new Stock( temp[0], temp[1], int.Parse(temp[2]), Stock.ToStatus(temp[3]) ));
					StockList.Add(new Stock(temp[0], temp[1], int.Parse(temp[2]), Stock.ToStatus(temp[3])));
				}
			}
			finally
			{
				// Release the file, close the reader
				fs.Close();
			}
			// Clear any existing data from the DataGrid
			StockTable.Clear();
			// Process data into the user view
			if (StockList.Count > 0)
			{
				DataRow row;
				for (int i = 0; i < StockList.Count; i++)
				{
					Stock temp = StockList.ElementAt(i);
					row = StockTable.NewRow();
					row["Item_Code"] = temp.ItemCode;
					row["Description"] = temp.Description;
					row["Current_Count"] = temp.Count;
					row["On_Order"] = temp.OnOrder;
					StockTable.Rows.Add(row);
				}
				Stocks_DataGrid.DataContext = StockTable;
				Stocks_DataGrid
				Console.Write(StockList.ToString());
				Console.Write(Stocks_DataGrid.ToString());
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

		private void DataView_SelectionChanged(object sender, SelectionChangedEventArgs e)
		{

		}
	}
}
