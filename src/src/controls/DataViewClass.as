
import com.mikechambers.accelerate.events.ViewEvent;

private var creationCompleted:Boolean = false;

private function onCreationComplete():void
{
	creationCompleted = true;
}

private function onMainButtonClick():void
{
	var e:ViewEvent = new ViewEvent(ViewEvent.MAIN_VIEW_REQUEST);
	dispatchEvent(e);
}

public override function set enabled(value:Boolean):void
{
	super.enabled = value;
	
	if(!creationCompleted)
	{
		return;
	}
	
	mainViewButton.enabled = value;
}