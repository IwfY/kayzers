module ui.characterproposalrenderer;

import std.string;

import derelict.sdl2.sdl;

import constants;
import client;
import ui.renderer;
import ui.renderhelper;
import ui.widgetrenderer;
import ui.widgets.characterdetails;
import ui.widgets.image;
import ui.widgets.label;
import ui.widgets.line;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import ui.widgets.vbox;
import world.character;
import world.nation;

class CharacterProposalRenderer : WidgetRenderer {
	private const(Character) character;
	private bool active;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private Image boxBackground;

	private CharacterDetails characterDetails;

	private Line seperator;
	private VBox marryableCharacters;

	public this(Client client, RenderHelper renderer, const(Character) character) {
		this.character = character;
		super(client, renderer, "grey_a127");
		this.active = true;
	}

	private const(string) _(string text) const {
		return this.client.getI18nString(text);
	}


	protected override void initWidgets() {
		this.boxBackground = new Image(
			this.renderer, "bg_550_600",
			new SDL_Rect(0, 0, 550, 600));
		this.boxBackground.setZIndex(-1);
		this.addWidget(this.boxBackground);

		// focus character
		this.characterDetails = new CharacterDetails(
			this.client, this.renderer, this.character);
		this.addWidget(this.characterDetails);

		this.seperator = new Line(this.renderer);
		this.addWidget(this.seperator);

		// marryable characters
		this.marryableCharacters = new VBox(this.renderer);

		foreach (const(Character) characterCursor;
		         this.client.getMarryableCharacters(this.character.getId())) {
			Label tmpLabel = new Label(
				this.renderer, characterCursor.getFullName());
			this.addWidget(tmpLabel);
			this.marryableCharacters.addChild(tmpLabel);
		}
		this.addWidget(this.marryableCharacters);
	}


	protected override void updateWidgets() {
		this.boxX = this.screenRegion.x +
			(this.screenRegion.w - this.boxBackground.getBounds().w) / 2;
		this.boxY = this.screenRegion.y +
			(this.screenRegion.h - this.boxBackground.getBounds().h) / 2;

		this.boxBackground.setXY(this.boxX,
		                         this.boxY);

		// focus character
		this.characterDetails.setXY(this.boxX + 20, this.boxY + 20);

		this.seperator.setBounds(
			this.boxX + 20, this.boxY + 102,
			this.boxBackground.getBounds().w - 40, 0);

		// marryable characters
		this.marryableCharacters.setXY(
			this.boxX + 20, this.seperator.getBounds().y + 20);

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
			// widgets
			super.handleEvent(event);

			// key press
			if (event.type == SDL_KEYDOWN) {
				// enter input
				if (event.key.keysym.sym == SDLK_ESCAPE) {
					this.active = false;
				}
			}
		}
	}
}

