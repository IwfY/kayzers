module ui.ui;

import game;
import map;
import renderhelper;
import utils;
import client;
import renderer;
import ui.widget;
import ui.button;
import world.structureprototype;

import derelict.sdl2.sdl;

import std.conv;
import std.stdio;
import std.string;

class UI : Renderer {
	private const(Game) game;
	private Client client;
	private Widget[] widgets;
	private Button[] structureButtons;
	


	public this(Client client, RenderHelper renderer) {
		super(renderer);
		this.client = client;
		this.game = this.client.getGame();
		this.renderer = renderer;
		
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
									   &this.client.addStructureHandler);
		   this.structureButtons ~= button;
		   this.widgets ~= button;
		}
	}
	
	
	private void updateWidgets() {
		int structureButtonX = 50;
		int structureButtonY = this.screenRegion.y + 40;
		foreach(Button button; this.structureButtons) {
			button.setXY(structureButtonX, structureButtonY);
			structureButtonY += 30;
		}
	}



	public override void handleEvent(SDL_Event event) {
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


	public override void render() {
		this.renderer.drawTexture(0, this.screenRegion.y, "ui_background");
		this.renderer.drawText(10, this.screenRegion.y + 10,
							   text(this.game.getCurrentYear()));
		
		this.updateWidgets();

		foreach (Widget widget; this.widgets) {
			widget.render();
		}
	}
}
