using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSharpProject_ASkek
{
	class Stock
	{
		private string ItemCode { get; set; }
		private string Description { get; set; }
		private int Count { get; set; }
		private string OnOrder { get; set; }
		public Stock( string iCode, string desc, int newCount, string order ) {
			ItemCode = iCode;
			Description = desc;
			Count = newCount;
			OnOrder = order;
		}
		public string toString() {
			return ItemCode + " | " + Description + " | " + Count + " | " + OnOrder;
		}
	}
}
