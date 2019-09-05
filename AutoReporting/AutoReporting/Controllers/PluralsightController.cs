using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using AutoReporting.Models;

namespace AutoReporting.Controllers
{
	[Route("Pluralsight")]
    public class PluralsightController : Controller
    {
		[HttpGet]
		public IActionResult Pluralsight_Manager()
		{

			ViewData["Message"] = "Pluralsight User Management. Uses the Pluralsight License Management API to manage users.";

			return View();
		}

		[HttpPost]
		public IActionResult Pluralsight_Manager(Pluralsight_ManagerModel model)
		{

			ViewData["Message"] = "Pluralsight User Management. Uses the Pluralsight License Management API to manage users.";
			model.GetUsersAsync();
			ViewData["Response"] = model.result;
			return View();
		}

		[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
		public IActionResult Error()
		{
			return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
		}
	}
}