module ui.characterinforenderer;

import client;
import constants;
import textinput;
import ui.renderhelper;
import ui.widgetrenderer;
import ui.widgets.image;
import ui.widgets.label;
import ui.widgets.labelbutton;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import ui.widgets.widget;
import ui.widgets.widgetinterface;
import world.character;
import world.nation;

import derelict.sdl2.sdl;

import std.string;
import std.typecons;

class CharacterInfoRenderer : WidgetRenderer {
	private Rebindable!(const(Character)) character;

	private bool active;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private Label characterName;
	private Label characterRulerLabel;
	private WidgetInterface characterAge;
	private RoundBorderImage characterDynasty;
	private RoundBorderImage characterSex;
	private WidgetInterface[] characterRulingNations;

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


	private const(string) _(string text) const {
		return this.client.getI18nString(text);
	}


	private void setCharacter(const(Character) character) {
		this.character = character;
		this.initWidgets();
	}



	protected override void initWidgets() {
		this.allWidgets.length = 0;	// clear list of old widgets
		this.characterRulingNations.length = 0;

		this.boxBackground = new Image(
			this.renderer, "", "bg_550_400",
			new SDL_Rect(0, 0, 550, 400));
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

		// focus character
		this.characterName = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 0, 0),
			this.character.getFullName(),
			"std_20");
		this.allWidgets ~= this.characterName;

		this.characterDynasty = new RoundBorderImage(
			this.renderer,
			"",
			this.character.getDynasty().getFlagImageName(),
			new SDL_Rect());
		this.allWidgets ~= this.characterDynasty;

		this.characterSex = new RoundBorderImage(
			this.renderer,
			"",
			NULL_TEXTURE,
			new SDL_Rect());
		if (this.character.getSex() == Sex.MALE) {
			this.characterSex.setTextureName("portrait_male");
		} else {
			this.characterSex.setTextureName("portrait_female");
		}
		this.allWidgets ~= this.characterSex;

		WidgetInterface tmpWidget = new Label(
			this.renderer,
			"",
			NULL_TEXTURE,
			new SDL_Rect(),
			format("%s: %d", _("Age"),
				   this.character.getAge(this.client.getCurrentYear())));

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
		this.allWidgets ~= this.characterAge;

		// ruling nations
		this.characterRulerLabel = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 0, 0),
			_("Ruler of") ~ ":");
		this.allWidgets ~= this.characterRulerLabel;

		foreach (const(Nation) nation; this.client.getNations()) {
			if (this.character == nation.getRuler()) {
				WidgetInterface tmpNationWidget = new RoundBorderImage(
					this.renderer,
					"",
					nation.getPrototype().getFlagImageName(),
					new SDL_Rect());
				WidgetInterface nationFlag = new PopupWidgetDecorator(
					tmpNationWidget,
					this.renderer,
					nation.getName(),
					"ui_popup_background");
				this.characterRulingNations ~= nationFlag;
				this.allWidgets ~= nationFlag;
			}
		}

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

		// focus character
		this.characterDynasty.setXY(this.boxX + 20, this.boxY + 20);
		this.characterSex.setXY(this.boxX + 60, this.boxY + 20);
		this.characterName.setXY(this.boxX + 100,
								 this.boxY + 23);
		this.characterAge.setXY(this.boxX + 100, this.boxY + 54);
		this.characterRulerLabel.setXY(this.boxX + 200, this.boxY + 54);

		int nationStartX = this.characterRulerLabel.getBounds().x +
			this.characterRulerLabel.getBounds().w + 10;
		foreach (WidgetInterface widget; this.characterRulingNations) {
			widget.setXY(nationStartX, this.boxY + 50);
			nationStartX += 40;
		}

		this.okButton.setXY(this.boxX + 420,
		                    this.boxY + 350);
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

