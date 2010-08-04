
import controls.LEDControl;

public static const DISCONNECTED:String = "Disconnected";
public static const CONNECTED:String = "Connected";
public static const ACTIVE:String = "Active";
public static const TRIPPED:String = "Tripped";

private var _label:String;
private var _value:String;
private var _status:String;

private function onCreationComplete():void
{
	if(!_status)
	{
		this.status = DISCONNECTED;
	}
}

public function set status(value:String):void
{
	switch(value)
	{
		case (DISCONNECTED):
		{
			led.ledColor = LEDControl.RED;
			break;
		}
		case (CONNECTED):
		{
			led.ledColor = LEDControl.GREEN;
			break;
		}
		case (ACTIVE):
		{
			led.ledColor = LEDControl.GREEN;
			break;
		}
		case (TRIPPED):
		{
			led.ledColor = LEDControl.GREEN;
			break;
		}
		default:
		{
			trace("SensorStatusControl.status : status not recognized : " + value);
			return;
		}
	}
	
	_status = value;
	statusField.text = _status;
}

public function set label(value:String):void
{
	_label = value;
	labelField.text = _label;
}

public function get label():String
{
	return _label;
}

public function set value(value:String):void
{
	_value = value;
	valueField.text = _value;
}

public function get value():String
{
	return _value;
}