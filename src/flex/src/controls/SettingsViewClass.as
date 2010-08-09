
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
	textAreaTarget.includeLevel = true;
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
	tripThresholdSlider.value = _settings.lightSensorTripThreshold;
	changeThresholdSlider.value = _settings.lightSensorChangeThreshold;
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
	
	s.lightSensorTripThreshold = uint(tripThresholdSlider.value);
	s.lightSensorChangeThreshold = uint(changeThresholdSlider.value);
	
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

