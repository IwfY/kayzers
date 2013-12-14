module ui.proposalreplyrenderer;

import client;
import constants;

import ui.renderhelper;
import ui.widgetrenderer;

import ui.widgets.characterinfo;
import ui.widgets.image;
import ui.widgets.label;
import ui.widgets.labelbutton;

import world.character;


import derelict.sdl2.sdl;

import std.string;

class ProposalReplyRenderer : WidgetRenderer {
	private const(Character) sender;
	private const(Character) receiver;

	private bool active;

	private int boxX;
	private int boxY;
	private Image boxBackground;
	private Label proposeLabel;
	private Label questionLabel;
	private LabelButton yesButton;
	private LabelButton noButton;
	private CharacterInfo senderInfo;
	private CharacterInfo receiverInfo;


	public this(Client client, RenderHelper renderer, int senderId, int receiverId) {
		this.sender = client.getServerStub().getCharacter(senderId);
		this.receiver = client.getServerStub().getCharacter(receiverId);

		super(client, renderer, "grey_a127");	// calls initWidgets

		this.active = true;
	}

	private const(string) _(string text) const {
		return this.client.getI18nString(text);
	}

	private void callback(string message) {
		if (message == "yes") {
			this.client.getServerStub().proposalAnswered(
				this.sender.getId(), this.receiver.getId(), true);
			this.active = false;
		} else if (message == "no") {
			this.client.getServerStub().proposalAnswered(
				this.sender.getId(), this.receiver.getId(), false);
			this.active = false;
		}
	}

	protected override void initWidgets() {
		this.boxBackground = new Image(
			this.renderer, "bg_350_230", new SDL_Rect(0, 0, 350, 230));
		this.boxBackground.setZIndex(-1);
		this.addWidget(this.boxBackground);

		this.senderInfo = new CharacterInfo(
			this.client, this.renderer, this.sender, &(this.callback), "");
		this.senderInfo.setZIndex(2);
		this.addWidget(this.senderInfo);

		this.receiverInfo = new CharacterInfo(
			this.client, this.renderer, this.receiver, &(this.callback), "");
		this.receiverInfo.setZIndex(2);
		this.addWidget(this.receiverInfo);

		this.proposeLabel = new Label(this.renderer, _("proposes to"));
		this.addWidget(this.proposeLabel);
		this.questionLabel = new Label(this.renderer, _("Do you accept?"));
		this.addWidget(this.questionLabel);

		this.yesButton = new LabelButton(
			this.renderer, "yes", "button_100_28", "white_a10pc",
			new SDL_Rect(0, 0, 100, 28), &(this.callback), _("Yes"), STD_FONT);
		this.addWidget(this.yesButton);

		this.noButton = new LabelButton(
			this.renderer, "no", "button_100_28", "white_a10pc",
			new SDL_Rect(0, 0, 100, 28), &(this.callback), _("No"), STD_FONT);
		this.addWidget(this.noButton);
	}

	protected override void updateWidgets() {
		this.boxX = this.screenRegion.x + (this.screenRegion.w - 350) / 2;
		this.boxY = this.screenRegion.y + (this.screenRegion.h - 230) / 2;

		this.boxBackground.setXY(this.boxX, this.boxY);

		this.senderInfo.setXY(this.boxX + 20, this.boxY + 20);
		this.proposeLabel.setXY(this.boxX + 40, this.boxY + 60);
		this.receiverInfo.setXY(this.boxX + 60, this.boxY + 90);
		this.questionLabel.setXY(this.boxX + 20, this.boxY + 140);

		this.yesButton.setXY(this.boxX + 20, this.boxY + 180);
		this.noButton.setXY(this.boxX + 230, this.boxY + 180);
	}

	public override void render(int tick=0) {
		if (this.active) {
			super.render(tick);
		}
	}


	public bool isActive() {
		return this.active;
	}
}
