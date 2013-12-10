module ui.widgets.label;

import constants;
import rect;
import utils;
import ui.widgets.widget;
import ui.renderhelper;

import derelict.sdl2.sdl;

import std.array;


class Label : Widget {
	private string[] text;
	private string fontName;
	private string textureName;
	// x and y of padding mark the distance of text to widget border
	private Rect padding;
	private SDL_Color *color;

	public this(RenderHelper renderer,
				string textIn,
				string fontName=STD_FONT,
				SDL_Color *color=null,
				string textureName = NULL_TEXTURE) {
		super(renderer);

		this.textureName = textureName;
		this.fontName = fontName;
		if (color is null) {
			this.color = new SDL_Color(255, 255, 255);
		} else {
			this.color = color;
		}
		this.padding = new Rect();

		this.setText(textIn);
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


	public void setText(string textIn) {
		this.text = textIn.split("\n");

		// set width and height to actual bounds of rendered text
		Rect boundsRect = this.getTextSize();
		this.bounds.w = boundsRect.w + 2 * this.padding.x;
		this.bounds.h = boundsRect.h + 2 * this.padding.y;
	}


	public void setPadding(int x, int y) {
		this.padding.x = x;
		this.padding.y = y;

		Rect boundsRect = this.getTextSize();
		this.bounds.w = boundsRect.w + 2 * this.padding.x;
		this.bounds.h = boundsRect.h + 2 * this.padding.y;
	}

	protected override void draw() {
		this.renderer.drawTexture(this.bounds, this.textureName);
		this.renderer.drawTextMultiline(
				this.bounds.x + this.padding.x,
				this.bounds.y + this.padding.y,
				this.text, this.fontName, 1.2, this.color);
	}
}
