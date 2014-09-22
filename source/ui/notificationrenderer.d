module ui.notificationrenderer;

import client;
import message;
import messagebroker;
import observer;
import serverstub;
import utils;
import ui.renderer;
import ui.renderhelper;
import world.nation;
import world.nationprototype;

import derelict.sdl2.sdl;

import std.conv;

/**
 * renderer as child of InGameRenderer to render notifications
 *
 * - year change
 * - nation change
 **/
class NotificationRenderer : Renderer, Observer {
	private MessageBroker messageBroker;
	private ServerStub serverStub;

	// sdl_tick when last notification started
	private uint startNotifyNation;

	public this(Client client, RenderHelper renderer,
				MessageBroker messageBroker) {
		super(client, renderer);
		this.serverStub = this.client.getServerStub();
		this.messageBroker = messageBroker;

		this.messageBroker.register(this, "nationChanged");
	}

	public ~this() {
		this.messageBroker.unregister(this, "nationChanged");
	}

	public override void notify(const(Message) message) {
		// active nation changed
		if (message.text == "nationChanged") {
			this.startNotifyNation = SDL_GetTicks();
		}
	}

	public override void render(int tick=0) {
		uint diffStartNotifyNation =
			SDL_GetTicks() - this.startNotifyNation;
		if (diffStartNotifyNation < 1360) {
			int alpha = 180 - ((cast(int)diffStartNotifyNation - 1000) / 2);
			alpha = min(180, alpha);
			this.renderer.drawTextureAlpha(
				this.screenRegion.x, this.screenRegion.y + 30,
				this.screenRegion.w, 50,
				"black", cast(ubyte)alpha);
		}
		if (diffStartNotifyNation < 1000) {
			const(Nation) nation = this.serverStub.getCurrentNation();
			const(NationPrototype) nationPrototype = nation.getPrototype();
			// flag
			this.renderer.drawTexture(
				this.screenRegion.x + 51, this.screenRegion.y + 41,
				nationPrototype.getFlagImageName());
			this.renderer.drawTexture(
				this.screenRegion.x + 50, this.screenRegion.y + 40,
				"border_round_30");
			// nation name
			this.renderer.drawText(
				this.screenRegion.x + 100, this.screenRegion.y + 38,
				nation.getName(),
				"notificationLarge");
			// year
			this.renderer.drawText(
				this.screenRegion.x + this.screenRegion.w - 200,
				this.screenRegion.y + 38,
				"Year " ~ text(this.serverStub.getCurrentYear()),
				"notificationLarge");
		}
	}


	public override void handleEvent(SDL_Event event) {

	}
}
