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
