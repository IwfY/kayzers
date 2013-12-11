module ui.widgets.clickwidgetdecorator;

import ui.widgets.iwidget;
import ui.widgets.widgetdecorator;

import derelict.sdl2.sdl;

/**
 * make a widget clickable by providing a callback method
 **/
class ClickWidgetDecorator : WidgetDecorator {
	private string name;
	private void delegate(string) callback;	// callback function pointer

	public this(IWidget decoratedWidget,
				string name,
				void delegate(string) callback) {
		super(decoratedWidget);
		this.callback = callback;
		this.name = name;
	}

	public override void handleEvent(SDL_Event event) {
		if (this.isHidden()) {
			return;
		}

		super.handleEvent(event);
		// left mouse down
		if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_LEFT) {
			if (this.isPointInBounds(event.button.x, event.button.y)) {
				this.callback(this.name);
			}
		}
	}
}
