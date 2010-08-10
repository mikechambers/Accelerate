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

import com.mikechambers.accelerate.events.AccelerateDataEvent;
import com.mikechambers.accelerate.events.AccelerateEvent;
import com.mikechambers.accelerate.events.SettingsEvent;
import com.mikechambers.accelerate.events.ViewEvent;
import com.mikechambers.accelerate.logging.TextAreaTarget;
import com.mikechambers.accelerate.serial.AccelerateSerialPort;
import com.mikechambers.accelerate.settings.Settings;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.Timer;

import mx.logging.Log;
import mx.logging.LogEventLevel;
import mx.logging.targets.TraceTarget;
import mx.utils.NameUtil;

public static const TRANSITION_SPEED:int = 500;

public static const MAIN_STATE:String = "speedometerState";
public static const DATA_STATE:String = "dataState";
public static const SETTINGS_STATE:String = "settingsState";

public static const SETTINGS_BUTTON_INDEX:uint = 0;
public static const MAIN_BUTTON_INDEX:uint = 1;
public static const DATA_BUTTON_INDEX:uint = 2;

private static const SETTINGS_FILE_NAME:String = "accelerate.settings";

public var settings:Settings;
private var arduino:AccelerateSerialPort;
private var traceTarget:TraceTarget;

private function onCreationComplete():void
{
	navButtonBar.selectedIndex = MAIN_BUTTON_INDEX;
	
	arduino = new AccelerateSerialPort(settings.serverAddress, settings.serverPort);
	
	mainView.arduino = arduino;
	
	//rename stuff here?
	arduino.tripThreshhold = settings.lightSensorTripThreshold;
	arduino.changeThreshhold = settings.lightSensorChangeThreshold;
	
	arduino.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
	arduino.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
	
	arduino.connect();
}

private function onIOError(event:IOErrorEvent):void
{
	Log.getLogger("LOG").error("IOErrorEvent : " + event.text);
}

private function onSecurityError(event:SecurityErrorEvent):void
{
	Log.getLogger("LOG").error("SecurityErrorEvent : " + event.text);
}


private function onInitialize():void
{
	traceTarget = new TraceTarget();
	
	traceTarget.includeDate = false;
	traceTarget.includeTime = false;
	traceTarget.includeLevel = true;
	traceTarget.level = LogEventLevel.ALL;
	
	Log.addTarget(traceTarget);
	
	loadSettings();
	mainView.settings = settings;
	settingsView.settings = settings;
}

private function onSettingsUpdated(e:SettingsEvent):void
{
	if(settings.lightSensorTripThreshold != 
		e.settings.lightSensorTripThreshold)
	{
		arduino.tripThreshhold = e.settings.lightSensorTripThreshold;
	}
	
	if(settings.lightSensorChangeThreshold !=
		e.settings.lightSensorChangeThreshold)
	{
		arduino.changeThreshhold = e.settings.lightSensorChangeThreshold;
	}
	
	if(
		(settings.serverAddress != e.settings.serverAddress) ||
		(settings.serverPort != e.settings.serverPort)
		)
	{
		arduino.close();
		
		arduino.connect(e.settings.serverAddress, e.settings.serverPort);
	}
	
	settings = e.settings;
	
	saveSettings();
}

private function saveSettings():void
{
	Log.getLogger("LOG").info("Saving Settings : " + settings.serverAddress);
	var f:File = File.applicationStorageDirectory.resolvePath(SETTINGS_FILE_NAME);
	var fs:FileStream = new FileStream();
	fs.open(f, FileMode.WRITE);
	fs.writeObject(settings);
	fs.close();
}

private function loadSettings():void
{
	var f:File = File.applicationStorageDirectory.resolvePath(SETTINGS_FILE_NAME);
	
	if(!f.exists)
	{
		settings = new Settings();
		return;
	}
	
	var fs:FileStream = new FileStream();
	fs.open(f, FileMode.READ);
	settings = fs.readObject() as Settings;
	fs.close();
}

private function onNavChange():void
{
	var index:int = navButtonBar.selectedIndex;
	
	var state:String;
	switch(index)
	{
		case SETTINGS_BUTTON_INDEX:
		{
			state = SETTINGS_STATE;
			break;
		}
		case MAIN_BUTTON_INDEX:
		{
			state = MAIN_STATE;
			break;
		}
		case DATA_BUTTON_INDEX:
		{
			state = DATA_STATE;
			break;
		}
	}
	
	currentState = state;
}

private function onDataViewRequest(e:ViewEvent):void
{
	currentState = DATA_STATE;
}

private function onMainViewRequest(e:ViewEvent):void
{
	currentState = MAIN_STATE;	
}

private function onTransitionStart(event:Event):void
{
	mainView.enabled = false;
	dataView.enabled = false;
}

private function onTransitionEnd(event:Event):void
{
	mainView.enabled = true;
	dataView.enabled = true;
}