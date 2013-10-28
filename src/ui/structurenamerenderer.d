module ui.structurenamerenderer;

import client;
import constants;
import textinput;
import ui.image;
import ui.inputbox;
import ui.label;
import ui.labelbutton;
import ui.renderhelper;
import ui.widget;
import ui.widgetrenderer;
import world.structure;

import derelict.sdl2.sdl;

import std.string;

class StructureNameRenderer : WidgetRenderer {
	private const(Structure) structure;

	private bool active;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private Label label;
	private InputBox inputBox;
	private LabelButton okButton;
	private Image boxBackground;
	private TextInput textInputServer;
	private string inputString;

	public this(Client client, RenderHelper renderer,
				const(Structure) structure) {
		this.textInputServer = new TextInput();
		this.structure = structure;

		super(client, renderer, "grey_a127");

		this.active = true;
		this.inputBox.click();	// activate text input
	}


	public ~this() {
		destroy(this.textInputServer);
	}


	protected override void initWidgets() {
		this.boxBackground = new Image(
			this.renderer, "", "bg_300_140",
			new SDL_Rect(0, 0, 300, 140));
		this.boxBackground.setZIndex(-1);
		this.allWidgets ~= this.boxBackground;

		this.inputBox = new InputBox(
			this.renderer, this.textInputServer,
			"inputBox",
			"inputbox_260_30",
			new SDL_Rect(0, 0, 260, 30),
			STD_FONT);
		this.allWidgets ~= this.inputBox;

		this.inputBox.setTextPointer(&this.inputString);

		this.okButton = new LabelButton(
			this.renderer,
			"okButton",
			"button_100_28",
			"white_a10pc",
			new SDL_Rect(0, 0, 100, 28),
			&(this.okButtonCallback),
			"OK",
			STD_FONT);
		this.allWidgets ~= this.okButton;

		this.label = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 280, 25),
			format("Name your %s:", this.structure.getPrototype().getName()),
			STD_FONT);
		this.allWidgets ~= this.label;
	}


	private void okButtonCallback(string message) {
		this.client.setStructureName(this.structure, this.inputString);
		this.active = false;
	}


	protected override void updateWidgets() {
		this.boxX = this.screenRegion.x + (this.screenRegion.w - 300) / 2;
		this.boxY = this.screenRegion.y + (this.screenRegion.h - 140) / 2;

		this.boxBackground.setXY(this.boxX,
		                         this.boxY);
		this.label.setXY(this.boxX + 20,
		                 this.boxY + 20);
		this.inputBox.setXY(this.boxX + 20,
		                    this.boxY + 50);
		this.okButton.setXY(this.boxX + 180,
		                    this.boxY + 90);
	}


	public override void render(int tick=0) {
		if (this.active) {
			super.render(tick);
		}
	}


	public bool isActive() {
		return this.active;
	}

	public override void handleEvent(SDL_Event event) {
		if (this.active) {
			// text input
			this.textInputServer.handleEvent(event);

			// widgets
			super.handleEvent(event);

			// key press
			if (event.type == SDL_KEYDOWN) {
				// enter input
				if (event.key.keysym.sym == SDLK_RETURN) {
					this.okButtonCallback("");
				}
			}
		}
	}
}

