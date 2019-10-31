using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AutoReporting.Controllers
{
	[Route("LMS")]
	public class LMSController : Controller
	{
		// GET: /<controller>/
		public IActionResult Index()
		{
			return View();
		}

		public IActionResult LMS_Reports()
		{

			ViewData["Message"] = "Access to the LMS reports below.";
			ViewData["Trainer-List"] = null;
			return View();
		}
	}
}
