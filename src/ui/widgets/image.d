module ui.image;

import utils;
import ui.renderhelper;
import ui.widgets.widget;

import derelict.sdl2.sdl;

class Image : Widget {
	public this(RenderHelper renderer,
				string name,
				string textureName,
				const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, name, textureName, bounds);
	}
	
	override public void click() {
	}

	protected override void draw() {
	}
}
