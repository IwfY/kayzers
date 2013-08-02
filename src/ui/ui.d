module ui.ui;

import map;
import renderhelper;
import utils;
import client;
import ui.widget;
import ui.button;
import world.structureprototype;

import derelict.sdl2.sdl;

import std.stdio;
import std.string;

class UI {
	private Client client;
	private RenderHelper renderer;
	private Widget[] widgets;
	private Button[] structureButtons;
	private SDL_Rect *screenRegion;


	public this(Client client, RenderHelper renderer) {
		this.client = client;
		this.renderer = renderer;

		this.screenRegion = new SDL_Rect(0, 0);
		
		this.initWidgets();
	}
	
	
	public void initWidgets() {
		// structure buttons
		foreach (const StructurePrototype structurePrototype;
				 this.client.getStructurePrototypes()) {
			Button button = new Button(this.renderer,
									   structurePrototype.getName(),
									   structurePrototype.getIconImageName(),
									   new SDL_Rect(0, 0, 20, 20),
									   &this.renderer.uiCallbackHandler);
		   this.structureButtons ~= button;
		   this.widgets ~= button;
		}
	}


	public void setScreenRegion(int x, int y, int w, int h) {
		this.screenRegion.x = x;
		this.screenRegion.y = y;
		this.screenRegion.w = w;
		this.screenRegion.h = h;
	}
	
	
	private void updateWidgets() {
		int structureButtonX = 50;
		int structureButtonY = this.screenRegion.y + 40;
		foreach(Button button; this.structureButtons) {
			button.setXY(structureButtonX, structureButtonY);
			structureButtonY += 30;
		}
	}



	public void handleEvent(SDL_Event event) {
		// left mouse down
		if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_LEFT) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			foreach (Widget widget; this.widgets) {
				if (widget.isPointInBounds(mousePosition)) {
					widget.click();
				}
			}
		}
	}


	public void render() {
		this.renderer.drawTexture(0, this.screenRegion.y, "ui_background");
		this.renderer.drawText(10, this.screenRegion.y + 10, "test");
		
		this.updateWidgets();

		foreach (Widget widget; this.widgets) {
			widget.render();
		}
	}
}
