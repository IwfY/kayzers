module ui;

import map;
import renderer;
import utils;
import client;

import derelict.sdl2.sdl;

import std.stdio;
import std.string;

class UI {
	private Client client;
	private Renderer renderer;
	
	
	public this(Client client, Renderer renderer) {
		this.client = client;
		this.renderer = renderer;
	}
	
	public void render(SDL_Point *mousePosition,
					   SDL_Rect *selectedRegion) {
		SDL_Rect *mapRegion = this.renderer.getMapScreenRegion();
		this.renderer.drawTexture(0, mapRegion.h, "ui_background");
		this.renderer.drawText(10, mapRegion.h + 10, "test");
	}
}
