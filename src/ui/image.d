module ui.image;

import utils;
import renderhelper;
import ui.widget;

import derelict.sdl2.sdl;

class Image : Widget {
	public this(RenderHelper renderer,
				string name,
				string textureName,
				const(SDL_Rect *)bounds) {
		super(renderer, name, textureName, bounds);
	}
	
	override public void click() {
	}

	public override void draw() {
	}
}