module ui.characterinforenderer;

import std.conv;
import std.string;
import std.typecons;

import client;
import constants;
import textinput;
import ui.characterproposalrenderer;
import ui.renderhelper;
import ui.widgetrenderer;
import ui.widgets.characterdetails;
import ui.widgets.clickwidgetdecorator;
import ui.widgets.hbox;
import ui.widgets.image;
import ui.widgets.iwidget;
import ui.widgets.label;
import ui.widgets.labelbutton;
import ui.widgets.line;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import ui.widgets.widget;
import world.character;
import world.nation;

import derelict.sdl2.sdl;

class CharacterInfoRenderer : WidgetRenderer {
	private Rebindable!(const(Character)) character;

	private bool active;

	private CharacterProposalRenderer proposalRenderer;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private CharacterDetails characterDetails;

	private Label parentsHead;
	private Line seperator1;
	private IWidget fatherName;
	private IWidget fatherDynasty;
	private IWidget fatherSex;
	private IWidget motherName;
	private IWidget motherDynasty;
	private IWidget motherSex;

	private Label partnerHead;
	private Line seperator2;
	private IWidget partnerName;
	private IWidget partnerDynasty;
	private IWidget partnerSex;
	private IWidget proposalButton;

	private Label childrenHead;
	private Line seperator3;
	private IWidget[] childrenNames;
	private IWidget[] childrenDynasty;
	private IWidget[] childrenSex;

	private LabelButton okButton;
	private Image boxBackground;

	public this(Client client, RenderHelper renderer,
	            const(Character) character) {
		this.character = character;

		super(client, renderer, "grey_a127");	// calls initWidgets

		this.active = true;
	}


	public ~this() {
		if (this.proposalRenderer !is null) {
			destroy(this.proposalRenderer);
		}

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
		} else if (message[0..6] == "child_") {
			int childIndex = to!int(message[6..$]);
			assert(childIndex < this.character.getChildren().length,
			       "CharacterInfoRenderer::buttonHandler child range error");
			const(Character) child = this.character.getChildren()[childIndex];
			if (child !is null) {
				this.setCharacter(child);
			}
		} else if (message == "proposal") {
			this.proposalRenderer = new CharacterProposalRenderer(
				this.client, this.renderer, this.character);
			this.proposalRenderer.setScreenRegion(
				this.screenRegion.x, this.screenRegion.y,
				this.screenRegion.w, this.screenRegion.h);
		}
	}


	private void setCharacter(const(Character) character) {
		this.character = character;
		this.initWidgets();
	}



	protected override void initWidgets() {
		this.clearWidgets();	// clear list of old widgets

		this.boxBackground = new Image(
			this.renderer, "bg_550_600",
			new SDL_Rect(0, 0, 550, 600));
		this.boxBackground.setZIndex(-1);
		this.addWidget(this.boxBackground);

		this.okButton = new LabelButton(
			this.renderer,
			"okButton",
			"button_100_28",
			"white_a10pc",
			&(this.okButtonCallback),
			_("OK"),
			STD_FONT,
			new SDL_Rect(0, 0, 100, 28));
		this.addWidget(this.okButton);

		// focus character
		this.characterDetails = new CharacterDetails(
			this.client, this.renderer, this.character);
		this.addWidget(this.characterDetails);

		this.initWidgetsParents();
		this.initWidgetsPartner();
		this.initWidgetsChildren();
	}


	private void initWidgetsParents() {
		// header
		this.parentsHead = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 0, 0),
			_("Parents"));
		this.allWidgets ~= this.parentsHead;

		this.seperator1 = new Line(this.renderer, "");
		this.allWidgets ~= this.seperator1;

		// father
		const(Character) father = this.character.getFather();
		IWidget tmpWidget = new RoundBorderImage(
			this.renderer, "father", "portrait_male");
		this.fatherSex = new ClickWidgetDecorator(
			tmpWidget, &this.buttonHandler);
		this.allWidgets ~= this.fatherSex;

		// father found
		if (father !is null) {
			tmpWidget = new Label(
				this.renderer, "father", NULL_TEXTURE,
				new SDL_Rect(), father.getFullName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);

			string popupText = format("%s: %d%s",
			   _("Age"),
			   father.getAge(this.client.getCurrentYear()),
			   (father.isDead() ? " ✝" : ""));
			this.fatherName = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, popupText, "ui_popup_background");
			this.fatherName.setZIndex(5);
			this.allWidgets ~= this.fatherName;

			tmpWidget = new RoundBorderImage(
				this.renderer, "father", father.getDynasty.getFlagImageName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.fatherDynasty = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, father.getDynasty().getName(),
				"ui_popup_background");
			this.fatherDynasty.setZIndex(5);
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
				this.renderer, "father", NULL_TEXTURE);
			tmpWidget.hide();
			this.fatherDynasty = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.allWidgets ~= this.fatherDynasty;
		}

		// mother
		const(Character) mother = this.character.getMother();
		tmpWidget = new RoundBorderImage(
			this.renderer, "mother", "portrait_female");
		this.motherSex = new ClickWidgetDecorator(
			tmpWidget, &this.buttonHandler);
		this.allWidgets ~= this.motherSex;

		// mother found
		if (mother !is null) {
			tmpWidget = new Label(
				this.renderer, "mother", NULL_TEXTURE,
				new SDL_Rect(), mother.getFullName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);

			string popupText = format("%s: %d%s",
			   _("Age"),
			   mother.getAge(this.client.getCurrentYear()),
			   (mother.isDead() ? " ✝" : ""));
			this.motherName = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, popupText, "ui_popup_background");
			this.motherName.setZIndex(5);
			this.allWidgets ~= this.motherName;

			tmpWidget = new RoundBorderImage(
				this.renderer, "mother", mother.getDynasty.getFlagImageName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.motherDynasty = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, mother.getDynasty().getName(),
				"ui_popup_background");
			this.motherDynasty.setZIndex(5);
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
				this.renderer, "mother", NULL_TEXTURE);
			tmpWidget.hide();
			this.motherDynasty = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.allWidgets ~= this.motherDynasty;
		}
	}


	private void initWidgetsPartner() {
		// header
		this.partnerHead = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 0, 0),
			_("Partner"));
		this.allWidgets ~= this.partnerHead;

		this.seperator2 = new Line(this.renderer, "");
		this.allWidgets ~= this.seperator2;

		this.proposalButton = new LabelButton(
			this.renderer,
			"proposal",
			"button_100_28",
			"white_a10pc",
			new SDL_Rect(0, 0, 200, 28),
			&this.buttonHandler,
			_("Send a proposal"));
		this.allWidgets ~= this.proposalButton;

		// partner
		const(Character) partner = this.character.getPartner();
		// partner found
		if (partner !is null) {
			IWidget tmpWidget = new RoundBorderImage(
				this.renderer,
				"partner",
				((partner.getSex() == Sex.MALE) ?
					"portrait_male" : "portrait_female"));
			this.partnerSex = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.allWidgets ~= this.partnerSex;

			tmpWidget = new Label(
				this.renderer, "partner", NULL_TEXTURE,
				new SDL_Rect(), partner.getFullName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);

			string popupText = format("%s: %d%s",
			   _("Age"),
			   partner.getAge(this.client.getCurrentYear()),
			   (partner.isDead() ? " ✝" : ""));
			this.partnerName = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, popupText, "ui_popup_background");
			this.partnerName.setZIndex(6);
			this.allWidgets ~= this.partnerName;

			tmpWidget = new RoundBorderImage(
				this.renderer, "partner",
				partner.getDynasty.getFlagImageName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.partnerDynasty = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, partner.getDynasty().getName(),
				"ui_popup_background");
			this.partnerDynasty.setZIndex(6);
			this.allWidgets ~= this.partnerDynasty;

			// hide proposal button
			this.proposalButton.hide();
		}
		// partner unknown
		else {
			if (this.character.getAge(this.client.getCurrentYear()) < MIN_MARRIAGE_AGE) {
				this.proposalButton.hide();
			}
			this.partnerSex = new RoundBorderImage(
				this.renderer,
				"partner",
				"",
				 new SDL_Rect());
			this.partnerSex.hide();
			this.allWidgets ~= this.partnerSex;

			this.partnerName = new Label(
				this.renderer, "partner", NULL_TEXTURE,
				new SDL_Rect(), "");
			this.partnerName.hide();
			this.allWidgets ~= this.partnerName;

			this.partnerDynasty = new RoundBorderImage(
				this.renderer, "partner", NULL_TEXTURE);
			this.partnerDynasty.hide();
			this.allWidgets ~= this.partnerDynasty;
		}
	}


	private void initWidgetsChildren() {
		// clear old lists
		this.childrenNames.length = 0;
		this.childrenDynasty.length = 0;
		this.childrenSex.length = 0;

		// header
		this.childrenHead = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 0, 0),
			_("Children"));
		this.allWidgets ~= this.childrenHead;

		this.seperator3 = new Line(this.renderer, "");
		this.allWidgets ~= this.seperator3;

		// children loop
		// TODO: sort by age
		int i = 0;
		foreach (const(Character) child; this.character.getChildren()) {
			// dynasty
			IWidget tmpWidget = new RoundBorderImage(
				this.renderer, format("child_%d", i),
				child.getDynasty.getFlagImageName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			tmpWidget = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, child.getDynasty().getName(),
				"ui_popup_background");
			tmpWidget.setZIndex(10 + i);
			this.childrenDynasty ~= tmpWidget;
			this.allWidgets ~= tmpWidget;

			// sex
			tmpWidget = new RoundBorderImage(
				this.renderer,
				format("child_%d", i),
				((child.getSex() == Sex.MALE) ?
					"portrait_male" : "portrait_female"));
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);
			this.childrenSex ~= tmpWidget;
			this.allWidgets ~= tmpWidget;

			// name
			tmpWidget = new Label(
				this.renderer, format("child_%d", i), NULL_TEXTURE,
				new SDL_Rect(), child.getFullName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, &this.buttonHandler);

			string popupText = format("%s: %d%s",
			   _("Age"),
			   child.getAge(this.client.getCurrentYear()),
			   (child.isDead() ? " ✝" : ""));
			tmpWidget = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, popupText, "ui_popup_background");
			tmpWidget.setZIndex(10 + i);
			this.childrenNames ~= tmpWidget;
			this.allWidgets ~= tmpWidget;

			++i;
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
		this.characterDetails.setXY(this.boxX + 20, this.boxY + 20);

		// parents
		this.parentsHead.setXY(this.boxX + 20, this.boxY + 90);
		this.seperator1.setBounds(
			this.parentsHead.getBounds().x + this.parentsHead.getBounds().w + 10,
			this.parentsHead.getBounds().y + 12,
			this.boxBackground.getBounds().w - 40 - (this.parentsHead.getBounds().w + 10),
			0);

		this.fatherDynasty.setXY(
			this.boxX + 20, this.seperator1.getBounds().y + 15);
		this.fatherSex.setXY(
			this.boxX + 60, this.seperator1.getBounds().y + 15);
		this.fatherName.setXY(
			this.boxX + 100, this.seperator1.getBounds().y + 23);
		this.motherDynasty.setXY(
			this.boxX + (this.boxBackground.getBounds().w / 2) + 0,
			this.seperator1.getBounds().y + 15);
		this.motherSex.setXY(
			this.boxX + (this.boxBackground.getBounds().w / 2) + 40,
			this.seperator1.getBounds().y + 15);
		this.motherName.setXY(
			this.boxX + (this.boxBackground.getBounds().w / 2) + 80,
			this.seperator1.getBounds().y + 23);

		// partner
		this.partnerHead.setXY(this.boxX + 20, this.boxY + 160);
		this.seperator2.setBounds(
			this.partnerHead.getBounds().x +
				this.partnerHead.getBounds().w + 10,
			this.partnerHead.getBounds().y + 12,
			this.boxBackground.getBounds().w - 40 -
				(this.partnerHead.getBounds().w + 10),
			0);
		this.proposalButton.setXY(
			0, this.seperator2.getBounds().y + 15);
		this.proposalButton.centerHorizontally();
		this.partnerDynasty.setXY(
			this.boxX + 20, this.seperator2.getBounds().y + 15);
		this.partnerSex.setXY(
			this.boxX + 60, this.seperator2.getBounds().y + 15);
		this.partnerName.setXY(
			this.boxX + 100, this.seperator2.getBounds().y + 23);

		// children
		this.childrenHead.setXY(this.boxX + 20, this.boxY + 230);
		this.seperator3.setBounds(
			this.childrenHead.getBounds().x +
				this.childrenHead.getBounds().w + 10,
			this.childrenHead.getBounds().y + 12,
			this.boxBackground.getBounds().w - 40 -
				(this.childrenHead.getBounds().w + 10),
			0);

		int childStartY = this.seperator3.getBounds().y + 15;
		for (int i=0; i < this.childrenNames.length; ++i) {
			this.childrenDynasty[i].setXY(
				this.boxX + 20, childStartY);
			this.childrenSex[i].setXY(
				this.boxX + 60, childStartY);
			this.childrenNames[i].setXY(
				this.boxX + 100, childStartY + 8);
			childStartY += 35;
		}

		this.okButton.setXY(this.boxX + 420,
		                    this.boxY + 550);
	}


	public override void setScreenRegion(int x, int y, int w, int h) {
		this.screenRegion.x = x;
		this.screenRegion.y = y;
		this.screenRegion.w = w;
		this.screenRegion.h = h;

		if (this.proposalRenderer !is null && this.proposalRenderer.isActive()) {
			this.proposalRenderer.setScreenRegion(
				this.screenRegion.x, this.screenRegion.y,
				this.screenRegion.w, this.screenRegion.h);
		}
	}


	public override void render(int tick=0) {
		if (this.active) {
			if (this.proposalRenderer !is null && this.proposalRenderer.isActive()) {
				this.proposalRenderer.render();
			} else {
				super.render(tick);
			}
		}
	}


	public bool isActive() {
		return this.active;
	}

	public override void handleEvent(SDL_Event event) {
		if (this.active) {
			if (this.proposalRenderer !is null && this.proposalRenderer.isActive()) {
				this.proposalRenderer.handleEvent(event);
				if (!this.proposalRenderer.isActive()) {
					this.proposalRenderer = null;
				}
			} else {
				// widgets
				super.handleEvent(event);

				// key press
				if (event.type == SDL_KEYDOWN) {
					// enter input
					if (event.key.keysym.sym == SDLK_RETURN ||
							event.key.keysym.sym == SDLK_ESCAPE) {
						this.okButtonCallback("");
					}
				}
			}
		}
	}
}

