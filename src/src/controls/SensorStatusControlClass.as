
import controls.LEDControl;

private var _label:String;
private var _value:String;

private function updateLabel():void
{
	var out:String = _label;
	
	if(value)
	{
		out += " : " + value;
	}
	
	labelField.text = out;
}

public function set label(value:String):void
{
	_label = value;
	updateLabel();
}

public function get label():String
{
	return _label;
}

public function set value(value:String):void
{
	_value = value;
	updateLabel();
}

public function get value():String
{
	return _value;
}

public function set ledColor(value:String):void
{
	led.ledColor = value;
}

public function get ledColor():String
{
	return led.ledColor;
}