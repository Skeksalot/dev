using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace AutoReporting.Models
{
    public class LMS_ReportsModel : PageModel
    {
		public string Trainer_names { get; set; } = "";
		public string Alert { get; set; }
		
    }
}