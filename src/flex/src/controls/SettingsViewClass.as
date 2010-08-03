
import com.mikechambers.accelerate.events.SettingsEvent;
import com.mikechambers.accelerate.settings.Settings;

private var _settings:Settings;

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
	
	s.lightSensorDistance = Number(sensorDistanceInput.text);
	
	var e:SettingsEvent = new SettingsEvent(SettingsEvent.UPDATED);
	e.settings = s;
	
	_settings = s;
	 
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

