using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using AutoReporting.Models;

namespace AutoReporting.Controllers
{
	[Route("Linkedin")]
    public class LinkedinController : Controller
    {
		[HttpGet]
		public IActionResult Linkedin()
		{

			ViewData["Message"] = "LinkedIn Learning User Management. Uses their API to manage users.";

			return View();
		}

		[HttpPost]
		public async Task<IActionResult> Linkedin(LinkedinModel model)
		{

			ViewData["Message"] = "LinkedIn Learning User Management. Uses their API to manage users. (Post)";
			/*await model.OnGet();
			//ViewData["Response"] = model.users.data.Count + "\r\n" + model.users.data[0].toString() + "\r\n" + model.result;
			ViewData["Response"] = model.users.toString();
			ViewData["UserList"] = model.users.data;
			ViewData["Update"] = DateTime.Now;
			model.users.data.Sort();*/
			return View();
		}

		[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
		public IActionResult Error()
		{
			return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
		}
	}
}