import com.mikechambers.accelerate.events.AccelerateEvent;
import com.mikechambers.accelerate.events.ViewEvent;

import flash.events.Event;
import flash.utils.Timer;

import mx.utils.NameUtil;


public static const MAIN_STATE:String = "speedometerState";
public static const DATA_STATE:String = "dataState";

public static const TRANSITION_SPEED:int = 500;

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