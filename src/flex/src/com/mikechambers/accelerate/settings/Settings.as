package com.mikechambers.accelerate.settings
{
	[RemoteClass(alias="com.mikechambers.accelerate.settings.Settings")]	
	public class Settings
	{
		
		public var serverAddress:String = "127.0.0.1";
		public var serverPort:uint = 3551;
		public var lightSensorTripThreshold:uint = 75;
		public var lightSensorChangeThreshold:uint = 100;
		public var lightSensorDistance:Number = 12; //specified in inches
		public var logData:Boolean = false;
		
		public function Settings()
		{
		}
	}
}