package com.mikechambers.accelerate.events
{
	import flash.events.Event;
	
	public class ViewEvent extends Event
	{
		public static const MAIN_VIEW_REQUEST:String = "onMainViewRequest";
		public static const DATA_VIEW_REQUEST:String = "onDataViewRequest";
		
		public function ViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			var e:ViewEvent = new ViewEvent(this.type, this.bubbles, this.cancelable);
			return e;
		}
		
	}
}