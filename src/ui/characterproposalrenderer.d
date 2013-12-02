module ui.characterproposalrenderer;

import std.string;

import derelict.sdl2.sdl;

import constants;
import client;
import ui.renderer;
import ui.renderhelper;
import ui.widgetrenderer;
import ui.widgets.hbox;
import ui.widgets.image;
import ui.widgets.label;
import ui.widgets.line;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import ui.widgets.vbox;
import ui.widgets.widgetinterface;
import world.character;
import world.nation;

class CharacterProposalRenderer : WidgetRenderer {
	private const(Character) character;
	private bool active;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private Image boxBackground;
	private Label characterNameLabel;
	private Label characterRulerLabel;
	private WidgetInterface characterDynasty;
	private WidgetInterface characterSex;
	private WidgetInterface characterAge;
	private HBox characterRulingNations;
	private WidgetInterface seperator;
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
			this.renderer, "", "bg_550_600",
			new SDL_Rect(0, 0, 550, 600));
		this.boxBackground.setZIndex(-1);
		this.addWidget(this.boxBackground);

		// focus character
		this.characterNameLabel = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 0, 0),
			this.character.getFullName(),
			"std_20");
		this.addWidget(this.characterNameLabel);

		WidgetInterface tmpWidget = new RoundBorderImage(
			this.renderer,
			"",
			this.character.getDynasty().getFlagImageName(),
			new SDL_Rect());
		this.characterDynasty = new PopupWidgetDecorator(
			tmpWidget,
			this.renderer, this.character.getDynasty().getName(),
			"ui_popup_background" );
		this.characterDynasty.setZIndex(2);
		this.addWidget(this.characterDynasty);

		this.characterSex = new RoundBorderImage(
			this.renderer,
			"",
			NULL_TEXTURE);
		if (this.character.getSex() == Sex.MALE) {
			this.characterSex.setTextureName("portrait_male");
		} else {
			this.characterSex.setTextureName("portrait_female");
		}
		this.addWidget(this.characterSex);

		tmpWidget = new Label(
			this.renderer,
			"",
			NULL_TEXTURE,
			new SDL_Rect(),
			format("%s: %d%s",
		       _("Age"),
		       this.character.getAge(this.client.getCurrentYear()),
		       (this.character.isDead() ? " ✝" : "")));

		string popupText = format("%s: %d", _("Born"),
		                          this.character.getBirth());
		if (this.character.isDead()) {
			popupText ~= format("\n%s: %d", _("Death"),
			                    this.character.getDeath());
		}
		this.characterAge = new PopupWidgetDecorator(
			tmpWidget,
			this.renderer,
			popupText,
			"ui_popup_background");
		this.characterAge.setZIndex(3);
		this.addWidget(this.characterAge);

		// ruling nations
		this.characterRulerLabel = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 0, 0),
			_("Ruler of") ~ ":");
		this.addWidget(this.characterRulerLabel);

		this.characterRulingNations = new HBox(this.renderer, "", NULL_TEXTURE, new SDL_Rect());

		foreach (const(Nation) nation; this.client.getNations()) {
			if (this.character == nation.getRuler()) {
				WidgetInterface tmpNationWidget = new RoundBorderImage(
					this.renderer,
					"",
					nation.getPrototype().getFlagImageName());
				WidgetInterface nationFlag = new PopupWidgetDecorator(
					tmpNationWidget,
					this.renderer,
					nation.getName(),
					"ui_popup_background");
				nationFlag.setZIndex(4);
				this.characterRulingNations.addChild(nationFlag);
				this.addWidget(nationFlag);
			}
		}

		this.seperator = new Line(this.renderer, "");
		this.addWidget(this.seperator);

		// marryable characters
		this.marryableCharacters = new VBox(
			this.renderer, "", NULL_TEXTURE, new SDL_Rect(0, 0, 0, 0));

		foreach (const(Character) characterCursor;
		         this.client.getMarryableCharacters(this.character.getId())) {
			Label tmpLabel = new Label(
				this.renderer, "", NULL_TEXTURE, new SDL_Rect(), characterCursor.getFullName());
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
		this.characterDynasty.setXY(this.boxX + 20, this.boxY + 20);
		this.characterSex.setXY(this.boxX + 60, this.boxY + 20);
		this.characterNameLabel.setXY(this.boxX + 100, this.boxY + 23);
		this.characterAge.setXY(this.boxX + 100, this.boxY + 54);
		this.characterRulerLabel.setXY(this.boxX + 180, this.boxY + 54);

		int nationStartX = this.characterRulerLabel.getBounds().x +
			this.characterRulerLabel.getBounds().w + 10;
		this.characterRulingNations.setXY(nationStartX, this.boxY + 50);

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

