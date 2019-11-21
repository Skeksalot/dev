using System;
using System.IO;
using System.Net;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Net.Http;
using Newtonsoft.Json;

namespace AutoReporting.Models
{
    public class PluralsightModel : PageModel
    {
		private HttpClient httpClient { get; set; } 
		public string result { get; set; }
		public UserList<PluralsightUser> users { get; set; }
		private readonly IHttpClientFactory clientFactory;

		public PluralsightModel()
		{
			users = new UserList<PluralsightUser>();
		}

		public PluralsightModel(IHttpClientFactory httpClientFactory)
		{
			clientFactory = httpClientFactory;
			users = new UserList<PluralsightUser>();
		}

		public async Task OnGet()
		{
			var request = new HttpRequestMessage(HttpMethod.Get, "https://app.pluralsight.com/plans/api/license/v1/upskilled/users");
			request.Headers.Add("Authorization", "Token 9c8cdda3-f9cb-4bf0-b243-029b590d2af5");
			request.Headers.Add("Accept", "application/json");
			// For requests with a message body
			//request.Headers.Add("Content-Type", "application/json");

			try
			{
				httpClient = clientFactory.CreateClient();
			} catch(Exception e)
			{
				//result = e.Message;
				httpClient = new HttpClient();
			}

			var response = await httpClient.SendAsync(request);

			if(response.IsSuccessStatusCode)
			{
				//result = "\nReceived:\n";
				result = result + await response.Content.ReadAsStringAsync();

				// Process returned JSON data
				users = JsonConvert.DeserializeObject<UserList<PluralsightUser>>(result);
			}
			else
			{
				//result = "\nRequest Failed:\n";
				result = result + await response.Content.ReadAsStringAsync();
			}
		}

	}

}