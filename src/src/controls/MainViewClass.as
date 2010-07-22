
import com.mikechambers.accelerate.events.AccelerateEvent;
import com.mikechambers.accelerate.events.ViewEvent;

private function onCreationComplete():void
{
	sensor1.label = "Light Sensor 1";
	sensor2.label = "Light Sensor 2";
}

private function onDataButtonClick():void
{
	var e:ViewEvent = new ViewEvent(ViewEvent.DATA_VIEW_REQUEST);
	dispatchEvent(e);
}

private function onResetClick():void
{
	var e:AccelerateEvent = new AccelerateEvent(AccelerateEvent.RESET);
	dispatchEvent(e);
}