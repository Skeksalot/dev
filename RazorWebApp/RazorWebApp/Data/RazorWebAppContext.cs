using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace RazorWebApp.Models
{
    public class RazorWebAppContext : DbContext
    {
        public RazorWebAppContext (DbContextOptions<RazorWebAppContext> options)
            : base(options)
        {
        }

        public DbSet<RazorWebApp.Models.Movie> Movie { get; set; }
    }
}
