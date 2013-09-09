module ui.label;

import rect;
import renderhelper;
import utils;
import ui.widget;

import derelict.sdl2.sdl;


class Label : Widget {
	private string text;
	private string fontName;
	// x and y of padding mark the distance of text to widget border
	private Rect padding;
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
		this.padding = new Rect();

		// set width and height to actual bounds of rendered text
		Rect boundsRect = this.getTextSize();
		this.bounds.w = boundsRect.w + 2 * this.padding.x;
		this.bounds.h = boundsRect.h + 2 * this.padding.y;
	}


	private Rect getTextSize() {
		return this.renderer.getTextSize(this.text, this.fontName);
	}


	public override void setBounds(int x, int y, int w, int h) {
		// don't set new width and height as these are specified by renderer
		this.bounds.x = x;
		this.bounds.y = y;
	}


	public void setPadding(int x, int y) {
		this.padding.x = x;
		this.padding.y = y;

		Rect boundsRect = this.getTextSize();
		this.bounds.w = boundsRect.w + 2 * this.padding.x;
		this.bounds.h = boundsRect.h + 2 * this.padding.y;
	}


	public override void click() {
	}

	public override void draw() {
		this.renderer.drawText(this.bounds.x + this.padding.x,
							   this.bounds.y + this.padding.y,
							   this.text, this.fontName, this.color);
	}
}
