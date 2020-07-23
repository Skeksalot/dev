using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace Reporting_Pluralsight
{
	/// <summary>
	/// Interaction logic for Course_Usage.xaml
	/// </summary>
	public partial class Pluralsight_Course_Usage : Page
	{
		public Pluralsight_Course_Usage()
		{
			InitializeComponent();
		}
		// Custom constructor to pass expense report data
		public Pluralsight_Course_Usage(object data) : this()
		{
			// Bind to expense report data.
			this.DataContext = data;
		}
	}
}
