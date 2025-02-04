﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using RazorWebApp.Models;

namespace RazorWebApp.Pages.Movies
{
    public class IndexModel : PageModel
    {
        private readonly RazorWebApp.Models.RazorWebAppContext _context;

        public IndexModel(RazorWebApp.Models.RazorWebAppContext context)
        {
            _context = context;
        }

        public IList<Movie> Movie { get;set; }

        public async Task OnGetAsync()
        {
            Movie = await _context.Movie.ToListAsync();
        }
    }
}
