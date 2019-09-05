using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Net.Http;

namespace AutoReporting.Models
{
    public class Pluralsight_ManagerModel : PageModel
    {
		private HttpClient client { get; set; }
		public string result { get; set; } = "";
		private string auth { get; set; } = "";
		public Pluralsight_ManagerModel()
		{
			client = new HttpClient();
			client.BaseAddress = new Uri("https://app.pluralsight.com");
			client.DefaultRequestHeaders.Add("Accept", "application/json");
			// Do something with this auth token
			//client.DefaultRequestHeaders.Add("Authorization", auth);
		}
		public async void GetUsersAsync()
		{
			
			try
			{
				var response = await client.GetAsync("https://app.pluralsight.com/plan-analytics-api/reports/upskilled/user/all/download?range=all");
				response.EnsureSuccessStatusCode();

				result = await response.Content.ReadAsStringAsync();

			} catch (HttpRequestException e)
			{
				result = e.Message;
				
			}
			
		}

	}

}