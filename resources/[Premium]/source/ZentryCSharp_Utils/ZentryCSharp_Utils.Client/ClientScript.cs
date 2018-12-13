using System;
using System.Threading.Tasks;
using static CitizenFX.Core.Native.API;
using CitizenFX.Core;
using ZentryCSharp_Utils.Client.Manager;

namespace ZentryCSharp_Utils.Client
{
	public class ClientScript : BaseScript
	{
		
		public ClientScript() {
			var session = new Session(LocalPlayer);
			Tick += OnTick;
		}
		
		public async Task OnTick()
		{
			await Delay(10);
		}

	}
}
