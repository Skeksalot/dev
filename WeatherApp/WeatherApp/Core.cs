using System;
using System.Threading.Tasks;

namespace WeatherApp
{
	public class Core
	{
		public static async Task<Weather> GetWeather(string city)
		{
			//Sign up for a free API key at http://openweathermap.org/appid
			string key = "f43ac9da3e8483cd16c5343a57ad2655";
			string queryString = "http://api.openweathermap.org/data/2.5/weather?q="
				+ city + ",au&appid=" + key + "&units=metric";

			//Make sure developers running this sample replaced the API key
			if (key == "YOUR API KEY HERE")
			{
				throw new ArgumentException("You must obtain an API key from openweathermap.org/appid and save it in the 'key' variable.");
			}

			dynamic results = await DataService.GetDataFromService(queryString).ConfigureAwait(false);

			if (results["weather"] != null)
			{
				Weather weather = new Weather();
				weather.Title = (string)results["name"];
				weather.Temperature = (string)results["main"]["temp"] + " C";
				weather.Wind = (string)results["wind"]["speed"] + " kph";
				weather.Humidity = (string)results["main"]["humidity"] + " %";
				weather.Visibility = (string)results["weather"][0]["main"];

				DateTime time = new System.DateTime(1970, 1, 1, 0, 0, 0, 0);
				DateTime sunrise = time.AddSeconds((double)results["sys"]["sunrise"]);
				DateTime sunset = time.AddSeconds((double)results["sys"]["sunset"]);
				weather.Sunrise = sunrise.ToString() + " UTC";
				weather.Sunset = sunset.ToString() + " UTC";
				return weather;
			}
			else
			{
				return null;
			}
		}
	}
}