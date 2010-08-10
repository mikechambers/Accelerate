/*
	The MIT License

	Copyright (c) 2010 Mike Chambers

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

import com.mikechambers.accelerate.data.Result;
import com.mikechambers.accelerate.events.AccelerateDataEvent;
import com.mikechambers.accelerate.events.ViewEvent;
import com.mikechambers.accelerate.serial.AccelerateSerialPort;
import com.mikechambers.accelerate.settings.Settings;

import flash.events.Event;
import flash.media.Sound;

import mx.collections.ArrayCollection;
import mx.logging.Log;

private var _settings:Settings;

//private var _lastLightSensor_1_value:uint;
//private var _lastLightSensor_2_value:uint;

private var _arduino:AccelerateSerialPort;

private var sessionResults:ArrayCollection;

[Embed('assets/sounds/trigger_1.mp3')]
private var trigger_2:Class;

[Embed('assets/sounds/trigger_2.mp3')]
private var trigger_1:Class;

private var trigger2:Sound;
private var trigger1:Sound;

private function onCreationComplete():void
{
	sensor1.label = "Light Sensor 1";
	sensor2.label = "Light Sensor 2";
	arduinoDevice.label = "Arduino";
	
	trigger1 = new trigger_1() as Sound;
	trigger2 = new trigger_2() as Sound;
}

public function set settings(value:Settings):void
{
	_settings = value;
}

public function set arduino(value:AccelerateSerialPort):void
{
	//todo: we should make sure to remove listeners in case another
	//arduino instance is passed in.
	_arduino = value;	
	
	//a light sensor has tripped
	_arduino.addEventListener(AccelerateDataEvent.LIGHT_SENSOR_TRIP, onLightSensorTrip);
	
	//value of light sensor has updated
	_arduino.addEventListener(AccelerateDataEvent.LIGHT_SENSOR_UPDATE, onLightSensorUpdate);
	
	//both light sensors have tripped, and total time between trips is available
	_arduino.addEventListener(AccelerateDataEvent.TOTAL_TIME, onSensorTotalTime);
	
	//connected to the arduino hardware
	_arduino.addEventListener(AccelerateDataEvent.ARDUINO_ATTACH, onArduinoConnect);
	
	_arduino.addEventListener(AccelerateDataEvent.ARDUINO_DETACH, onArduinoDetach);
	
	_arduino.addEventListener( Event.CLOSE, onClose );
	
}

public override function set enabled(value:Boolean):void
{
	super.enabled = value;
	
	if(_arduino)
	{
		resetButton.enabled = _arduino.connected;
	}
}

private function onLightSensorTrip(event:AccelerateDataEvent):void
{	
	var sensor:String = event.sensor;
	var sensorStatusControl:SensorStatusControl;
	
	if(sensor == AccelerateSerialPort.LIGHT_SENSOR_1)
	{
		trigger1.play();
		sensorStatusControl = sensor1;
	}
	else if(sensor == AccelerateSerialPort.LIGHT_SENSOR_2)
	{
		trigger2.play();
		sensorStatusControl = sensor2;
	}
	else
	{
		Log.getLogger("LOG").error("onLightSensorTrip : Sensor not recognized : " + sensor);
		return;
	}
	
	sensorStatusControl.status = SensorStatusControl.TRIPPED;
}

private function onLightSensorUpdate(event:AccelerateDataEvent):void
{
	var value:Number = event.value;
	
	var sensor:String = event.sensor;
	var sensorStatusControl:SensorStatusControl;
	
	if(sensor == AccelerateSerialPort.LIGHT_SENSOR_1)
	{
		sensorStatusControl = sensor1;
	}
	else if(sensor == AccelerateSerialPort.LIGHT_SENSOR_2)
	{
		sensorStatusControl = sensor2;
	}
	else
	{
		Log.getLogger("LOG").error("onLightSensorUpdate : Sensor not recognized : " + sensor);
		return;
	}
	
	sensorStatusControl.status = (value == 0)?SensorStatusControl.DISCONNECTED:SensorStatusControl.ACTIVE;
	sensorStatusControl.value = String(value);
}

private function onSensorTotalTime(event:AccelerateDataEvent):void
{
	Log.getLogger("LOG").info("onSensorTotalTime : " + event.totalElapsedTime);
	var timeMs:Number = event.totalElapsedTime;
	var speedMPH:Number = calculateSpeed(timeMs / 1000);
	
	
	var r:Result = new Result();
	r.date = new Date();
	r.speed = speedMPH;
	r.rawTime = event.totalElapsedTime;
	r.distance = _settings.lightSensorDistance;
	
	if(!sessionResults)
	{
		sessionResults = new ArrayCollection();
		sessionResultsList.dataProvider = sessionResults;
	}
	
	sessionResults.addItemAt(r,0);
	
	speedView.speed = speedMPH;
	
	//saveButton.enabled = true;
	//titleInput.enabled = true;
	//notesField.enabled = true;
}

private function onArduinoConnect(event:AccelerateDataEvent):void
{
	arduinoDevice.status = SensorStatusControl.CONNECTED;
	
	resetButton.enabled = true;	
}

private function onArduinoDetach(event:AccelerateDataEvent):void
{
	arduinoDevice.status = SensorStatusControl.DISCONNECTED;
}

private function reset():void
{	
	sensor1.status = SensorStatusControl.RESETTING;
	sensor2.status = SensorStatusControl.RESETTING;
	
	sensor1.value = String(0);
	sensor1.value = String(0);
	
	_arduino.reset();
	
	speedView.reset();	
}

public function onClose(e:Event):void
{
	Log.getLogger("LOG").info("-------onDisconnect-------");
	arduinoDevice.status = SensorStatusControl.DISCONNECTED;
	sensor1.status = SensorStatusControl.DISCONNECTED;
	sensor2.status = SensorStatusControl.DISCONNECTED;
	
	sensor2.value = "";
	sensor1.value = "";
	
	resetButton.enabled = false;
}

/*
	This is my original function to calculate speed. It has been replaced
	by a much more efficient function below, but I am keeping this here
	so you can see the different approaches, and how it was optimized.
*/
/*
private function calculateSpeed2(elapsedTimeSeconds:Number):Number
{
	var inches:Number = 5.5;
	
	var t:Number = ((inches / elapsedTimeSeconds) * 3600);
	
	var t2:Number = t / 63360; // 63360 inches in a mile
	
	return t2;
}
*/

private function calculateSpeed(elapsedTimeSeconds:Number):Number
{	
	/*
		Thanks to Tim Goss for vastly simplifying
		my algorithm for converting inches / second
		into miles / hour
	
		5.5 inches / 0.083 sec = 66.265 inches/sec
		
		66.265 inches/sec  x 3600 sec/hour = 239850 inches/hour
		
		239850 inches/hour / 63360 inches/mile = 3.76 miles/hour
		
		looks good :)
		
		but the 63360 and 3600 are constants so you can simplify this a bit and 
		convert inches/sec directly to miles/hour
		
		1 mile/hour = 63360 inches / 3600 sec = 17.6 inches/sec
		
		just dividing by 17.6 and you can avoid the larger numbers and the extra 
		multiply and divide...
		
		5.5 inches / 0.083 sec / 17.6 = 3.76 miles/hour
		
		or just...
		
		milesPerHour = distanceInInches / timeInSeconds / 17.6	
	
	*/
	
	//lightSensorDistance is specified in inches
	return _settings.lightSensorDistance / elapsedTimeSeconds / 17.6;
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