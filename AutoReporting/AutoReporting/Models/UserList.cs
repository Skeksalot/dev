using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text;
using Newtonsoft.Json;

namespace AutoReporting.Models
{
	public class UserList<User>
	{
		[JsonProperty("data")]
		public List<User> data { get; set; }
		public enum SortMethod { Name, Date }

		public UserList() {}

		public int CompareByName()
		{
			return 0;
		}

		public int CompareByDate()
		{
			return 0;
		}

		public void SortList(SortMethod identifier)
		{
			switch (identifier)
			{
				case SortMethod.Date:
					//data.Sort(new Comparison<User>(CompareByDate));
					break;
				case SortMethod.Name:
					//data.Sort(gcnew Comparison < String ^> CompareByName);
					break;
				default:

					break;
			}
		}

		public string toString()
		{
			StringBuilder sb = new StringBuilder();
			foreach (User i in data) {
				sb.Append(i.ToString());
				sb.AppendLine();
			}
			return sb.ToString();
		}
	}
}
