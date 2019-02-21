using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSharpProject_ASkek
{
	class Stock
	{
		private string itemCode { get; set; }
		private string description { get; set; }
		private int count { get; set; }
		private bool onOrder { get; set; }
		public Stock( string iCode, string desc, int newCount, bool order ) {
			itemCode = iCode;
			description = desc;
			count = newCount;
			onOrder = order;
		}
	}
}
