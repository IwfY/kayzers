module ui.ui;

import client;
import constants;
import map;
import message;
import messagebroker;
import observer;
import position;
import rect;
import serverstub;
import utils;
import ui.ingamerenderer;
import ui.maprenderer;
import ui.minimap;
import ui.renderer;
import ui.renderhelper;
import ui.widgets.button;
import ui.widgets.clickwidgetdecorator;
import ui.widgets.image;
import ui.widgets.iwidget;
import ui.widgets.label;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import world.character;
import world.nation;
import world.nationprototype;
import world.resourcemanager;
import world.structure;
import world.structureprototype;

import derelict.sdl2.sdl;

import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
import std.string;

class UI : Renderer, Observer {
	private const(Map) map;
	private ServerStub serverStub;

	private IWidget[] widgets;
	private IWidget mouseOverWidget; // reference to widget under mouse
	private Button[string] structureButtons;
	private IWidget[string] structureButtonsDecorated;
	private IWidget renameButton;
	private Image tileImage;
	private Image structureImage;
	private Label yearLabel;
	private Label nationName;
	private RoundBorderImage nationFlag;
	private Label rulerLabel;
	private IWidget rulerLabelDecorated;
	private RoundBorderImage rulerImage;
	private IWidget rulerImageDecorated;
	private Image goldIcon;
	private Image inhabitantsIcon;

	private MapRenderer mapRenderer;
	private MiniMap miniMap;
	private InGameRenderer inGameRenderer;

	private MessageBroker messageBroker;


	public this(Client client, RenderHelper renderer,
				InGameRenderer inGameRenderer,
	            MapRenderer mapRenderer,
	            MessageBroker messageBroker) {
		super(client, renderer);
		this.serverStub = this.client.getServerStub();
		this.messageBroker = messageBroker;
		this.inGameRenderer = inGameRenderer;
		this.mapRenderer = mapRenderer;
		this.map = this.serverStub.getMap();

		this.initWidgets();

		this.messageBroker.register(this, "nationChanged");
	}


	public ~this() {
		this.messageBroker.unregister(this, "nationChanged");
	}


	public override void notify(const(Message) message) {
		// active nation changed
		if (message.text == "nationChanged") {
			// nation flag and name
			const(Nation) nation = this.serverStub.getCurrentNation();
			this.nationName.setText(nation.getName());
			this.nationFlag.setTextureName(
				nation.getPrototype().getFlagImageName());

			// ruler
			const(Character) ruler = nation.getRuler();
			this.rulerLabel.setText(ruler.getFullName());
			if (ruler.getSex() == Sex.MALE) {
				this.rulerImage.setTextureName("portrait_male");
			} else {
				this.rulerImage.setTextureName("portrait_female");
			}

			// year
			this.yearLabel.setText(
				_("Year ") ~ text(this.serverStub.getCurrentYear()));
		}
	}


	private const(string) _(string text) const {
		return this.client.getI18nString(text);
	}


	public void initWidgets() {
		// structure buttons
		foreach (const StructurePrototype structurePrototype;
				 this.serverStub.getStructurePrototypes()) {
			Button button = new Button(
				this.renderer,
				structurePrototype.getName(),
				structurePrototype.getIconImageName(),
				NULL_TEXTURE,
				&this.addStructureHandler,
				new SDL_Rect(0, 0, 35, 35));

			IWidget decoratedButton = new PopupWidgetDecorator(
				button,
				this.renderer,
				structurePrototype.getPopupText(),
				"ui_popup_background");

			this.structureButtons[structurePrototype.getIconImageName()] =
				button;
			this.structureButtonsDecorated[structurePrototype.getIconImageName()] =
				decoratedButton;
			this.widgets ~= decoratedButton;
		}

		// selected structure and tile display
		this.tileImage = new Image(this.renderer, NULL_TEXTURE, new SDL_Rect(0, 0, 20, 20));
		this.widgets ~= this.tileImage;
		this.structureImage = new Image(this.renderer, NULL_TEXTURE, new SDL_Rect(0, 0, 20, 20));
		this.widgets ~= this.structureImage;

		// rename button
		Button tmpButton = new Button(
			this.renderer,
			"rename",
			"button_rename",
			"white_a10pc",
			&this.renameStructureHandler,
			new SDL_Rect(0, 0, 11, 11));

		this.renameButton = new PopupWidgetDecorator(
				tmpButton,
				this.renderer,
				_("Rename"),
				"ui_popup_background");
		this.widgets ~= this.renameButton;


		// nation flag and label
		this.nationName = new Label(this.renderer, "");
		this.widgets ~= this.nationName;

		this.nationFlag = new RoundBorderImage(
			this.renderer, NULL_TEXTURE, new SDL_Rect(0, 0, 30, 30));
		this.widgets ~= this.nationFlag;

		// year
		this.yearLabel = new Label(this.renderer, "");
		this.widgets ~= this.yearLabel;

		// ruler
		this.rulerLabel = new Label(this.renderer, "");
		this.rulerLabelDecorated = new ClickWidgetDecorator(
			this.rulerLabel, "ruler", &this.buttonHandler);
		this.widgets ~= this.rulerLabelDecorated;

		this.rulerImage = new RoundBorderImage(
			this.renderer, NULL_TEXTURE, new SDL_Rect(0, 0, 30, 30));
		this.rulerImageDecorated = new ClickWidgetDecorator(
			this.rulerImage, "ruler", &this.buttonHandler);
		this.widgets ~= this.rulerImageDecorated;

		// resources
		this.goldIcon = new Image(
			this.renderer, "gold", new SDL_Rect(0, 0, 18, 18));
		this.widgets ~= this.goldIcon;

		this.inhabitantsIcon = new Image(
			this.renderer, "inhabitants", new SDL_Rect(0, 0, 18, 18));
		this.widgets ~= this.inhabitantsIcon;


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
					this.serverStub.getStructure(selectedPosition.i,
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
					if (structure.getNation() == this.serverStub.getCurrentNation() &&
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
		foreach(IWidget button; this.structureButtonsDecorated.values) {
			button.setXY(structureButtonX, structureButtonY);
			structureButtonX += 45;
		}

		// nation flag and label
		this.nationName.setXY(
			this.screenRegion.x + 44, this.screenRegion.y + 160);
		this.nationFlag.setXY(
			this.screenRegion.x + 10, this.screenRegion.y + 145);

		this.yearLabel.setXY(this.screenRegion.x + this.screenRegion.w - 240,
		                     this.screenRegion.y + 160);

		// ruler
		this.rulerImageDecorated.setXY(this.screenRegion.x + 470,
									   this.screenRegion.y + 145);
		this.rulerLabelDecorated.setXY(this.screenRegion.x + 504,
									   this.screenRegion.y + 160);

		// resource icons
		this.goldIcon.setXY(
			this.screenRegion.x + 200, this.screenRegion.y + 160);
		this.inhabitantsIcon.setXY(
			this.screenRegion.x + 300, this.screenRegion.y + 160);

		// minimap
		this.miniMap.setScreenRegion(
			this.screenRegion.x + this.screenRegion.w - 170,
			this.screenRegion.y + 10,
			160, 160);
	}


	private void buttonHandler(string message) {
		if (message == "ruler") {
			const(Nation) nation = this.serverStub.getCurrentNation();
			const(Character) ruler = nation.getRuler();
			this.inGameRenderer.startCharacterInfoRenderer(ruler);
		}
	}


	public void addStructureHandler(string structureName) {
		bool success = this.serverStub.addStructure(
			structureName,
			this.serverStub.getCurrentNation(),
			this.mapRenderer.getSelectedPosition());

		if (success) {
			const(Structure) newStructure = this.serverStub.getStructure(
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
		const(Structure) structure = this.serverStub.getStructure(
			this.mapRenderer.getSelectedPosition().i,
			this.mapRenderer.getSelectedPosition().j);
		// name nameable structures
		if (structure !is null) {
			if (structure.getPrototype().isNameable() &&
					structure.getNation() == this.serverStub.getCurrentNation()) {
				this.inGameRenderer.startStructureNameRenderer(structure);
			}
		}
	}

	/**
	 * grey out buttons for structures that can't be built
	 **/
	public void updateStructureButtonBuildable() {
		const(Nation) currentNation = this.serverStub.getCurrentNation();
		const(Position) position = this.mapRenderer.getSelectedPosition();
		foreach (string buttonImageName, Button button;
				 this.structureButtons) {
			bool buildable = this.serverStub.canBuildStructure(
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
		foreach (IWidget widget;
				 sort!(IWidget.zIndexSortDesc)(this.widgets)) {
			widget.handleEvent(event);
		}

		// key press
		if (event.type == SDL_KEYDOWN) {
			// end turn
			if (event.key.keysym.sym == SDLK_RETURN) {
				this.serverStub.endTurn();
			}
		}

		// mini map
		this.miniMap.handleEvent(event);
	}


	public override void render(int tick=0) {
		this.updateStructureButtonBuildable();

		this.renderer.drawTexture(0, this.screenRegion.y, "ui_background");

		// ruler portrait and name
		const(Nation) nation = this.serverStub.getCurrentNation();

		// resource text
		string resourceString;
		const(ResourceManager) resources = nation.getResources();

		// gold
		this.renderer.drawText(
				220, this.screenRegion.y + 160,
				text(floor(resources.getResourceAmount("gold"))));
		// inhabitants
		this.renderer.drawText(
				320, this.screenRegion.y + 160,
				text(floor(nation.getTotalResourceAmount("inhabitants"))));
		// build token
		this.renderer.drawText(
				300,
				this.screenRegion.y + 12,
				_("Available build token: ") ~
				text(floor(nation.getTotalResourceAmount("structureToken"))));


		this.updateWidgets();

		foreach (IWidget widget;
				 sort!(IWidget.zIndexSort)(this.widgets)) {
			widget.render();
		}

		this.miniMap.render();
	}
}
