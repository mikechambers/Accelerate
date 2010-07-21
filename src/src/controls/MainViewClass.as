
import com.mikechambers.accelerate.events.ViewEvent;

private var creationCompleted:Boolean = false;

private function onCreationComplete():void
{
	creationCompleted = true;
}

private function onDataButtonClick():void
{
	var e:ViewEvent = new ViewEvent(ViewEvent.DATA_VIEW_REQUEST);
	dispatchEvent(e);
}

public override function set enabled(value:Boolean):void
{
	super.enabled = value;
	
	if(!creationCompleted)
	{
		return;
	}
	
	resetButton.enabled = value;
	saveButton.enabled = value;
	notesField.enabled = value;
	nameInput.enabled = value;
}