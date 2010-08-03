import com.mikechambers.accelerate.events.AccelerateDataEvent;
import com.mikechambers.accelerate.events.AccelerateEvent;
import com.mikechambers.accelerate.events.SettingsEvent;
import com.mikechambers.accelerate.events.ViewEvent;
import com.mikechambers.accelerate.serial.AccelerateSerialPort;
import com.mikechambers.accelerate.settings.Settings;

import flash.events.Event;
import flash.utils.Timer;

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

private function onCreationComplete():void
{
	navButtonBar.selectedIndex = MAIN_BUTTON_INDEX;
	
	arduino = new AccelerateSerialPort(settings.serverAddress, settings.serverPort);
	
	mainView.arduino = arduino;
	
	//rename stuff here?
	arduino.tripThreshhold = settings.lightSensorTripThreshold;
	arduino.changeThreshhold = settings.lightSensorChangeThreshold;
	
	//connected to the proxy server (but not the hardware).
	arduino.addEventListener( Event.CONNECT, onConnect );
	arduino.addEventListener( IOErrorEvent.IO_ERROR, onIOErrorEvent );
	arduino.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
	
	arduino.connect();
}

private function onInitialize():void
{
	loadSettings();
	mainView.settings = settings;
	settingsView.settings = settings;
}

private function onIOErrorEvent(event:IOErrorEvent):void
{
	trace("IOErrorEvent : " + event.text);	
}

private function onSecurityError(event:SecurityErrorEvent):void
{
	trace("SecurityErrorEvent : " + event.text );	
}

private function onConnect(e:Event):void
{
	trace("-------onConnect-------");
}

private function onArduinoConnect(event:AccelerateDataEvent):void
{
	trace("arduino connect");
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
	
	settings = e.settings;
	
	saveSettings();
}

private function saveSettings():void
{
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