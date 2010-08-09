package com.mikechambers.accelerate.logging
{
	import mx.logging.targets.LineFormattedTarget;
	import spark.components.TextArea;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class TextAreaTarget extends LineFormattedTarget
	{
		private var textArea:TextArea;
		
		public function TextAreaTarget(textArea:TextArea)
		{
			this.textArea = textArea;
		}
		
		mx_internal override function internalLog(message:String):void
		{
			write(message);
		}		
		
		private function write(msg:String):void
		{		
			if(textArea == null)
			{
				return;
			}
			
			textArea.text = msg + "\n" + textArea.text;
		}			
		
		public function clear():void
		{
			if(textArea == null)
			{
				return;
			}
			
			textArea.text = "";	
		}
		
	}
}