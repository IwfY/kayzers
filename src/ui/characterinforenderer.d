module ui.characterinforenderer;

import client;
import constants;
import textinput;
import ui.widgets.image;
import ui.widgets.label;
import ui.widgets.labelbutton;
import ui.renderhelper;
import ui.widgets.widget;
import ui.widgetrenderer;
import world.character;

import derelict.sdl2.sdl;

import std.string;
import std.typecons;

class CharacterInfoRenderer : WidgetRenderer {
	private Rebindable!(const(Character)) character;

	private bool active;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private Label label;
	private LabelButton okButton;
	private TextInput textInputServer;
	private Image boxBackground;
	private string inputString;

	public this(Client client, RenderHelper renderer,
	            const(Character) character) {
		this.textInputServer = new TextInput();
		this.character = character;

		super(client, renderer, "grey_a127");	// calls initWidgets

		this.active = true;
	}


	public ~this() {
		destroy(this.textInputServer);
	}


	private void setCharacter(const(Character) character) {
		this.character = character;
	}



	protected override void initWidgets() {
		this.boxBackground = new Image(
			this.renderer, "", "bg_300_140",
			new SDL_Rect(0, 0, 500, 400));
		this.boxBackground.setZIndex(-1);
		this.allWidgets ~= this.boxBackground;

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
			this.character.getFullName(),
			STD_FONT);
		this.allWidgets ~= this.label;
	}


	private void okButtonCallback(string message) {
		this.active = false;
	}

	private void characterButtonCallback(string message) {
	}


	protected override void updateWidgets() {
		this.boxX = this.screenRegion.x +
			(this.screenRegion.w - this.boxBackground.getBounds().w) / 2;
		this.boxY = this.screenRegion.y +
			(this.screenRegion.h - this.boxBackground.getBounds().h) / 2;

		this.boxBackground.setXY(this.boxX,
		                         this.boxY);
		this.label.setXY(this.boxX + 20,
		                 this.boxY + 20);
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

