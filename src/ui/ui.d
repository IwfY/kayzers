module ui.ui;

import client;
import constants;
import map;
import position;
import rect;
import utils;
import ui.widgets.button;
import ui.widgets.image;
import ui.ingamerenderer;
import ui.maprenderer;
import ui.minimap;
import ui.renderer;
import ui.renderhelper;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.widgetinterface;
import world.character;
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
	private WidgetInterface[] widgets;
	private WidgetInterface mouseOverWidget; // reference to widget under mouse
	private WidgetInterface[string] structureButtons;
	private WidgetInterface renameButton;
	private Image tileImage;
	private Image structureImage;
	private MapRenderer mapRenderer;
	private MiniMap miniMap;
	private InGameRenderer inGameRenderer;


	public this(Client client, RenderHelper renderer,
				InGameRenderer inGameRenderer,
				MapRenderer mapRenderer) {
		super(client, renderer);
		this.inGameRenderer = inGameRenderer;
		this.mapRenderer = mapRenderer;
		this.map = this.client.getMap();

		this.initWidgets();
	}

	private const(string) _(string text) const {
		return this.client.getI18nString(text);
	}


	public void initWidgets() {
		// structure buttons
		foreach (const StructurePrototype structurePrototype;
				 this.client.getStructurePrototypes()) {
			Button button = new Button(
					this.renderer,
					structurePrototype.getName(),
					structurePrototype.getIconImageName(),
					NULL_TEXTURE,
					new SDL_Rect(0, 0, 35, 35),
					&this.addStructureHandler);

			WidgetInterface decoratedButton = new PopupWidgetDecorator(
				button,
				this.renderer,
				structurePrototype.getPopupText(),
				"ui_popup_background");

			this.structureButtons[structurePrototype.getIconImageName()] =
				decoratedButton;
			this.widgets ~= decoratedButton;
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

		// rename button
		Button tmpButton = new Button(
			this.renderer,
			"rename",
			"button_rename",
			"white_a10pc",
			new SDL_Rect(0, 0, 11, 11),
			&this.renameStructureHandler);

		this.renameButton = new PopupWidgetDecorator(
				tmpButton,
				this.renderer,
				_("Rename"),
				"ui_popup_background");
		this.widgets ~= this.renameButton;

		// mini map
		this.miniMap = new MiniMap(this.client, this.renderer,
								   this.mapRenderer);
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
					// rename button
					if (structure.getNation() == this.client.getCurrentNation() &&
							prototype.isNameable()) {
						this.renameButton.unhide();
						this.renameButton.setXY(this.screenRegion.x + 20,
						                        this.screenRegion.y + 24);

					} else {
						this.renameButton.hide();
					}
					// structure name
					this.renderer.drawText(this.screenRegion.x + 35,
					                       this.screenRegion.y + 22,
					                       structure.getNameString());
				} else {
					this.renameButton.hide();
					this.structureImage.setTextureName(NULL_TEXTURE);
				}
			} else {
				this.renameButton.hide();
				this.tileImage.setTextureName(NULL_TEXTURE);
				this.structureImage.setTextureName(NULL_TEXTURE);
			}
		}

		// structure buttons
		int structureButtonX = 300;
		int structureButtonY = this.screenRegion.y + 30;
		foreach(WidgetInterface button; this.structureButtons.values) {
			button.setXY(structureButtonX, structureButtonY);
			structureButtonX += 45;
		}

		// minimap
		this.miniMap.setScreenRegion(
			this.screenRegion.x + this.screenRegion.w - 170,
			this.screenRegion.y + 10,
			160, 160);
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


	public void renameStructureHandler(string message) {
		const(Structure) structure = this.client.getStructure(
			this.mapRenderer.getSelectedPosition().i,
			this.mapRenderer.getSelectedPosition().j);
		// name nameable structures
		if (structure !is null) {
			if (structure.getPrototype().isNameable() &&
					structure.getNation() == this.client.getCurrentNation()) {
				this.inGameRenderer.startStructureNameRenderer(structure);
			}
		}
	}

	/**
	 * grey out buttons for structures that can't be built
	 **/
	public void updateStructureButtonBuildable() {
		const(Nation) currentNation = this.client.getCurrentNation();
		const(Position) position = this.mapRenderer.getSelectedPosition();
		foreach (string buttonImageName, WidgetInterface button;
				 this.structureButtons) {
			bool buildable = this.client.canBuildStructure(
				button.getName(),
				currentNation,
				position);

			if (buildable) {
				button.setTextureName(buttonImageName);
			} else {
				button.setTextureName(buttonImageName ~ "_grey");
			}
		}
	}


	public override void handleEvent(SDL_Event event) {
		// left mouse down
		if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_LEFT) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			foreach (WidgetInterface widget; this.widgets) {
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
			foreach (WidgetInterface widget; this.widgets) {
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
		// key press
		else if (event.type == SDL_KEYDOWN) {
			// end turn
			if (event.key.keysym.sym == SDLK_RETURN) {
				this.client.endTurn();
			}
		}

		// mini map
		this.miniMap.handleEvent(event);
	}


	public override void render(int tick=0) {
		this.updateStructureButtonBuildable();

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

		// ruler portrait and name
		const(Character) ruler = nation.getRuler();
		if (ruler.getSex() == Sex.MALE) {
			this.renderer.drawTexture(
				this.screenRegion.x + 471, this.screenRegion.y + 144,
				"portrait_male");

		} else {
			this.renderer.drawTexture(
				this.screenRegion.x + 471, this.screenRegion.y + 144,
				"portrait_female");
		}
		this.renderer.drawTexture(this.screenRegion.x + 470,
								  this.screenRegion.y + 143,
								  "border_round_30");
		this.renderer.drawText(this.screenRegion.x + 504,
							   this.screenRegion.y + 160,
							   ruler.getName());

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
				_("Available build token: ") ~
				text(floor(nation.getTotalResourceAmount("structureToken"))));



		// year
		this.renderer.drawText(this.screenRegion.x + this.screenRegion.w - 240,
							    this.screenRegion.y + 160,
							    _("Year ") ~ text(this.client.getCurrentYear()));


		this.updateWidgets();

		foreach (WidgetInterface widget; this.widgets) {
			widget.render();
		}

		this.miniMap.render();
	}
}
