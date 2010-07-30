package com.mikechambers.accelerate.events
{
	import flash.events.DataEvent;
		
	public class AccelerateDataEvent extends DataEvent
	{
		public static const LIGHT_SENSOR_UPDATE:String = "onLightSensorUpdate";
		public static const LIGHT_SENSOR_TRIP:String = "onLightSensorTrip";
		public static const TOTAL_TIME:String = "onTotalTime";
		
		
		public var sensor:String;
		public var value:Number;
		
		//in milliseconds
		public var totalElapsedTime:Number;		
		
		public function AccelerateDataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:String="")
		{
			super(type, bubbles, cancelable, data);
		}
	}
}