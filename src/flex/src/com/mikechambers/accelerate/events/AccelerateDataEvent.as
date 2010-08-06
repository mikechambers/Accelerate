package com.mikechambers.accelerate.events
{
	import com.mikechambers.accelerate.data.Result;
	
	import flash.events.DataEvent;
		
	public class AccelerateDataEvent extends DataEvent
	{
		public static const LIGHT_SENSOR_UPDATE:String = "onLightSensorUpdate";
		public static const LIGHT_SENSOR_TRIP:String = "onLightSensorTrip";
		public static const TOTAL_TIME:String = "onTotalTime";
		public static const ARDUINO_ATTACH:String = "onArduinoAttach";
		public static const ARDUINO_DETACH:String = "onArduinoDetach";
		public static const RESULT:String = "onResult";
		
		public var sensor:String;
		public var value:Number;
		public var result:Result;
		
		//in milliseconds
		public var totalElapsedTime:Number;		
		
		public function AccelerateDataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:String="")
		{
			super(type, bubbles, cancelable, data);
		}
	}
}