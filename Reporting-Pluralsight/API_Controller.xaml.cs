using System;
using System.Collections.Generic;
using System.Data;
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
using System.Xml;

namespace API_Reporting
{
	/// <summary>
	/// Interaction logic for Pluralsight_API_Control.xaml
	/// </summary>
	public partial class API_Controller : Page
	{
		private double TreeHeight()
		{
			return ActualHeight - PluralTab.ActualHeight - Header.ActualHeight - SubHeader.ActualHeight - QueryInfo.ActualHeight - QueryFieldsHeader.ActualHeight - ActionsWrapper.ActualHeight;
		}
		public API_Controller()
		{
			InitializeComponent();
			var height = TreeHeight();
			if( height > 0 )
			{
				InfoTree.Height = height;
			}
			else
			{
				InfoTree.Height = 0;
			}
		}

		private void Run_Query(object sender, RoutedEventArgs e)
		{
			if (pluralsightQueryListBox.SelectedItem != null)
			{
				// Retrieve value in selected item
				XmlElement selectedNode = (XmlElement)this.pluralsightQueryListBox.SelectedItem;
				string value = selectedNode.GetAttribute("Name");
				// View selected report
				Pluralsight_API_Report reportPage = new Pluralsight_API_Report(value);
				reportPage.Header.Content = value;
				NavigationService.Navigate(reportPage);
			}
			else
			{
				// Give 'item must be selected' error if needed
			}
		}
		
		private void Nav_To_Home(object sender, RoutedEventArgs e)
		{
			API_Controller home = new API_Controller();
			NavigationService.Navigate(home);
		}
		private void Nav_To_API(object sender, RoutedEventArgs e)
		{
			API_Controller api = new API_Controller();
			NavigationService.Navigate(api);
		}
		private void Nav_To_User_Search(object sender, RoutedEventArgs e)
		{
			User_Search userSearchPage = new User_Search();
			NavigationService.Navigate(userSearchPage);
		}

		private void Auto_Deselect(object sender, RoutedEventArgs e)
		{
			TreeViewItem item = sender as TreeViewItem;
			item.IsSelected = false;
		}
		private void TreeView_SelectedItemChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
		{
			TreeView myTreeView = sender as TreeView;
			if (myTreeView == null)
			{
				return;
			}
			TreeViewItem selectedItem = myTreeView.SelectedItem as TreeViewItem;
			if (selectedItem == null)
			{
				return;
			}
			selectedItem.IsSelected = false;
			myTreeView.ReleaseMouseCapture();
		}
		private void TreeView_ScrollChanged(object sender, ScrollChangedEventArgs e)
		{
			TreeView origin = (TreeView)sender;
			DetailsScroller.ScrollToVerticalOffset(e.VerticalOffset);
		}

		private void pluralsightQueryFields_SizeChanged(object sender, SizeChangedEventArgs e)
		{
			var height = TreeHeight();
			if ( height > 0 )
			{
				InfoTree.Height = height;
			}
			else
			{
				InfoTree.Height = 0;
			}
		}
	}
}
