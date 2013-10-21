module ui.notificationrenderer;

import client;
import messagebroker;
import observer;
import ui.renderer;
import ui.renderhelper;
import world.nation;

import derelict.sdl2.sdl;

/**
 * renderer as child of InGameRenderer to render notifications
 *
 * - year change
 * - nation change
 **/
class NotificationRenderer : Renderer, Observer {
	private MessageBroker messageBroker;

	public this(Client client, RenderHelper renderer,
				MessageBroker messageBroker) {
		super(client, renderer);
		this.messageBroker = messageBroker;

		this.messageBroker.register(this, "nationChanged");
	}

	public ~this() {
		this.messageBroker.unregister(this, "nationChanged");
	}

	public override void notify(string message) {
		// active nation changed
		if (message == "nationChanged") {

		}
	}

	public override void render(int tick=0) {

	}


	public override void handleEvent(SDL_Event event) {

	}
}
