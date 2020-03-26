using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using AutoReporting.Models;

namespace AutoReporting.Controllers
{
    public class PluralsightController : Controller
    {
		/*
		 	Pluralsight API references:
			https://app.pluralsight.com/plans/api/license/docs?planId=upskilled
			License Management API token: 9c8cdda3-f9cb-4bf0-b243-029b590d2af5
			- Could be used for removing 'expired' students from Pluralsight

			https://app.pluralsight.com/plans/api/reports/docs
			Reports API token: 2f08d268-305f-467b-bf67-78f7af1ce36c
			- Gives complete data set of detailed user logs

			For auto-deleting users, might need to manually pull the id's for students to be culled, and then put them into the site to handle from there.
				* Alternative: Download the full list of users using analytics API, match student id's and then check the last access from there

			To download the full list, send GET to: https://app.pluralsight.com/plan-analytics-api/reports/upskilled/user/all/download?range=all.
				* Must be logged in to Pluralsight first 
		 */
		[HttpGet]
		public IActionResult Pluralsight()
		{

			ViewData["Message"] = "Pluralsight User Management. Uses the Pluralsight License Management API to manage users.";

			return View();
		}

		[HttpPost]
		public async Task<IActionResult> Pluralsight(PluralsightModel model)
		{

			ViewData["Message"] = "Pluralsight User Management. Uses the Pluralsight License Management API to manage users. (Post)";
			await model.OnGet();
			ViewData["Response"] = model.users.ToString();
			ViewData["UserList"] = model.users.data;
			ViewData["Update"] = DateTime.Now;
			model.users.data.Sort();
			return View();
		}

		[HttpGet]
		public IActionResult User_Management(PluralsightModel model)
		{
			return RedirectToAction("Pluralsight", model);
		}

		[HttpGet]
		public IActionResult License_Management(PluralsightModel model)
		{
			return RedirectToAction("Pluralsight", model);
		}

		[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
		public IActionResult Error()
		{
			return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
		}
	}
}