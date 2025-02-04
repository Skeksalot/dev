﻿using System;
using Android.App;
using Android.Widget;
using Android.OS;
using Android.Support.V7.App;

namespace WeatherApp.Android
{
    [Activity(Label = "@string/app_name", Theme = "@android:style/Theme.Material.Light", MainLauncher = true)]
    public class MainActivity : Activity
    {
        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);

            // Set our view from the "main" layout resource
            SetContentView(Resource.Layout.activity_main);

			Button button = FindViewById<Button>(Resource.Id.weatherBtn);

			button.Click += Button_Click;
		}

		private async void Button_Click(object sender, EventArgs e)
		{
			EditText cityEntry = FindViewById<EditText>(Resource.Id.cityEntry);

			if (!String.IsNullOrEmpty(cityEntry.Text))
			{
				Weather weather = await Core.GetWeather(cityEntry.Text);
				FindViewById<TextView>(Resource.Id.locationText).Text = weather.Title;
				FindViewById<TextView>(Resource.Id.tempText).Text = weather.Temperature;
				FindViewById<TextView>(Resource.Id.windText).Text = weather.Wind;
				FindViewById<TextView>(Resource.Id.visibilityText).Text = weather.Visibility;
				FindViewById<TextView>(Resource.Id.humidityText).Text = weather.Humidity;
				FindViewById<TextView>(Resource.Id.sunriseText).Text = weather.Sunrise;
				FindViewById<TextView>(Resource.Id.sunsetText).Text = weather.Sunset;
			}
		}
	}
}

