module ui.widgets.characterdetails;

import std.string;

import derelict.sdl2.sdl;

import client;
import constants;
import utils;
import ui.renderhelper;
import ui.widgets.containerwidget;
import ui.widgets.hbox;
import ui.widgets.iwidget;
import ui.widgets.label;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import world.character;
import world.dynasty;
import world.nation;

class CharacterDetails : ContainerWidget {
	private const(Client) client;
	private const(Character) character;

	private Label characterName;
	private Label characterRulerLabel;
	private IWidget characterAge;
	private IWidget characterDynasty;
	private RoundBorderImage characterSex;
	private HBox characterRulingNations;

	public this(const(Client) client,
	            RenderHelper renderer,
	            const(Character) character) {
		super(renderer);

		this.client = client;
		this.character = character;

		this.initWidgets();
	}

	private const(string) _(string text) const {
		return this.client.getI18nString(text);
	}


	private void initWidgets() {
		// name label
		this.characterName = new Label(
			this.renderer,
			this.character.getFullName(),
			"std_20");
		this.addChild(this.characterName);

		IWidget tmpWidget;

		// dynasty flag
		if (this.character.getDynasty() is null) {
			this.characterDynasty = new RoundBorderImage(
				this.renderer, NULL_TEXTURE);
		} else {
			tmpWidget = new RoundBorderImage(
				this.renderer,
				this.character.getDynasty().getFlagImageName());
			this.characterDynasty = new PopupWidgetDecorator(
				tmpWidget, this.renderer, this.character.getDynasty().getName(),
				"ui_popup_background");
		}
		this.characterDynasty.setZIndex(2);
		this.addChild(this.characterDynasty);

		// sex portrait
		this.characterSex = new RoundBorderImage(
			this.renderer, NULL_TEXTURE);
		if (this.character.getSex() == Sex.MALE) {
			this.characterSex.setTextureName("portrait_male");
		} else {
			this.characterSex.setTextureName("portrait_female");
		}
		this.addChild(this.characterSex);

		// age label
		tmpWidget = new Label(
			this.renderer,
			format("%s: %d%s",
				   _("Age"),
				   this.character.getAge(this.client.getServerStub().getCurrentYear()),
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
		this.addChild(this.characterAge);

		// ruling nations
		this.characterRulerLabel = new Label(
			this.renderer, _("Ruler of") ~ ":");
		this.addChild(this.characterRulerLabel);

		this.characterRulingNations = new HBox(this.renderer);

		foreach (const(Nation) nation; this.client.getServerStub().getNations()) {
			if (this.character == nation.getRuler()) {
				IWidget tmpNationWidget = new RoundBorderImage(
					this.renderer,
					nation.getPrototype().getFlagImageName());
				IWidget nationFlag = new PopupWidgetDecorator(
					tmpNationWidget,
					this.renderer,
					nation.getName(),
					"ui_popup_background");
				nationFlag.setZIndex(4);
				this.characterRulingNations.addChild(nationFlag);
			}
		}
		this.addChild(this.characterRulingNations);
	}

	protected override void updateChildren() {
		this.characterDynasty.setXY(this.x(), this.y());
		this.characterSex.setXY(this.x() + 40, this.y());
		this.characterName.setXY(this.x() + 80, this.y() + 3);
		this.characterAge.setXY(this.x() + 80, this.y() + 34);
		this.characterRulerLabel.setXY(this.x() + 160, this.y() + 34);

		int nationStartX =
			this.characterRulerLabel.x() + this.characterRulerLabel.w() + 10;
		this.characterRulingNations.setXY(nationStartX, this.y() + 30);

		this.bounds.w = -this.x() + max(
			this.characterName.x() + this.characterName.w(),
			this.characterRulingNations.x() + this.characterRulingNations.w());
		this.bounds.h =
			this.characterRulingNations.y() - this.y() + this.characterRulingNations.h();
	}
}
