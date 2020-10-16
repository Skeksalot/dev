using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using GraphQL;
using GraphQL.Client.Http;
using GraphQL.Types;
using GraphQL.Client.Serializer.Newtonsoft;
using System.Reactive.Linq;
using System.Windows.Threading;

namespace API_Reporting
{
	/// <summary>
	/// Interaction logic for Pluralsight_API_Report.xaml
	/// </summary>
	public partial class Pluralsight_API_Report : Page
	{
		private static readonly string endpoint = "https://paas-api.pluralsight.com/graphql";
		private static readonly string key = "dXBza2lsbGVk-87d0abaedec44d64bfd5db7885cac075-UExBTg==";
		private static readonly GraphQLHttpClient graphQLClient = new GraphQLHttpClient(endpoint, new NewtonsoftJsonSerializer());
		private readonly string reportName = "";
		private GraphQLResponse<Data> response;
		public Pluralsight_API_Report()
		{
			InitializeComponent();
			UserList.DataContext = response;
		}
		// Custom constructor, passing selected Pluralsight API endpoint (& options)
		public Pluralsight_API_Report(Dictionary<string, string> input) : this()
		{
			InitializeComponent();
			UserList.DataContext = response;
			// Bind to passed API selection and options
			reportName = input["report"];
			if (!string.IsNullOrEmpty(reportName)) {
				SubHeaderText.Content = reportName;
			}
			if( !graphQLClient.HttpClient.DefaultRequestHeaders.Contains("Authorization") )
			{
				graphQLClient.HttpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + key + " ");
			}
		}
		private async void Page_Loaded(object sender, RoutedEventArgs e)
		{
			// Create the query based on which report has been requested
			var query = new GraphQLRequest
			{
				Query = @"
					query {
						users(first: 5000) {
							totalCount,
							pageInfo {
								endCursor,
								hasNextPage
							},
							nodes {
								id,
								firstName,
								lastName,
								email,
								isOnAccount,
								startedOn,
								createdOn,
								removedOn,
								lastLogin
							}
						}
					}"
			};

			// Attempt to fetch the query from Pluralsight's GraphQL API
			try
			{
				response = await graphQLClient.SendQueryAsync<Data>(query);
				// Clear loading icon here
				Loading.Visibility = Visibility.Hidden;
				Loading.Stop();
				// Bind the query data to the ui
				UserList.ItemsSource = response.Data.users.nodes;

				// Addtional processing for UI related fields
				foreach(User u in response.Data.users.nodes)
				{
					if(!u.isOnAccount)
					{
						u.icon = "user-inactive.png";
					}
					else if (u.email.EndsWith("@upskilled.edu.au"))
					{
						u.icon = "user-staff.png";
					} else
					{
						u.icon = "user-active.png";
					}

					if (u.isOnAccount)
					{
						u.status = "Active";
					}
					else
					{
						u.status = "Inactive";
					}
				}
			}
			catch (Exception exc)
			{
				// Clear loading icon here
				Loading.Visibility = Visibility.Hidden;
				Loading.Stop();
				Console.Error.WriteLine(exc.Message);
			}
		}

		private void Loading_MediaEnded(object sender, RoutedEventArgs e)
		{
			Loading.Position = TimeSpan.FromMilliseconds(1);
			Loading.Play();
		}
		private void Loading_Loaded(object sender, RoutedEventArgs e)
		{
			Loading.Play();
		}
		private void UserList_SelectionChanged(object sender, SelectionChangedEventArgs e)
		{
			UserProfile.Visibility = Visibility.Visible;
			UserActions.Visibility = Visibility.Visible;
		}
		private void Breadcrumb_Back_Click(object sender, RoutedEventArgs e)
		{
			NavigationService.GoBack();
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
	}
}
