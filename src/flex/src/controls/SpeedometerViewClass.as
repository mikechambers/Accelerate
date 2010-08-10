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