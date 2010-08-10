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

import com.mikechambers.accelerate.events.SettingsEvent;
import com.mikechambers.accelerate.logging.TextAreaTarget;
import com.mikechambers.accelerate.settings.Settings;

import mx.logging.Log;
import mx.logging.LogEventLevel;

private var _settings:Settings;

private var textAreaTarget:TextAreaTarget;

public function onComplete():void
{
	
	textAreaTarget = new TextAreaTarget(logTextArea);
	textAreaTarget.includeDate = false;
	textAreaTarget.includeTime = false;
	textAreaTarget.includeLevel = false;
	textAreaTarget.level = LogEventLevel.ALL;
	
	//apparently, the target is automatically
	//added by flex, so we have to remove it below
	//if we dont want to enable it
	if(_settings.logData)
	{
		Log.addTarget(textAreaTarget);
	}
	else
	{
		Log.removeTarget(textAreaTarget);
	}
}

public function set settings(value:Settings):void
{
	_settings = value;
	updateSettings();
}

private function updateSettings():void
{
	addressInput.text = _settings.serverAddress;
	portInput.text = String(_settings.serverPort);
	tripThresholdInput.text = String(_settings.lightSensorTripThreshold);
	changeThresholdInput.text = String(_settings.lightSensorChangeThreshold);
	sensorDistanceInput.text = String(_settings.lightSensorDistance);
	
	enableLogCB.selected = _settings.logData;
	
	saveButton.enabled = false;
	cancelButton.enabled = false;
}

private function onSaveClick():void
{
	var s:Settings = new Settings();
	s.serverAddress = addressInput.text;
	s.serverPort = uint(portInput.text);
	
	s.lightSensorTripThreshold = uint(tripThresholdInput.text);
	s.lightSensorChangeThreshold = uint(changeThresholdInput.text);
	
	s.logData = enableLogCB.selected;
	
	s.lightSensorDistance = Number(sensorDistanceInput.text);
	
	var e:SettingsEvent = new SettingsEvent(SettingsEvent.UPDATED);
	e.settings = s;
	
	_settings = s;
	
	if(_settings.logData)
	{
		Log.addTarget(textAreaTarget);
	}
	else
	{
		Log.removeTarget(textAreaTarget);
	}
	 
	//bug: no code hint for this
	dispatchEvent(e);
	
	saveButton.enabled = false;
	cancelButton.enabled = false;
}

private function onCancelClick():void
{
	updateSettings();
}

private function onChange():void
{
	saveButton.enabled = true;
	cancelButton.enabled = true;
}

