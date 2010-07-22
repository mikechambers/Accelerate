package com.mikechambers.accelerate.events
{
	import flash.events.Event;
	
	public class AccelerateEvent extends Event
	{
		public static const RESET:String = "onReset";
		
		public function AccelerateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			var e:AccelerateEvent = new AccelerateEvent(this.type, this.bubbles, this.cancelable);
			return e;
		}
	}
}