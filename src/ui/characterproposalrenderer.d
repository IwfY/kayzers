module ui.characterproposalrenderer;

import std.conv;
import std.string;

import derelict.sdl2.sdl;

import constants;
import client;
import serverstub;
import ui.characterinforenderer;
import ui.renderer;
import ui.renderhelper;
import ui.widgetrenderer;
import ui.widgets.characterdetails;
import ui.widgets.characterinfo;
import ui.widgets.hbox;
import ui.widgets.image;
import ui.widgets.label;
import ui.widgets.labelbutton;
import ui.widgets.line;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import ui.widgets.vbox;
import world.character;
import world.nation;

class CharacterProposalRenderer : WidgetRenderer {
	private CharacterInfoRenderer charInfoRenderer;
	private const(Character) character;
	private bool active;
	private ServerStub serverStub;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private Image boxBackground;

	private CharacterDetails characterDetails;

	private Label proposalHead;
	private Line seperator;
	private VBox marryableCharacters;
	private LabelButton backButton;

	public this(Client client, RenderHelper renderer,
	            CharacterInfoRenderer charInfoRenderer, const(Character) character) {
		this.charInfoRenderer = charInfoRenderer;
		this.character = character;
		this.serverStub = this.client.getServerStub();

		super(client, renderer, "grey_a127");
		this.active = true;
	}

	private const(string) _(string text) const {
		return this.client.getI18nString(text);
	}

	private void callback(string message) {
		this.active = false;
	}

	private void proposalCallback(string message) {
		this.serverStub.sendProposal(this.character.getId(), to!(int)(message));
		this.active = false;
	}

	private void charInfoCallback(string message) {
		int charId = to!(int)(message);
		const(Character) character = this.serverStub.getCharacter(charId);
		this.charInfoRenderer.setCharacter(character);
		this.active = false;

	}


	protected override void initWidgets() {
		this.boxBackground = new Image(
			this.renderer, "bg_550_600",
			new SDL_Rect(0, 0, 550, 600));
		this.boxBackground.setZIndex(-1);
		this.addWidget(this.boxBackground);

		this.backButton = new LabelButton(
			this.renderer, "backButton", "button_100_28", "white_a10pc",
			new SDL_Rect(0, 0, 100, 28), &(this.callback), _("Back"));
		this.addWidget(this.backButton);

		// focus character
		this.characterDetails = new CharacterDetails(
			this.client, this.renderer, this.character);
		this.addWidget(this.characterDetails);

		this.proposalHead = new Label(this.renderer, _("Send proposal to:"));
		this.addWidget(this.proposalHead);
		this.seperator = new Line(this.renderer);
		this.addWidget(this.seperator);

		// marryable characters
		this.marryableCharacters = new VBox(this.renderer);

		foreach (const(Character) characterCursor;
		         this.serverStub.getMarryableCharacters(this.character.getId())) {
			LabelButton send = new LabelButton(
				this.renderer, text(characterCursor.getId()),
				"button_30_30", "white_a10pc", new SDL_Rect(0, 0, 30, 30),
				&this.proposalCallback, ">", "std_20");

			CharacterInfo charInfo = new CharacterInfo(
				this.client, this.renderer, characterCursor,
				&this.charInfoCallback, text(characterCursor.getId()));

			HBox hbox = new HBox(this.renderer);
			hbox.setMargin(15);
			hbox.addChild(send);
			hbox.addChild(charInfo);
			this.marryableCharacters.addChild(hbox);
		}
		this.addWidget(this.marryableCharacters);
	}


	protected override void updateWidgets() {
		this.boxX = this.screenRegion.x +
			(this.screenRegion.w - this.boxBackground.w()) / 2;
		this.boxY = this.screenRegion.y +
			(this.screenRegion.h - this.boxBackground.h()) / 2;

		this.boxBackground.setXY(this.boxX, this.boxY);
		this.backButton.setXY(this.boxX + 420, this.boxY + 550);

		// focus character
		this.characterDetails.setXY(this.boxX + 20, this.boxY + 20);

		this.proposalHead.setXY(this.boxX + 20, this.boxY + 90);
		this.seperator.setBounds(
			this.proposalHead.x() + this.proposalHead.w() + 10,
			this.proposalHead.y() + 12,
			this.boxBackground.w() - 40 - (this.proposalHead.w() + 10),
			0);

		// marryable characters
		this.marryableCharacters.setXY(
			this.boxX + 20, this.seperator.y() + 20);

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

