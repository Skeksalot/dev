using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace API_Reporting
{
	// All required definitions for objects in the Pluralsight GraphQL API.
	// https://dev-portal.pluralsight.com/schema-docs/query.doc.html
	// https://github.com/graphql-dotnet/graphql-client
	public class Data
	{
		public Users users { get; set; }
	}
	public class Users
	{
		public int totalCount { get; set; }
		public List<UserEdge> edges { get; set; }
		public List<User> nodes { get; set; }
		public PageInfo pageInfo { get; set; }
	}

	public class CourseConnection
	{
		public int totalCount { get; set; }
		public List<CourseEdge> edges { get; set; }
		public List<Course> nodes { get; set; }
		public string pageInfo { get; set; }
	}
	public class CourseEdge
	{
		public string cursor { get; set; }
		public Course node { get; set; }
	}
	public class PageInfo
	{
		public string endCursor { get; set; }
		public bool hasNextPage { get; set; }
	}
	public class Team
	{
		public string id { get; set; }
		public string name { get; set; }
		public string planId { get; set; }
		public string description { get; set; }
	}
	public class UserEdge
	{
		public string cursor { get; set; }
		public User node { get; set; }
	}
	public class TeamUserConnection
	{

	}
	public class User
	{
		public string id { get; set; }
		public string email { get; set; }
		public List<string> additionalEmails { get; set; }
		public string firstName { get; set; }
		public string lastName { get; set; }
		public DateTime startedOn { get; set; }
		public DateTime createdOn { get; set; }
		public string note { get; set; }
		public Team team { get; set; }
		public TeamUserConnection teams { get; set; }
		public bool isOnAccount { get; set; }
		public DateTime? removedOn { get; set; }
		public DateTime lastLogin { get; set; }
		public List<string> ssoIdentifiers { get; set; }
		public string currentSsoIdentifier { get; set; }
		public bool ssoEnabled { get; set; }
		public string planId { get; set; }
		// Custom fields for UI
		public string icon { get; set; }
		public string status { get; set; }
	}
	public class Image
	{
		public string alt { get; set; }
		public string url { get; set; }
		public bool isDefault { get; set; }
	}
	public class Status
	{
		public string name { get; set; }
		public string reason { get; set; }
		public string replacementCourseId { get; set; }
	}
	public class PrimaryAtomic
	{
		public string name { get; set; }
		public List<string> alternativeNames { get; set; }
	}
	public class Tags
	{
		public List<string> tools { get; set; }
		public List<string> topics { get; set; }
		public List<string> audiences { get; set; }
		public List<string> certifications { get; set; }
		public List<string> primaryAtomicTags { get; set; }
		public string superDomain { get; set; }
		public string domain { get; set; }
		public PrimaryAtomic primaryAtomic { get; set; }
		public string audience { get; set; }
	}
	public class Course
	{
		public string id { get; set; }
		public int idNum { get; set; }
		public string slug { get; set; }
		public string url { get; set; }
		public Image image { get; set; }
		public Status courseStatus { get; set; }
		public string title { get; set; }
		public string level { get; set; }
		public string description { get; set; }
		public string shortDescription { get; set; }
		public float courseSeconds { get; set; }
		public Tags tags { get; set; }
		public List<string> authors { get; set; }
		public bool free { get; set; }
		public DateTime releasedDate { get; set; }
		public DateTime displayDate { get; set; }
		public DateTime publishedDate { get; set; }
		public float averageRating { get; set; }
		public int numberOfRatings { get; set; }
	}
	public class CourseProgress
	{
		public string userId { get; set; }
		public User user { get; set; }
		public string courseId { get; set; }
		public Course course { get; set; }
		public int courseIdNum { get; set; }
		public float percentComplete { get; set; }
		public bool isCourseCompleted { get; set; }
		public DateTime completedOn { get; set; }
		public int courseSeconds { get; set; }
		public int totalWatchedSeconds { get; set; }
		public int totalClipsWatched { get; set; }
		public DateTime firstViewedClipOn { get; set; }
		public DateTime lastViewedClipOn { get; set; }
		public string planId { get; set; }
		public DateTime updatedOn { get; set; }
	}
}
