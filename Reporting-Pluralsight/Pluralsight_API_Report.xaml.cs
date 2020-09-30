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
using Newtonsoft.Json;

namespace API_Reporting
{
	/// <summary>
	/// Interaction logic for Course_Usage.xaml
	/// </summary>
	public partial class Pluralsight_API_Report : Page
	{
		public Pluralsight_API_Report()
		{
			InitializeComponent();
		}
		// Custom constructor, passing selected Pluralsight API endpoint (& options)
		// TODO expand with passing options and defaults
		public Pluralsight_API_Report(object data) : this()
		{
			// Bind to passed API selection and options
			this.DataContext = data;
		}
		private void Nav_To_Home(object sender, RoutedEventArgs e)
		{
			API_Controller home = new API_Controller();
			this.NavigationService.Navigate(home);
		}
		private void Nav_To_API(object sender, RoutedEventArgs e)
		{
			API_Controller api = new API_Controller();
			this.NavigationService.Navigate(api);
		}

		private void Nav_To_User_Search(object sender, RoutedEventArgs e)
		{
			User_Search userSearchPage = new User_Search();
			this.NavigationService.Navigate(userSearchPage);
		}
	}
}
