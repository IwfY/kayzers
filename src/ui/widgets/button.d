module ui.button;

import utils;
import ui.widgets.hoverwidget;
import ui.renderhelper;

import derelict.sdl2.sdl;


class Button : HoverWidget {
	private string name;
	private void delegate(string) callback;	// callback function pointer

	public this(RenderHelper renderer,
				string name,
				string textureName,
				string hoverTextureName,
				void delegate(string) callback,
				SDL_Rect *bounds = new SDL_Rect()) {
		super(renderer, textureName, hoverTextureName, bounds);
		this.name = name;
		this.callback = callback;
	}


	public void click() {
		this.callback(this.name);
	}

	public override void handleEvent(SDL_Event event) {
		if (this.isHidden()) {
			return;
		}

		super.handleEvent(event);

		// left mouse down
		if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_LEFT) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			if (this.isPointInBounds(mousePosition)) {
				this.click();
			}
		}
	}
}
