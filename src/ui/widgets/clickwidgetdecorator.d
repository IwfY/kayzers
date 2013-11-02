module ui.widgets.clickwidgetdecorator;

import ui.widgets.widgetdecorator;
import ui.widgets.widgetinterface;

/**
 * make a widget clickable by providing a callback method
 **/
class ClickWidgetDecorator : WidgetDecorator {
	private void delegate(string) callback;	// callback function pointer

	public this(WidgetInterface decoratedWidget,
				void delegate(string) callback) {
		super(decoratedWidget);
		this.callback = callback;
	}

	public override void click() {
		this.decoratedWidget.click();
		this.callback(this.decoratedWidget.getName());
	}

	public override void mouseEnter() {
		this.decoratedWidget.mouseEnter();
		//TODO change mouse pointer
	}

	public override void mouseLeave() {
		this.decoratedWidget.mouseLeave();
		//TODO change mouse pointer
	}
}
