module ui.characterinforenderer;

import client;
import constants;
import textinput;
import ui.renderhelper;
import ui.widgetrenderer;
import ui.widgets.clickwidgetdecorator;
import ui.widgets.image;
import ui.widgets.label;
import ui.widgets.labelbutton;
import ui.widgets.line;
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

	private Label parentsHead;
	private Line seperator1;
	private WidgetInterface fatherName;
	private WidgetInterface fatherDynasty;
	private WidgetInterface fatherSex;
	private WidgetInterface motherName;
	private WidgetInterface motherDynasty;
	private WidgetInterface motherSex;

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


	private void buttonHandler(string message) {
		if (message == "father") {
			const(Character) father = this.character.getFather();
			if (father !is null) {
				this.setCharacter(father);
			}
		} else if (message == "mother") {
			const(Character) mother = this.character.getMother();
			if (mother !is null) {
				this.setCharacter(mother);
			}
		} else if (message == "partner") {
			const(Character) partner = this.character.getPartner();
			if (partner !is null) {
				this.setCharacter(partner);
			}
		}
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

		this.initWidgetsParents();
	}


	private void initWidgetsParents() {
		// header
		this.parentsHead = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 0, 0),
			_("Parents"));
		this.allWidgets ~= this.parentsHead;

		this.seperator1 = new Line(this.renderer, "", new SDL_Rect(0, 0, 0, 0));
		this.allWidgets ~= this.seperator1;

		// father
		const(Character) father = this.character.getFather();
		WidgetInterface tmpWidget = new RoundBorderImage(
			this.renderer, "father", "portrait_male", new SDL_Rect());
		this.fatherSex = new ClickWidgetDecorator(
			tmpWidget, &this.buttonHandler);
		this.allWidgets ~= this.fatherSex;

		// father found
		if (father !is null) {
			tmpWidget = new Label(
				this.renderer, "father", NULL_TEXTURE,
				new SDL_Rect(), father.getName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);

			string popupText = format("%s: %d%s",
			   _("Age"),
			   father.getAge(this.client.getCurrentYear()),
			   (father.isDead() ? " ✝" : ""));
			this.fatherName = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, popupText, "ui_popup_background");
			this.allWidgets ~= this.fatherName;

			tmpWidget = new RoundBorderImage(
				this.renderer, "father", father.getDynasty.getFlagImageName(),
				new SDL_Rect());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.fatherDynasty = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, father.getDynasty().getName(),
				"ui_popup_background");
			this.allWidgets ~= this.fatherDynasty;
		}
		// father unknown
		else {
			tmpWidget = new Label(
				this.renderer, "father", NULL_TEXTURE,
				new SDL_Rect(), _("unknown"));
			this.fatherName = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.allWidgets ~= this.fatherName;

			tmpWidget = new RoundBorderImage(
				this.renderer, "father", NULL_TEXTURE, new SDL_Rect());
			tmpWidget.hide();
			this.fatherDynasty = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.allWidgets ~= this.fatherDynasty;
		}

		// mother
		const(Character) mother = this.character.getMother();
		tmpWidget = new RoundBorderImage(
			this.renderer, "mother", "portrait_female", new SDL_Rect());
		this.motherSex = new ClickWidgetDecorator(
			tmpWidget, &this.buttonHandler);
		this.allWidgets ~= this.motherSex;

		// mother found
		if (mother !is null) {
			tmpWidget = new Label(
				this.renderer, "mother", NULL_TEXTURE,
				new SDL_Rect(), mother.getName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);

			string popupText = format("%s: %d%s",
			   _("Age"),
			   mother.getAge(this.client.getCurrentYear()),
			   (mother.isDead() ? " ✝" : ""));
			this.motherName = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, popupText, "ui_popup_background");
			this.allWidgets ~= this.motherName;

			tmpWidget = new RoundBorderImage(
				this.renderer, "mother", mother.getDynasty.getFlagImageName(),
				new SDL_Rect());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.motherDynasty = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, mother.getDynasty().getName(),
				"ui_popup_background");
			this.allWidgets ~= this.motherDynasty;
		}
		// mother unknown
		else {
			tmpWidget = new Label(
				this.renderer, "mother", NULL_TEXTURE,
				new SDL_Rect(), _("unknown"));
			this.motherName = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.allWidgets ~= this.motherName;

			tmpWidget = new RoundBorderImage(
				this.renderer, "mother", NULL_TEXTURE, new SDL_Rect());
			tmpWidget.hide();
			this.motherDynasty = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.allWidgets ~= this.motherDynasty;
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
		this.characterRulerLabel.setXY(this.boxX + 180, this.boxY + 54);

		int nationStartX = this.characterRulerLabel.getBounds().x +
			this.characterRulerLabel.getBounds().w + 10;
		foreach (WidgetInterface widget; this.characterRulingNations) {
			widget.setXY(nationStartX, this.boxY + 50);
			nationStartX += 40;
		}

		// parents
		this.parentsHead.setXY(this.boxX + 20, this.boxY + 90);
		this.seperator1.setBounds(
			this.parentsHead.getBounds().x + this.parentsHead.getBounds().w + 10,
			this.parentsHead.getBounds().y + 12,
			this.boxBackground.getBounds().w - 40 - (this.parentsHead.getBounds().w + 10),
			0);

		this.fatherDynasty.setXY(
			this.boxX + 20, this.seperator1.getBounds().y + 20);
		this.fatherSex.setXY(
			this.boxX + 60, this.seperator1.getBounds().y + 20);
		this.fatherName.setXY(
			this.boxX + 100, this.seperator1.getBounds().y + 28);
		this.motherDynasty.setXY(
			this.boxX + (this.boxBackground.getBounds().w / 2) + 20,
			this.seperator1.getBounds().y + 20);
		this.motherSex.setXY(
			this.boxX + (this.boxBackground.getBounds().w / 2) + 60,
			this.seperator1.getBounds().y + 20);
		this.motherName.setXY(
			this.boxX + (this.boxBackground.getBounds().w / 2) + 100,
			this.seperator1.getBounds().y + 28);

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

