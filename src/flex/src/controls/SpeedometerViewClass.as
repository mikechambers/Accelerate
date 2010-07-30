import com.mikechambers.accelerate.enums.MeasurementSystemEnum;

public function set speed(value:Number):void
{
	var roundedSpeed:Number = Math.round(value *100)/100;
	
	var speedString:String = String(roundedSpeed);
	
	if(roundedSpeed < 10)
	{
		speedString = "0" + speedString;
	}
	speedLabel.text = speedString;
}


public function get speed():Number
{
	return Number(speedLabel.text);
}

public function reset():void
{
	speedLabel.text = "00.00";
}

public function set measurementSystem(value:String):void
{
	if(value != MeasurementSystemEnum.CUSTOMARY &&
	value != MeasurementSystemEnum.IMPERIAL &&
	value != MeasurementSystemEnum.METRIC)
	{
		throw new Error("Unknown Measurement System specified : [" + value + "]");
		return;
	}
	
}