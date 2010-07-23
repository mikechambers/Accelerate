import com.mikechambers.accelerate.events.AccelerateEvent;
import com.mikechambers.accelerate.events.ViewEvent;

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

private function onCreationComplete():void
{
	navButtonBar.selectedIndex = MAIN_BUTTON_INDEX;
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