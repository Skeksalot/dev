using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSharpProject_ASkek
{
	public enum OrderStatus { Yes, No, Err }
	class Stock
	{
		public string ItemCode { get; set; }
		public string Description { get; set; }
		public int Count { get; set; }
		public OrderStatus OnOrder { get; set; }
		public Stock( string iCode, string desc, int newCount, OrderStatus order ) {
			ItemCode = iCode;
			Description = desc;
			Count = newCount;
			OnOrder = order;
		}
		public string toString() {
			return ItemCode + " | " + Description + " | " + Count + " | " + OnOrder;
		}

		public static OrderStatus ToStatus( string str )
		{
			if( str.ToLower() == "yes")
			{
				return OrderStatus.Yes;
			}
			else if( str.ToLower() == "no")
			{
				return OrderStatus.No;
			}
			else
			{
				return OrderStatus.Err;
			}
		}
	}
}
