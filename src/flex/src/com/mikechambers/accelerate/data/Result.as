package com.mikechambers.accelerate.data
{
	[RemoteClass(alias="com.mikechambers.accelerate.data.Result")]	
	public class Result
	{
		//speed in MPH
		public var speed:Number;
		
		//time in milliseconds
		public var rawTime:Number;
		
		//distance that sensors were apart
		public var distance:Number;
		
		public var date:Date;
		
		public function Result()
		{
		}
	}
}