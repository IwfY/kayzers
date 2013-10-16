module ui.ui;

import client;
import constants;
import map;
import position;
import rect;
import utils;
import ui.button;
import ui.image;
import ui.ingamerenderer;
import ui.maprenderer;
import ui.minimap;
import ui.popupbutton;
import ui.renderer;
import ui.renderhelper;
import ui.structurenamerenderer;
import ui.textinputrenderer;
import ui.widget;
import world.nation;
import world.nationprototype;
import world.resourcemanager;
import world.structure;
import world.structureprototype;

import derelict.sdl2.sdl;

import std.conv;
import std.math;
import std.stdio;
import std.string;

class UI : Renderer {
	private const(Map) map;
	private Widget[] widgets;
	private Widget mouseOverWidget;	// reference to widget under mouse
	private PopupButton[] structureButtons;
	private Image tileImage;
	private Image structureImage;
	private const(MapRenderer) mapRenderer;
	private MiniMap miniMap;
	private InGameRenderer inGameRenderer;



	public this(Client client, RenderHelper renderer, InGameRenderer inGameRenderer,
				const(MapRenderer) mapRenderer) {
		super(client, renderer);
		this.inGameRenderer = inGameRenderer;
		this.mapRenderer = mapRenderer;
		this.map = this.client.getMap();

		this.initWidgets();
	}


	public void initWidgets() {
		// structure buttons
		foreach (const StructurePrototype structurePrototype;
				 this.client.getStructurePrototypes()) {
			PopupButton button = new PopupButton(
					this.renderer,
					structurePrototype.getName(),
					structurePrototype.getIconImageName(),
					NULL_TEXTURE,
					new SDL_Rect(0, 0, 35, 35),
					&this.addStructureHandler,
					structurePrototype.getPopupText(),
					STD_FONT);
		   this.structureButtons ~= button;
		   this.widgets ~= button;
		}

		// selected structure and tile display
		this.tileImage = new Image(this.renderer,
								   "",
								   NULL_TEXTURE,
								   new SDL_Rect(0, 0, 20, 20));
		this.widgets ~= this.tileImage;
		this.structureImage = new Image(this.renderer,
									    "",
									    NULL_TEXTURE,
									    new SDL_Rect(0, 0, 20, 20));
		this.widgets ~= this.structureImage;

		// mini map
		this.miniMap = new MiniMap(this.renderer, "minimap", "minimap_bg",
								   new SDL_Rect(0, 0, 160, 160),
								   this.client);
		this.widgets ~= this.miniMap;
	}


	private void updateWidgets() {
		// selected structure and tile display
		const(Position) selectedPosition =
				this.mapRenderer.getSelectedPosition();
		const(Rect) tileDimensions = this.mapRenderer.getTileDimensions();
		if (selectedPosition !is null) {
			bool isOnMap = this.map.isPositionInMap(selectedPosition.i,
													selectedPosition.j);
			if (isOnMap) {
				byte tile = this.map.getTile(selectedPosition.i,
											 selectedPosition.j);
				string textureName =
					this.renderer.getTextureNameByTileIdentifier(tile);

				this.tileImage.setTextureName(textureName);
				this.tileImage.setBounds(this.screenRegion.x + 20,
										 this.screenRegion.y + 40,
										 tileDimensions.w,
										 tileDimensions.h);

				// structure
				const(Structure) structure =
					this.client.getStructure(selectedPosition.i,
											 selectedPosition.j);
				if (structure !is null) {
					const(StructurePrototype) prototype =
							structure.getPrototype();
					this.structureImage.setTextureName(
							prototype.getTileImageName());
					this.structureImage.setBounds(this.screenRegion.x + 20,
												  this.screenRegion.y + 40,
												  tileDimensions.w,
												  tileDimensions.h);
					// resource text
					string resourceString;
					const(ResourceManager) resources =
							structure.getResources();
					foreach (string resourceName;
							 resources.getResources().keys) {
						resourceString ~= resourceName ~ ": " ~
							text(resources.getResourceAmount(resourceName)) ~
							"; ";
					}
					this.renderer.drawText(
							this.screenRegion.x + 20,
							this.screenRegion.y + 40 + tileDimensions.h + 5,
							resourceString);
					// structure name
					this.renderer.drawText(this.screenRegion.x + 20,
											this.screenRegion.y + 25,
											structure.getNameString());
				} else {
					this.structureImage.setTextureName(NULL_TEXTURE);
				}
			} else {
				this.tileImage.setTextureName(NULL_TEXTURE);
				this.structureImage.setTextureName(NULL_TEXTURE);
			}
		}

		// structure buttons
		int structureButtonX = 300;
		int structureButtonY = this.screenRegion.y + 30;
		foreach(PopupButton button; this.structureButtons) {
			button.setXY(structureButtonX, structureButtonY);
			structureButtonX += 45;
		}

		// minimap
		this.miniMap.setXY(this.screenRegion.x + this.screenRegion.w - 170,
						   this.screenRegion.y + 10);
	}


	public void addStructureHandler(string structureName) {
		bool success = this.client.addStructure(
			structureName,
			this.client.getCurrentNation(),
			this.mapRenderer.getSelectedPosition());

		if (success) {
			const(Structure) newStructure = this.client.getStructure(
				this.mapRenderer.getSelectedPosition().i,
				this.mapRenderer.getSelectedPosition().j);
			// name new nameable structures
			if (newStructure !is null) {
				if (newStructure.getPrototype().isNameable()) {
					this.inGameRenderer.startStructureNameRenderer(newStructure);
				}
			}
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
		// mouse motion --> hover effects
		else if (event.type == SDL_MOUSEMOTION) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			bool widgetMouseOver = false; // is there a widget under the mouse?
			foreach (Widget widget; this.widgets) {
				if (widget.isPointInBounds(mousePosition)) {
					widgetMouseOver = true;
					if (this.mouseOverWidget is null) {
						this.mouseOverWidget = widget;
						this.mouseOverWidget.mouseEnter();
						break;
					} else if (this.mouseOverWidget != widget) {
						this.mouseOverWidget.mouseLeave();
						this.mouseOverWidget = widget;
						this.mouseOverWidget.mouseEnter();
						break;
					}
				}
			}
			// no widget under mouse but there was one before
			if (!widgetMouseOver && this.mouseOverWidget !is null) {
				this.mouseOverWidget.mouseLeave();
				this.mouseOverWidget = null;
			}
		}
	}


	public override void render(int tick=0) {
		this.renderer.drawTexture(0, this.screenRegion.y, "ui_background");

		// nation flag and name
		const(Nation) nation = this.client.getCurrentNation();
		this.renderer.drawTexture(
				11, this.screenRegion.y + 144,
				nation.getPrototype().getFlagImageName());
		this.renderer.drawTexture(10, this.screenRegion.y + 143,
								   "border_round_30");
		this.renderer.drawText(44, this.screenRegion.y + 160,
							    nation.getName());

		// resource text
		string resourceString;
		const(ResourceManager) resources = nation.getResources();

		// gold
		this.renderer.drawTexture(200, this.screenRegion.y + 160, "gold");
		this.renderer.drawText(
				220, this.screenRegion.y + 160,
				text(floor(resources.getResourceAmount("gold"))));
		// inhabitants
		this.renderer.drawTexture(300, this.screenRegion.y + 160,
								  "inhabitants");
		this.renderer.drawText(
				320, this.screenRegion.y + 160,
				text(floor(nation.getTotalResourceAmount("inhabitants"))));
		// build token
		this.renderer.drawText(
				300,
				this.screenRegion.y + 12,
				"Available build token: " ~
				text(floor(nation.getTotalResourceAmount("structureToken"))));



		// year
		this.renderer.drawText(this.screenRegion.x + this.screenRegion.w - 240,
							    this.screenRegion.y + 160,
							    "Year " ~ text(this.client.getCurrentYear()));

		this.updateWidgets();

		foreach (Widget widget; this.widgets) {
			widget.render();
		}
	}
}
