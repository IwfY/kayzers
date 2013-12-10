module ui.characternamerenderer;

import client;
import constants;
import textinput;

import ui.renderhelper;
import ui.widgetrenderer;

import ui.widgets.image;
import ui.widgets.inputbox;
import ui.widgets.iwidget;
import ui.widgets.label;
import ui.widgets.labelbutton;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import ui.widgets.widget;

import world.character;


import derelict.sdl2.sdl;

import std.string;

class CharacterNameRenderer : WidgetRenderer {
	private const(Character) character;

	private bool active;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private Label label;
	private InputBox inputBox;
	private LabelButton okButton;
	private Image boxBackground;

	private IWidget characterSex;
	private IWidget characterDynasty;
	private IWidget fatherName;
	private IWidget fatherDynasty;
	private IWidget motherName;
	private IWidget motherDynasty;

	private TextInput textInputServer;
	private string inputString;

	public this(Client client, RenderHelper renderer,
	            const(Character) character) {
		this.textInputServer = new TextInput();
		this.character = character;

		super(client, renderer, "grey_a127");	// calls initWidgets

		this.active = true;
		this.inputBox.click();	// activate text input
	}


	public ~this() {
		destroy(this.textInputServer);
	}

	private const(string) _(string text) const {
		return this.client.getI18nString(text);
	}


	protected override void initWidgets() {
		this.boxBackground = new Image(
			this.renderer, "bg_350_230", new SDL_Rect(0, 0, 350, 230));
		this.boxBackground.setZIndex(-1);
		this.addWidget(this.boxBackground);

		this.inputBox = new InputBox(
			this.renderer, this.textInputServer,
			"inputbox_230_30",
			new SDL_Rect(0, 0, 230, 30),
			STD_FONT);
		this.addWidget(this.inputBox);

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
		this.addWidget(this.okButton);

		this.label = new Label(
			this.renderer,
			format(_("celebrate the birth of a %s.\n%s name shall be:"),
				   (this.character.getSex() == Sex.MALE ?
						_("son") : _("daughter")),
					(this.character.getSex() == Sex.MALE ?
						_("His") : _("Her"))),
			STD_FONT);
		this.addWidget(this.label);

		// father
		const(Character) father = this.character.getFather();
		this.fatherName = new Label(
			this.renderer, father.getFullName());
		this.addWidget(this.fatherName);

		IWidget tmpWidget = new RoundBorderImage(
			this.renderer, father.getDynasty.getFlagImageName());
		this.fatherDynasty = new PopupWidgetDecorator(
			tmpWidget,
			this.renderer, father.getDynasty().getName(),
			"ui_popup_background");
		this.fatherDynasty.setZIndex(2);
		this.addWidget(this.fatherDynasty);

		// mother
		const(Character) mother = this.character.getMother();
		this.motherName = new Label(
			this.renderer, mother.getFullName());
		this.addWidget(this.motherName);

		tmpWidget = new RoundBorderImage(
			this.renderer, mother.getDynasty.getFlagImageName());
		this.motherDynasty = new PopupWidgetDecorator(
			tmpWidget,
			this.renderer, mother.getDynasty().getName(),
			"ui_popup_background");
		this.motherDynasty.setZIndex(3);
		this.addWidget(this.motherDynasty);

		// character
		tmpWidget = new RoundBorderImage(
			this.renderer, character.getDynasty.getFlagImageName());
		this.characterDynasty = new PopupWidgetDecorator(
			tmpWidget,
			this.renderer, character.getDynasty().getName(),
			"ui_popup_background");
		this.characterDynasty.setZIndex(4);
		this.addWidget(this.characterDynasty);

		this.characterSex = new RoundBorderImage(
			this.renderer,
			(this.character.getSex() == Sex.MALE) ?
				"portrait_male" : "portrait_female");
		this.characterSex.setZIndex(4);
		this.addWidget(this.characterSex);
	}


	private void okButtonCallback(string message) {
		this.client.setCharacterName(this.character, this.inputString);
		this.active = false;
	}


	protected override void updateWidgets() {
		this.boxX = this.screenRegion.x + (this.screenRegion.w - 350) / 2;
		this.boxY = this.screenRegion.y + (this.screenRegion.h - 230) / 2;

		this.boxBackground.setXY(this.boxX, this.boxY);

		this.fatherDynasty.setXY(this.boxX + 20, this.boxY + 20);
		this.fatherName.setXY(this.boxX + 60, this.boxY + 28);

		this.motherDynasty.setXY(this.boxX + 60, this.boxY + 55);
		this.motherName.setXY(this.boxX + 100, this.boxY + 63);

		this.characterDynasty.setXY(this.boxX + 20, this.boxY + 140);
		this.characterSex.setXY(this.boxX + 60, this.boxY + 140);

		this.label.setXY(this.boxX + 20, this.boxY + 95);
		this.inputBox.setXY(this.boxX + 100, this.boxY + 140);
		this.okButton.setXY(this.boxX + 230, this.boxY + 180);
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

