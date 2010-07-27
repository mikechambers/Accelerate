
import com.mikechambers.accelerate.events.AccelerateEvent;
import com.mikechambers.accelerate.events.ViewEvent;
import com.phidgets.Phidget;
import com.phidgets.PhidgetInterfaceKit;
import com.phidgets.events.PhidgetDataEvent;
import com.phidgets.events.PhidgetEvent;

import controls.LEDControl;

public static const PHIDGET_PORT:uint = 5001;

public static const LIGHT_SENSOR_1_INDEX:uint = 6;
public static const LIGHT_SENSOR_2_INDEX:uint = 7;

public static const SENSOR_1_OUTPUT_INDEX:uint = 6;
public static const SENSOR_2_OUTPUT_INDEX:uint = 7;

public static const LIGHT_THRESHHOLD:Number = 75;
public static const LIGHT_SENSOR_CHANGE_TRIGGER:uint = 100;

private var _lastLightSensor_1_value:Number = 0;
private var _lastLightSensor_2_value:Number = 0;

private var _lightSensor_1_triggered:Boolean = false;

private var _startTimeStamp:Number;

private var interfaceKit:PhidgetInterfaceKit;

private function onCreationComplete():void
{
	sensor1.label = "Light Sensor 1";
	sensor2.label = "Light Sensor 2";
	interfaceSensor.label = "Interface Kit";
	
	interfaceKit = new PhidgetInterfaceKit();
	
	interfaceKit.addEventListener(PhidgetEvent.CONNECT,	onConnect);
	interfaceKit.addEventListener(PhidgetEvent.DETACH,	onDetach);
	interfaceKit.addEventListener(PhidgetEvent.ATTACH,	onAttach);
	interfaceKit.addEventListener(PhidgetEvent.DISCONNECT, onDisconnect);
	//phid.addEventListener(PhidgetDataEvent.INPUT_CHANGE, onInputChange);
	//phid.addEventListener(PhidgetDataEvent.OUTPUT_CHANGE, onOutputChange);
	
	trace(calculateSpeed(0.083));
	trace(calculateSpeed2(0.083));
	interfaceKit.open("127.0.0.1", PHIDGET_PORT);
}

public override function set enabled(value:Boolean):void
{
	super.enabled = value;
	
	if(interfaceKit)
	{
		resetButton.enabled = interfaceKit.isAttached;
	}
}

public function onConnect(e:PhidgetEvent):void
{
	//note : cant query phidget here, and it will throw an error
	//since the data isnt available yet
	trace("-------onConnect-------");
}

public function onDetach(e:PhidgetEvent):void
{
	var device:Phidget = e.Device;
	trace("-------onDetach-------");
	trace(device.Name, device.Label, device.serialNumber);
	
	interfaceSensor.ledColor = LEDControl.RED;
	sensor1.ledColor = LEDControl.RED;
	sensor2.ledColor = LEDControl.RED;
	
	resetButton.enabled = false;
}

public function onAttach(e:PhidgetEvent):void
{
	var device:Phidget = e.Device;
	trace("-------onAttach------- ");
	trace(device.Name + " : " + device.Label);
	trace("Version : " + device.Version);
	trace("Serial : " + device.serialNumber);
	
	interfaceSensor.ledColor = LEDControl.GREEN;
	
	interfaceKit.setSensorChangeTrigger(LIGHT_SENSOR_1_INDEX, LIGHT_SENSOR_CHANGE_TRIGGER);
	interfaceKit.setSensorChangeTrigger(LIGHT_SENSOR_2_INDEX, LIGHT_SENSOR_CHANGE_TRIGGER);
	
	resetButton.enabled = true;
	
	reset();
}

private function reset():void
{
	_lastLightSensor_1_value = interfaceKit.getSensorValue(LIGHT_SENSOR_1_INDEX);
	_lastLightSensor_2_value = interfaceKit.getSensorValue(LIGHT_SENSOR_2_INDEX);
	
	sensor1.ledColor = (_lastLightSensor_1_value == 0)?LEDControl.RED:LEDControl.GREEN;
	sensor2.ledColor = (_lastLightSensor_2_value == 0)?LEDControl.RED:LEDControl.GREEN;	
	
	sensor1.value = String(_lastLightSensor_1_value);
	sensor2.value = String(_lastLightSensor_2_value);
	
	interfaceKit.setOutputState(SENSOR_1_OUTPUT_INDEX, false);
	interfaceKit.setOutputState(SENSOR_2_OUTPUT_INDEX, false);
	
	_lightSensor_1_triggered = false;
	_startTimeStamp = 0;
	
	speedView.reset();
	
	interfaceKit.addEventListener(PhidgetDataEvent.SENSOR_CHANGE, onSensorChange);
}

public function onDisconnect(e:PhidgetEvent):void
{
	var device:Phidget = e.Device;
	trace("-------onDisconnect-------");
	trace(device.Name, device.Label, device.serialNumber);
	
	sensor1.ledColor = LEDControl.RED;
	sensor2.ledColor = LEDControl.RED;
}

public function onSensorChange(e:PhidgetDataEvent):void
{
	var index:uint = e.Index;
	var value:Number = Number(e.Data);
	
	var change:Number;
	
	switch(index)
	{
		case LIGHT_SENSOR_1_INDEX:
		{
			if(_lightSensor_1_triggered)
			{
				return;
			}
			
			//trace("Light Sensor 1 : " + Number(e.Data));
			
			change = (Math.abs(_lastLightSensor_1_value - value) / value) * 100;
			
			_lastLightSensor_1_value = value;
			
			sensor1.value = String(value);
			
			if(Math.abs(change) > LIGHT_THRESHHOLD)
			{
				_lightSensor_1_triggered = true;
				_startTimeStamp = new Date().getTime();
				interfaceKit.setOutputState(SENSOR_1_OUTPUT_INDEX, true);
				
				trace("HIT");
			}
			
			break;
		}
		case LIGHT_SENSOR_2_INDEX:
		{
			
			//trace("Light Sensor 2 : " + Number(e.Data));			
			
			change = (Math.abs(_lastLightSensor_2_value - value) / value) * 100;
			
			_lastLightSensor_2_value = value;
			sensor2.value = String(value);
			
			if(Math.abs(change) > LIGHT_THRESHHOLD)
			{
				var stopTimeStamp:Number = new Date().getTime();
				
				var elapsedTime:Number = stopTimeStamp - _startTimeStamp;
				
				
				
				var distunitsvalue:Number = .0254;
				var speedunitsvalue:Number = 0.44704;
				var temp:Number =  elapsedTime / 1000;
				var inches:Number = 5.5;
				
				//  calculate speed
				
				var speedMPH:Number = ((inches * distunitsvalue)  / (temp * speedunitsvalue)); 				
				//interfaceKit.setOutputState(SENSOR_2_OUTPUT_INDEX, true);
				trace(speedMPH);
				speedView.speed = speedMPH;				
				trace("Light Sensor 2 : HIT");
				trace("Elapsed Time : " + (elapsedTime / 1000));
				
				
				
				interfaceKit.removeEventListener(PhidgetDataEvent.SENSOR_CHANGE, onSensorChange);
				
			}			
			
			break;
		}
	}
}

private function calculateSpeed(elapsedTimeSeconds:Number):Number
{
	var distunitsvalue:Number = .0254;
	var speedunitsvalue:Number = 0.44704;
	var temp:Number =  elapsedTimeSeconds;
	var inches:Number = 5.5;
	
	//  calculate speed
	
	var speedMPH:Number = ((inches * distunitsvalue)  / (temp * speedunitsvalue));
	return speedMPH;
}

private function calculateSpeed2(elapsedTimeSeconds:Number):Number
{
	var inches:Number = 5.5;
	
	var t:Number = ((inches / elapsedTimeSeconds) * 3600);
	
	var t2:Number = t / 63360; // 63360 inches in a mile
	
	return t2;
}

private function onDataButtonClick():void
{
	var e:ViewEvent = new ViewEvent(ViewEvent.DATA_VIEW_REQUEST);
	dispatchEvent(e);
}

private function onResetClick():void
{
	reset();
}