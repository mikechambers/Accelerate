import mx.core.BitmapAsset;

public static const RED:String = "red";
public static const GREEN:String = "green";

[Embed(source="assets/images/red_led.png")]
[Bindable]
private var redLED:Class;

[Embed(source="assets/images/green_led.png")]
[Bindable]
private var greenLED:Class;

//private var _redLEDBitmap:BitmapAsset;
//private var _greenLEDBitmap:BitmapAsset

private var _ledColor:String;

private function onCreationComplete():void
{
	//_redLEDBitmap = new redLED() as BitmapAsset;
	//_greenLEDBitmap = new greenLED() as BitmapAsset;
	
	ledColor = RED;
}

public function set ledColor(value:String):void
{
	if(value == _ledColor)
	{
		return;
	}
		
	_ledColor = value;
	var led:BitmapAsset;
	
	switch(_ledColor)
	{
		case RED:
		{
			led = new redLED() as BitmapAsset;
			break;
		}
		case GREEN:
		{
			//for some reason, cant reuse the same BitmapAsset instance
			//it seems it is not reased or removed correctly from the 
			//image control
			led = new greenLED() as BitmapAsset;
			break;
		}
		default:
		{
			throw new Error("LED Color not recognized : " + value);
			return;
		}
	}
	
	ledImage.source = null;
	ledImage.source = led;	
	
}

public function get ledColor():String
{
	return _ledColor;
}
