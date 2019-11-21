using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using AutoReporting.Models;
using System.Net.Http;
using System.Text;
using System.Web;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AutoReporting.Controllers
{
	[Route("LMS")]
	public class LMSController : Controller
	{
		[HttpGet]
		public async Task<IActionResult> LMS_Reporting(LMSModel model)
		{
			if (HttpContext.Request.Cookies.ContainsKey("MoodleSession"))
			{
				// Make request for report from LMS
				//await model.Retrieve_Report(HttpContext.Session.GetString("MoodleSession"));

			}
			else
			{
				// Not logged in via LMS

			}

			ViewData["Title"] = "LMS Reporting";
			ViewData["Message"] = "Access to the LMS reports below.";
			//ViewData["Trainer-List"] = null;
			return View(model);
		}

		[HttpPost]
		public async Task<IActionResult> LMS_Reporting(LMSModel model, string username, string password)
		{
			// Validate login details (use equivalents for LMS)
			if (!string.IsNullOrEmpty(username.Trim()) && !string.IsNullOrEmpty(password.Trim()))
			{
				HttpContext.Request.Cookies.Append(new KeyValuePair<string, string>("MoodleSession", "11111111111111"));
				await LMS_Login(username.Trim(), password.Trim());
				if (HttpContext.Request.Cookies.ContainsKey("MoodleSession"))
				{
					ViewData["Title"] = "LMS Reporting";
					ViewData["Message"] = "Access to the LMS reports below.";
					return View("LMS_Reporting", model);
				}
			}

			//return RedirectToAction("LMS_Reporting", model);
			return RedirectToAction("LMS_Reporting");
		}

		[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
		public IActionResult Error()
		{
			return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
		}

		/* ****** Beginning of functionality, separate from pages ****** */

		public async Task LMS_Login(string username, string password)
		{
			HttpClient httpClient = new HttpClient();
			StringBuilder url = new StringBuilder("https://lms.upskilled.edu.au/login/index.php");
			//StringBuilder url = new StringBuilder("https://httpbin.org/post");
			string extract;

			// Setting up content for post message
			var content = new StringContent("username=" + username + "&password=" + password, Encoding.ASCII, "application/x-www-form-urlencoded");
			content.Headers.Remove("Content-Type");
			content.Headers.Add("Content-Type", "application/x-www-form-urlencoded");

			// Setting up request using HttpRequestMessage
			var request = new HttpRequestMessage(HttpMethod.Post, url.ToString());
			//request.Headers.Add("username", HttpUtility.UrlEncode(username));
			//request.Headers.Add("password", HttpUtility.UrlEncode(password));
			request.Headers.Add("Connection", "keep-alive");
			request.Headers.Add("Location", "localhost:44349/LMS");
			//request.Headers.Add("Location", HttpContext.Request.Host + HttpContext.Request.Path);
			request.Content = content;
			
			// Executing request
			extract = await content.ReadAsStringAsync();
			var response = httpClient.PostAsync(url.ToString(), content).Result;
			//var response = await httpClient.SendAsync(request);
			extract = extract + "<br>" + response.ToString() + "<br>" + await response.Content.ReadAsStringAsync();

			if (response.IsSuccessStatusCode)
			{
				// Success
				string session = "";
				try
				{
					// Test for successful login
					
					/*if()
					{
						// Set MoodleSession if login success
						string newStr = response.Headers.GetValues("Set-Cookie").First();
						int pos = newStr.IndexOf("MoodleSession=") + 14;
						int pos2 = newStr.IndexOf(";", pos);
						session = newStr.Substring(pos, pos2 - pos);
					}*/
					session = response.Headers.GetValues("Set-Cookie").First();
					int pos = session.IndexOf("MoodleSession=") + 14;
					int pos2 = session.IndexOf(";", pos);
					//session = session.Substring(pos, pos2 - pos);
				}
				catch (Exception e)
				{
					Console.WriteLine(e.ToString());
				}

				// For testing
				session = "x0000000000000";
				ViewData["BeforeRedirect"] = response.RequestMessage.Headers.Host + " : " + response.RequestMessage.Headers.From + " : " + response.RequestMessage.Headers.Referrer + " : " + response.RequestMessage.Headers.Via + " : " + response.RequestMessage.Headers.GetCookies().ToArray().ToString();

				// Set relevant fields
				ViewData["Response"] = extract;
				//HttpContext.Session.SetString("MoodleSession", session);
				HttpContext.Response.Cookies.Append("MoodleSession", session);
				/*HttpContext.Request.Cookies.Append(new KeyValuePair<string, string>("MoodleSession", session));
				if (response.Headers.Contains("cookie"))
				{
					foreach (var i in response.Headers.GetValues("cookie"))
					{
						HttpContext.Response.Cookies.Append("cookie", i);
					}
				}*/
				
			}
			else
			{
				// Failure

			}
		}
	}
}
