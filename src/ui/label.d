module ui.label;

import rect;
import renderhelper;
import utils;
import ui.widget;

import derelict.sdl2.sdl;


class Label : Widget {
	private string text;
	private string fontName;
	private SDL_Color *color;
	
	public this(RenderHelper renderer,
				string name,
				string textureName,
				SDL_Rect *bounds,
				string text,
				string fontName,
				SDL_Color *color = null) {
		super(renderer, name, textureName, bounds);
		this.text = text;
		this.fontName = fontName;
		if (color is null) {
			this.color = new SDL_Color(255, 255, 255);
		} else {
			this.color = color;
		}
		Rect boundsRect = this.renderer.getTextSize(this.text, this.fontName);
		this.bounds.w = boundsRect.w;
		this.bounds.h = boundsRect.h;
	}


	override public void click() {
	}
	
	public override void render() {
		super.render();
		this.renderer.drawText(this.bounds.x, this.bounds.y,
							   this.text, this.fontName, this.color);
	}
}
