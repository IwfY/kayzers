module ui.button;

import utils;
import ui.widgets.hoverwidget;
import ui.renderhelper;

import derelict.sdl2.sdl;


class Button : HoverWidget {
	private void delegate(string) callback;	// callback function pointer
	
	public this(RenderHelper renderer,
				string name,
				string textureName,
				string hoverTextureName,
				SDL_Rect *bounds,
				void delegate(string) callback) {
		super(renderer, name, textureName, hoverTextureName, bounds);
		this.callback = callback;
	}
				
	
	public override void click() {
		this.callback(this.name);
	}

	protected override void draw() {
	}
}
