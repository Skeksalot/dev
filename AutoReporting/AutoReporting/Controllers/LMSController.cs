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
	public class LMSController : Controller
	{
		[HttpGet]
		public IActionResult Index(LMSModel model)
		{
			// Double check authorisation
			if (HttpContext.Request.Cookies.ContainsKey("MoodleSession"))
			{
				// User is already authorised, display page
				ViewData["Title"] = "LMS Reporting";
				ViewData["Message"] = "Access to the LMS reports below.";
				return View(model);
			}
			else
			{
				// Not logged in via LMS, send on to login
				ViewData["Error"] = "You must be logged in via LMS to view this page. Please log in below.";
				return View("Login", model);
			}
		}

		[HttpGet]
		public IActionResult LMS_Reporting(LMSModel model)
		{
			// Double check authorisation
			if (HttpContext.Request.Cookies.ContainsKey("MoodleSession"))
			{
				// User is authorised
				ViewData["Title"] = "LMS Reporting";
				ViewData["Message"] = "Access to the LMS reports below.";
				return View(model);
			}
			else
			{
				// Not logged in via LMS, send back to login
				
				ViewData["Error"] = "You must be logged in via LMS to view this page. Please log in below.";
				return View("Login", model);
			}
		}

		[HttpGet, HttpPost]
		public async Task<IActionResult> Login(LMSModel model, string username, string password)
		{
			if(HttpContext.Request.Method == HttpMethod.Get.Method)
			{
				// Get, display login form
				ViewData["Title"] = "Login via LMS";
				ViewData["Message"] = "Use your LMS login credentials to authenticate before accessing the LMS management tools.";
				return View(model);
			}
			else
			{
				// Post, attempt login
				await LMS_Login(username.Trim(), password.Trim());
				if (HttpContext.Request.Cookies.ContainsKey("MoodleSession"))
				{
					// Login succeded
					ViewData["Title"] = "LMS Reporting";
					ViewData["Message"] = "Access to the LMS reports below.";
					return View("LMS_Reporting");
				}
				else
				{
					// Login failed
					ViewData["Title"] = "Login via LMS";
					ViewData["Error"] = "Login with LMS failed. Check your details and retry.";
					return View(model);
				}
				
			}
		}

		[HttpPost]
		public async Task<IActionResult> LMS_Reporting(LMSModel model, string username, string password)
		{
			// Validate login details (use equivalents for LMS)
			if (!string.IsNullOrEmpty(username.Trim()) && !string.IsNullOrEmpty(password.Trim()))
			{
				//HttpContext.Request.Cookies.Append(new KeyValuePair<string, string>("MoodleSession", "11111111111111"));
				await LMS_Login(username.Trim(), password.Trim());
				if (HttpContext.Request.Cookies.ContainsKey("MoodleSession"))
				{
					ViewData["Title"] = "LMS Reporting";
					ViewData["Message"] = "Access to the LMS reports below.";
					return View("LMS_Reporting", model);
				}
			}

			//return RedirectToAction("LMS_Reporting", model);
			return View("LMS_Reporting", model);
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
			httpClient.DefaultRequestHeaders.Add("Connection", "keep-alive");
			httpClient.DefaultRequestHeaders.Add("Location", HttpContext.Request.Host.Value + HttpContext.Request.Path.Value);
			/*httpClient.DefaultRequestHeaders.Add("Referer", HttpContext.Request.Host.Value + HttpContext.Request.Path.Value);
			httpClient.DefaultRequestHeaders.Add("Origin", HttpContext.Request.Host.Value);
			httpClient.DefaultRequestHeaders.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36");
			httpClient.DefaultRequestHeaders.Date = DateTime.Now;
			httpClient.DefaultRequestHeaders.GetCookies().Clear();
			httpClient.DefaultRequestHeaders.GetCookies().Add(new System.Net.Http.Headers.CookieHeaderValue("MoodleSession", "00000000000000"));*/

			StringBuilder url = new StringBuilder("https://lms.upskilled.edu.au/login/index.php");
			//StringBuilder url = new StringBuilder("https://httpbin.org/post");
			string extract;

			// Setting up content for post message
			var content = new StringContent("username=" + username + "&password=" + password, Encoding.ASCII, "application/x-www-form-urlencoded");
			content.Headers.Remove("Content-Type");
			content.Headers.Add("Content-Type", "application/x-www-form-urlencoded");

			// Setting up request using HttpRequestMessage
			var request = new HttpRequestMessage(HttpMethod.Post, url.ToString());
			//request.Headers.Add("Connection", "keep-alive");
			//request.Headers.Add("Location", "localhost:44349/LMS");
			//request.Headers.Add("Location", HttpContext.Request.Host.Value + HttpContext.Request.Path.Value);
			request.Content = content;
			
			// Executing request
			extract = await content.ReadAsStringAsync();
			var response = httpClient.PostAsync(url.ToString(), content).Result;
			//var response = await httpClient.SendAsync(request);
			extract = extract + "<br>" + response.ToString() + "<br>" + await response.Content.ReadAsStringAsync();

			if (response.IsSuccessStatusCode)
			{
				// Success
				string session;
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
				ViewData["BeforeRedirect"] = response.RequestMessage.Headers.Host + " : " + response.RequestMessage.Headers.GetValues("Location") + " : " + response.RequestMessage.Headers.From + " : " + response.RequestMessage.Headers.Referrer + " : " + response.RequestMessage.Headers.Via + " : " + response.RequestMessage.RequestUri.ToString();

				// Set relevant fields
				ViewData["Response"] = extract;
				//HttpContext.Session.SetString("MoodleSession", LMSModel.MooSessTestVal);
				HttpContext.Response.Cookies.Delete("MoodleSession");
				HttpContext.Response.Cookies.Append("MoodleSession", LMSModel.MooSessTestVal);
				/*HttpContext.Request.Cookies.Append(new KeyValuePair<string, string>("MoodleSession", LMSModel.MooSessTestVal));
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
