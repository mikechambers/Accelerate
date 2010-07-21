import com.mikechambers.accelerate.enums.MeasurementSystemEnum;

public function set speed(value:Number):void
{
	speedLabel.text = String(value);
}

public function get speed():Number
{
	return Number(speedLabel.text);
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