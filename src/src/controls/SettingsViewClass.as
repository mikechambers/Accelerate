
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
	thresholdSlider.value = _settings.lightSensorThreshold;
	changeTriggerSlider.value = _settings.lightSensorChangeTrigger;
	sensorDistanceInput.text = String(_settings.lightSensorDistance);
	
	saveButton.enabled = false;
	cancelButton.enabled = false;
}

private function onSaveClick():void
{
	_settings.serverAddress = addressInput.text;
	_settings.serverPort = uint(portInput.text);
	_settings.lightSensorThreshold = thresholdSlider.value;
	_settings.lightSensorChangeTrigger = uint(changeTriggerSlider.value);
	_settings.lightSensorDistance = Number(sensorDistanceInput.text);
	
	var e:SettingsEvent = new SettingsEvent(SettingsEvent.UPDATED);
	e.settings = _settings;
	
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

