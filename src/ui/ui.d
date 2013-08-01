module ui.ui;

import map;
import renderhelper;
import utils;
import client;
import ui.widget;
import ui.button;

import derelict.sdl2.sdl;

import std.stdio;
import std.string;

class UI {
	private Client client;
	private RenderHelper renderer;
	private Widget[] widgets;
	private SDL_Rect *screenRegion;


	public this(Client client, RenderHelper renderer) {
		this.client = client;
		this.renderer = renderer;

		this.screenRegion = new SDL_Rect(0, 0);

		Button button = new Button(this.renderer, "test", "button_default",
								   new SDL_Rect(100, 100, 20, 20),
								   &this.renderer.uiCallbackHandler);
		this.widgets ~= button;
	}


	public void setScreenRegion(int x, int y, int w, int h) {
		this.screenRegion.x = x;
		this.screenRegion.y = y;
		this.screenRegion.w = w;
		this.screenRegion.h = h;
	}



	public void handleEvent(SDL_Event event) {

	}


	public void render() {
		this.renderer.drawTexture(0, this.screenRegion.y, "ui_background");
		this.renderer.drawText(10, this.screenRegion.y + 10, "test");

		foreach(Widget widget; this.widgets) {
			widget.render();
		}
	}
}
