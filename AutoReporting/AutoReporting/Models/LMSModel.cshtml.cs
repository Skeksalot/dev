using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Net.Http;
using System.Text;
using System.Web;

namespace AutoReporting.Models
{
    public class LMSModel : PageModel
    {
		public string Trainer_names { get; set; }
		private HttpClient httpClient { get; set; }
		public string session { get; set; }
		public string token { get; set; }
		private string result { get; set; }
		public string extract { get; set; }

		public async Task Retrieve_Report(string moodle_session)
		{
			if (string.IsNullOrEmpty(moodle_session))
			{
				var request = new HttpRequestMessage(HttpMethod.Get, "https://lms.upskilled.edu.au/blocks/configurable_reports/viewreport.php?id=181&courseid=1");
				// For requests with a message body
				request.Headers.Add("Connection", "keep-alive");
				// Should add a method for dynamically generating/finding this session ID
				StringBuilder sb = new StringBuilder("MoodleSession=");
				sb.Append(moodle_session);
				sb.Append(";");
				request.Headers.Add("Cookie", sb.ToString());

				httpClient = new HttpClient();

				var response = await httpClient.SendAsync(request);

				if (response.IsSuccessStatusCode)
				{
					//result = "\nReceived:\n";
					result = result + await response.Content.ReadAsStringAsync();

					// Process results to pull out data entries only
					extract = result.Substring(result.IndexOf("<table"), result.IndexOf("</table") - result.IndexOf("<table") + 8);
					
				}
				else
				{
					//result = "\nRequest Failed:\n";
					result = result + await response.Content.ReadAsStringAsync();
				}
			}
			else
			{
				// Not logged in

			}
		}

		public async Task Generate_Token(string username, string password, string service = "webserviceaccess")
		{
			StringBuilder sb = new StringBuilder("https://lms.upskilled.edu.au/login/token.php?username=");
			sb.Append(HttpUtility.UrlEncode(username));
			sb.Append("&password=");
			sb.Append(HttpUtility.UrlEncode(password));
			sb.Append("&service=");
			sb.Append(HttpUtility.UrlEncode(service));
			var request = new HttpRequestMessage(HttpMethod.Get, sb.ToString());

			httpClient = new HttpClient();

			var response = await httpClient.SendAsync(request);

			if (response.IsSuccessStatusCode)
			{
				// Success
				try
				{
					token = await response.Content.ReadAsStringAsync();
					token = token.Split(':')[1];
					token = token.Substring(1, token.Length - 3);
					//token = response.Headers.GetValues("token").First();
				}
				catch (Exception e)
				{
					Console.WriteLine(e.ToString());
				}
			}
			else
			{
				// Failure
			}
		}
	}
}