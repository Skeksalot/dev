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

namespace Reporting_Pluralsight
{
	/// <summary>
	/// Interaction logic for Pluralsight_API_Control.xaml
	/// </summary>
	public partial class API_Controller : Page
	{
		public API_Controller()
		{
			InitializeComponent();
		}

		private void View_Report(object sender, RoutedEventArgs e)
		{
			// View Pluralsight course usage report
			Pluralsight_Course_Usage courseUsagePage = new Pluralsight_Course_Usage(this.endpointListBox.SelectedItem);
			this.NavigationService.Navigate(courseUsagePage);
		}

		private void Nav_To_Home(object sender, RoutedEventArgs e)
		{
			User_Search userSearchPage = new User_Search();
			this.NavigationService.Navigate(userSearchPage);
		}
		private void Nav_To_API(object sender, RoutedEventArgs e)
		{
			User_Search userSearchPage = new User_Search();
			this.NavigationService.Navigate(userSearchPage);
		}

		private void Nav_To_User_Search(object sender, RoutedEventArgs e)
		{
			User_Search userSearchPage = new User_Search();
			this.NavigationService.Navigate(userSearchPage);
		}
	}
}
