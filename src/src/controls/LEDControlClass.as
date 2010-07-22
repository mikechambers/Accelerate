import mx.core.BitmapAsset;

public static const RED:String = "red";
public static const GREEN:String = "green";

[Embed(source="assets/images/red_led.png")]
[Bindable]
private var redLED:Class;

[Embed(source="assets/images/green_led.png")]
[Bindable]
private var greenLED:Class;

private var _redLEDBitmap:BitmapAsset;
private var _greenLEDBitmap:BitmapAsset

private var _ledColor:String;

private function onCreationComplete():void
{
	_redLEDBitmap = new redLED() as BitmapAsset;
	_greenLEDBitmap = new redLED() as BitmapAsset;
	
	greenLED = null;
	redLED = null;
	
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
			led = _redLEDBitmap;
			break;
		}
		case GREEN:
		{
			led = _greenLEDBitmap;
			break;
		}
		default:
		{
			trace("error");
			throw new Error("LED Color not recognized : " + value);
			return;
		}
	}
	
	ledImage.source = led;	
	
}

public function get ledColor():String
{
	return _ledColor;
}
