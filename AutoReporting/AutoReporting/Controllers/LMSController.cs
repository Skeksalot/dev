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
using Microsoft.Extensions.Primitives;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AutoReporting.Controllers
{
	public class LMSController : Controller
	{
		public const string MoodleSessNoLogin = "x0000000000000";
		public const string MoodleSessLoggedIn = "11111111111111";
		public const string MoodleHome = "https://lms.upskilled.edu.au/my/";
		public const string MoodleLogin = "https://lms.upskilled.edu.au/login/index.php";
		//public const string MoodleTestHome = "https://upskilledtest30.androgogic.com.au/my/";
		//public const string MoodleTestLogin = "https://upskilledtest30.androgogic.com.au/login/index.php";
		//public const string MoodleNewHome = "https://upskilled-sandbox.mrooms.net/";
		//public const string MoodleNewLogin = "https://upskilled-sandbox.mrooms.net/login/index.php";

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
				return RedirectToAction("Login");
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
				return RedirectToAction("Login");
			}
		}

		[HttpGet, HttpPost]
		public async Task<IActionResult> Login(LMSModel model, string username, string password)
		{
			if(HttpContext.Request.Method == HttpMethod.Get.Method)
			{
				// Get, check if already logged in
				if (HttpContext.Request.Cookies.ContainsKey("MoodleSession"))
				{
					// Logged in, redirect to management page
					ViewData["Title"] = "LMS Reporting";
					ViewData["Message"] = "Access to the LMS reports below.";
					return RedirectToAction("LMS_Reporting");
				}
				else
				{
					// Not logged in, display login form
					ViewData["Title"] = "Login via LMS";
					ViewData["Message"] = "Use your LMS login credentials to authenticate before accessing the LMS management tools.";
					return View(model);
				}
			}
			else
			{
				// Post, attempt login
				await LMS_Login(username, password); // *** Validation on inputs needs to be added - use equivalent to LMS rules
				if (HttpContext.Request.Cookies.ContainsKey("MoodleSession"))
				{
					// Login succeded
					ViewData["Title"] = "LMS Reporting";
					ViewData["Message"] = "Access to the LMS reports below.";
					return RedirectToAction("LMS_Reporting");
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
		public IActionResult LMS_Reporting(LMSModel model, string report)
		{
			// Check user athorisation to start
			if (HttpContext.Request.Cookies.ContainsKey("MoodleSession"))
			{
				// User is logged in, continue with request for report
				ViewData["Report"] = report;
				return View("LMS_Reporting", model);
			}
			else
			{
				// Not logged in, return to login page
				ViewData["Error"] = "You must be logged in via LMS to view this page. Please log in below.";
				return RedirectToAction("Login");
			}
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
			//httpClient.DefaultRequestHeaders.Add("Referer", HttpContext.Request.Host.Value + HttpContext.Request.Path.Value);
			httpClient.DefaultRequestHeaders.Add("Origin", MoodleLogin);
			StringValues ua;
			HttpContext.Request.Headers.TryGetValue("User-Agent", out ua);
			httpClient.DefaultRequestHeaders.Add("user-agent", ua.ToString());
			//httpClient.DefaultRequestHeaders.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36");
			//httpClient.DefaultRequestHeaders.Date = DateTime.Now;
			//httpClient.DefaultRequestHeaders.GetCookies().Clear();
			//httpClient.DefaultRequestHeaders.GetCookies().Add(new System.Net.Http.Headers.CookieHeaderValue("MoodleSession", "00000000000000"));

			StringBuilder url = new StringBuilder(MoodleLogin);
			//StringBuilder url = new StringBuilder("https://httpbin.org/post");
			string extract;

			// Setting up content for post message
			var content = new StringContent("username=" + username.Trim() + "&password=" + password.Trim(), Encoding.ASCII, "application/x-www-form-urlencoded");
			content.Headers.Remove("Content-Type");
			content.Headers.Add("Content-Type", "application/x-www-form-urlencoded");
			extract = await content.ReadAsStringAsync();

			// Executing request

			// Using HttpRequestMessage
			/*var request = new HttpRequestMessage(HttpMethod.Post, url.ToString());
			request.Headers.Add("Connection", "keep-alive");
			request.Headers.Add("Location", "localhost:44349/LMS");
			request.Headers.Add("Location", HttpContext.Request.Host.Value + HttpContext.Request.Path.Value);
			request.Content = content;
			var response = await httpClient.SendAsync(request);*/

			// Using HttpClient
			var initial = await httpClient.GetAsync(url.ToString());

			var response = await httpClient.PostAsync(url.ToString(), content);
			
			extract = extract + "<br>" + response.ToString() + "<br>" + await response.Content.ReadAsStringAsync();

			if (response.IsSuccessStatusCode)
			{
				// Request to LMS successful
				string redir = response.RequestMessage.RequestUri.ToString();

				IEnumerable<string> cook;
				//if(response.RequestMessage.Headers.TryGetValues("Cookie", out cook))
				//if(response.RequestMessage.Headers.TryGetValues("Cookies", out cook))
				if(response.RequestMessage.Headers.TryGetValues("cookie", out cook))
				//if(response.RequestMessage.Headers.TryGetValues("cookies", out cook))
				//if(response.Headers.TryGetValues("Cookie", out cook))
				{
					ViewData["LMS_Cookies"] = "From LMS Request: ";
					foreach (var i in cook)
					{
						ViewData["LMS_Cookies"] = ViewData["LMS_Cookies"] + i.ToString() + "<br>";
					}
				}
				
				ViewData["RedirectFrom"] = redir;
				ViewData["Response"] = extract;
				if (redir == MoodleHome)
				{
					// Hit the LMS home page, represents successful login
					//HttpContext.Response.Cookies.Delete("MoodleSession");
					HttpContext.Request.Cookies.Append(new KeyValuePair<string, string>("MoodleSession", MoodleSessLoggedIn));
					CookieOptions options = new CookieOptions();
					options.HttpOnly = true;
					options.SameSite = SameSiteMode.None;
					HttpContext.Response.Cookies.Append("MoodleSession", MoodleSessLoggedIn, options );
				}
				else
				{
					// Didn't make the home page, unsuccesful attempt
					HttpContext.Request.Cookies.Append(new KeyValuePair<string, string>("MoodleSession", MoodleSessNoLogin));
					CookieOptions options = new CookieOptions();
					options.HttpOnly = true;
					options.SameSite = SameSiteMode.None;
					HttpContext.Response.Cookies.Append("MoodleSession", MoodleSessNoLogin, options);
				}

			}
			else
			{
				// Request to LMS failed

			}
		}
	}
}
