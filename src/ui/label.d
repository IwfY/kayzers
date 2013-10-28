module ui.label;

import constants;
import rect;
import utils;
import ui.widget;
import ui.renderhelper;

import derelict.sdl2.sdl;

import std.array;


class Label : Widget {
	private string[] text;
	private string fontName;
	// x and y of padding mark the distance of text to widget border
	private Rect padding;
	private SDL_Color *color;

	public this(RenderHelper renderer,
				string name,
				string textureName,
				SDL_Rect *bounds,
				string textIn,
				string fontName=STD_FONT,
				SDL_Color *color=null) {
		super(renderer, name, textureName, bounds);
		this.text = textIn.split("\n");
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
		int maxWidth = 0;
		int lineHeight = 0;
		foreach (string line; this.text) {
			Rect size = this.renderer.getTextSize(line, this.fontName);
			if (size.w > maxWidth) {
				maxWidth = size.w;
			}
			lineHeight = size.h;
		}
		Rect result = new Rect();
		result.w = maxWidth;
		result.h = cast(int)(lineHeight + lineHeight * 0.2) *
				cast(int)this.text.length;

		return result;
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

	protected override void draw() {
		this.renderer.drawTextMultiline(
				this.bounds.x + this.padding.x,
				this.bounds.y + this.padding.y,
				this.text, this.fontName, 1.2, this.color);
	}
}
