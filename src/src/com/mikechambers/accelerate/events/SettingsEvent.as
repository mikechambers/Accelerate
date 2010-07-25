package com.mikechambers.accelerate.events
{
	import com.mikechambers.accelerate.settings.Settings;
	
	import flash.events.Event;
	
	public class SettingsEvent extends Event
	{
		public static const UPDATED:String = "onChange";
		
		public var settings:Settings;
		
		public function SettingsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			var e:SettingsEvent = new SettingsEvent(this.type, this.bubbles, this.cancelable);
			e.settings = this.settings;
			
			return e;
		}
	}
}