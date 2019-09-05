using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace AutoReporting.Hubs
{
	public class UpdateHub : Hub
	{
		public async Task RequestUpdate(string data)
		{
			//await Clients.All.SendAsync("ReceiveMessage", , data);
		}
	}
}