using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AutoReporting.Models
{
	public class PluralsightUser : User, IComparable<PluralsightUser>
	{
		[JsonProperty("id")]
		public string id { get; set; }
		[JsonProperty("teamId")]
		public string teamId { get; set; }
		[JsonProperty("firstName")]
		public string firstName { get; set; }
		[JsonProperty("lastName")]
		public string lastName { get; set; }
		[JsonProperty("email")]
		public string email { get; set; }
		[JsonProperty("note")]
		public string note { get; set; }
		[JsonProperty("startDate")]
		public DateTime startDate { get; set; }

		public PluralsightUser() {}

		public int compareDate(PluralsightUser u)
		{
			if (u.startDate == null)
			{
				return 1;
			}
			else if (startDate == null)
			{
				return -1;
			}
			else
			{
				return startDate.CompareTo(u.startDate); // Add proper logic for comparison
			}
		}

		public int CompareTo(PluralsightUser other)
		{
			// Defines default sort method. Sorts by name
			if (other == null)
			{
				return 1;
			}
			else if (lastName == null || firstName == null)
			{
				return -1;
			}
			else
			{
				// Sort by surname first
				return (lastName + firstName).CompareTo(other.lastName + other.firstName);
			}
		}

		public override string ToString()
		{
			return string.Format("{0} {1}, {2}, {3}, {4}, {5}, {6}", firstName, lastName, id, email, teamId, note, startDate);
		}
	}
}
