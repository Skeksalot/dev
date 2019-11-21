using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using AutoReporting.Models;

namespace AutoReporting.Controllers
{
	public class HomeController : Controller
	{
		public IActionResult Index()
		{
			return View();
		}
		/*
		public IActionResult About()
		{
			ViewData["Message"] = "This web application is designed to provide easy external access to the LMS reporting functions, and to enable automating the use of regular reports.";

			return View();
		}

		public IActionResult Contact()
		{
			ViewData["Message"] = "Company Contact Details.";

			return View();
		}
		*/
		public IActionResult Privacy()
		{
			return View();
		}

		[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
		public IActionResult Error()
		{
			return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
		}
	}
}
