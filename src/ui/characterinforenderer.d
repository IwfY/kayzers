module ui.characterinforenderer;

import std.conv;
import std.string;
import std.typecons;

import client;
import constants;
import serverstub;
import textinput;
import ui.characterproposalrenderer;
import ui.renderhelper;
import ui.widgetrenderer;
import ui.widgets.characterdetails;
import ui.widgets.characterinfo;
import ui.widgets.clickwidgetdecorator;
import ui.widgets.image;
import ui.widgets.iwidget;
import ui.widgets.label;
import ui.widgets.labelbutton;
import ui.widgets.line;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import ui.widgets.vbox;
import ui.widgets.widget;
import world.character;
import world.nation;

import derelict.sdl2.sdl;

class CharacterInfoRenderer : WidgetRenderer {
	private Rebindable!(const(Character)) character;
	private Rebindable!(const(Character)) lastCharacter;

	private bool active;
	private ServerStub serverStub;

	private CharacterProposalRenderer proposalRenderer;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private CharacterDetails characterDetails;

	private Label fatherHead;
	private Line seperator1;
	private Label motherHead;
	private Line seperator1_2;
	private CharacterInfo fatherInfo;
	private CharacterInfo motherInfo;

	private Label partnerHead;
	private Line seperator2;
	private CharacterInfo partnerInfo;
	private IWidget proposalButton;
	private Label proposalLabel;

	private Label childrenHead;
	private Line seperator3;
	private VBox childrenInfo;

	private LabelButton okButton;
	private LabelButton backButton;
	private Image boxBackground;

	public this(Client client, RenderHelper renderer,
	            const(Character) character) {
		this.character = character;
		this.lastCharacter = character;

		this.serverStub = client.getServerStub();
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
				this.client, this.renderer, this, this.character);
			this.proposalRenderer.setScreenRegion(
				this.screenRegion.x, this.screenRegion.y,
				this.screenRegion.w, this.screenRegion.h);
		} else if (message == "backButton") {
			this.setCharacter(this.lastCharacter);
		}
	}


	public void setCharacter(const(Character) character) {
		this.lastCharacter = this.character;
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
			new SDL_Rect(0, 0, 100, 28),
			&(this.okButtonCallback),
			_("OK"),
			STD_FONT);
		this.addWidget(this.okButton);

		this.backButton = new LabelButton(
			this.renderer,
			"backButton",
			"button_100_28",
			"white_a10pc",
			new SDL_Rect(0, 0, 100, 28),
			&(this.buttonHandler),
			_("Back"),
			STD_FONT);
		this.addWidget(this.backButton);

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
		this.fatherHead = new Label(
			this.renderer, _("Father"));
		this.addWidget(this.fatherHead);
		this.motherHead = new Label(
			this.renderer, _("Mother"));
		this.addWidget(this.motherHead);

		this.seperator1 = new Line(this.renderer);
		this.addWidget(this.seperator1);
		this.seperator1_2 = new Line(this.renderer);
		this.addWidget(this.seperator1_2);

		// father
		this.fatherInfo = new CharacterInfo(
			this.client, this.renderer,
			this.character.getFather(), &this.buttonHandler, "father");
		this.addWidget(this.fatherInfo);

		// mother
		this.motherInfo = new CharacterInfo(
			this.client, this.renderer,
			this.character.getMother(), &this.buttonHandler, "mother");
		this.addWidget(this.motherInfo);
	}


	private void initWidgetsPartner() {
		// header
		this.partnerHead = new Label(
			this.renderer, _("Partner"));
		this.addWidget(this.partnerHead);

		this.seperator2 = new Line(this.renderer);
		this.addWidget(this.seperator2);

		this.proposalButton = new LabelButton(
			this.renderer,
			"proposal",
			"button_100_28",
			"white_a10pc",
			new SDL_Rect(0, 0, 200, 28),
			&this.buttonHandler,
			_("Send a proposal"));
		this.addWidget(this.proposalButton);

		this.proposalLabel = new Label(this.renderer, "");
		this.addWidget(this.proposalLabel);
		const(Character) proposedTo =
			this.serverStub.getProposedToCharacter(this.character.getId());
		if (proposedTo !is null) {
			this.proposalLabel.setText(
				_("Proposed to %s").format(proposedTo.getFullName()));
		} else {
			this.proposalLabel.hide();
		}

		// partner
		this.partnerInfo = new CharacterInfo(
			this.client, this.renderer,
			this.character.getPartner(), &this.buttonHandler, "partner");
		this.addWidget(this.partnerInfo);

		if (this.character.getPartner() is null) {
			this.partnerInfo.hide();
		}
		if (this.character.getDynasty() != this.serverStub.getCurrentDynasty() ||
				!this.serverStub.canPropose(this.character)) {
			this.proposalButton.hide();
		}
	}


	private void initWidgetsChildren() {
		// header
		this.childrenHead = new Label(
			this.renderer, _("Children"));
		this.addWidget(this.childrenHead);

		this.seperator3 = new Line(this.renderer);
		this.addWidget(this.seperator3);

		// children loop
		// TODO: sort by age
		this.childrenInfo = new VBox(this.renderer);
		int i = 0;
		foreach (const(Character) child; this.character.getChildren()) {
			CharacterInfo childInfo = new CharacterInfo(
				this.client, this.renderer,
				child, &this.buttonHandler, format("child_%d", i));
			this.childrenInfo.addChild(childInfo);
			++i;
		}
		this.addWidget(this.childrenInfo);
	}


	private void okButtonCallback(string message) {
		this.active = false;
	}

	private void characterButtonCallback(string message) {
	}


	protected override void updateWidgets() {
		this.boxX = this.screenRegion.x +
			(this.screenRegion.w - this.boxBackground.w()) / 2;
		this.boxY = this.screenRegion.y +
			(this.screenRegion.h - this.boxBackground.h()) / 2;

		this.boxBackground.setXY(this.boxX,
		                         this.boxY);

		// focus character
		this.characterDetails.setXY(this.boxX + 20, this.boxY + 20);

		// parents
		int halfWidth = this.boxBackground.getBounds().w / 2;
		this.fatherHead.setXY(this.boxX + 20, this.boxY + 90);
		this.seperator1.setBounds(
			this.fatherHead.getBounds().x + this.fatherHead.getBounds().w + 10,
			this.fatherHead.getBounds().y + 12,
			halfWidth - 40 - (this.fatherHead.getBounds().w + 10),
			0);
		this.motherHead.setXY(this.boxX + halfWidth, this.boxY + 90);
		this.seperator1_2.setBounds(
			this.motherHead.getBounds().x + this.motherHead.getBounds().w + 10,
			this.motherHead.getBounds().y + 12,
			halfWidth - 20 - (this.motherHead.getBounds().w + 10),
			0);

		this.fatherInfo.setXY(
			this.boxX + 20, this.seperator1.getBounds().y + 15);
		this.motherInfo.setXY(
			this.boxX + halfWidth + 0,
			this.seperator1.getBounds().y + 15);

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
		this.proposalButton.centerHorizontally(
			this.boxX, this.boxBackground.w());

		this.proposalLabel.setXY(
			0, this.seperator2.getBounds().y + 25);
		this.proposalLabel.centerHorizontally(
			this.boxX, this.boxBackground.w());

		this.partnerInfo.setXY(
			this.boxX + 20, this.seperator2.getBounds().y + 15);

		// children
		this.childrenHead.setXY(this.boxX + 20, this.boxY + 230);
		this.seperator3.setBounds(
			this.childrenHead.getBounds().x +
				this.childrenHead.getBounds().w + 10,
			this.childrenHead.getBounds().y + 12,
			this.boxBackground.getBounds().w - 40 -
				(this.childrenHead.getBounds().w + 10),
			0);
		this.childrenInfo.setXY(
			this.boxX + 20, this.seperator3.getBounds().y + 15);

		this.backButton.setXY(this.boxX + 20, this.boxY + 550);
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
					this.initWidgets();
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

